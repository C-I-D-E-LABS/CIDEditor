package;

import sys.FileSystem;
import sys.io.File;
import haxe.Json;
import flixel.util.FlxSave;

// DLC data/storage helpers pulled out of XEternalDlcMenu.hx (the DLC menu
// state) to keep that script focused on UI. Everything here is stateless
// and takes whatever it needs (mainPath, a dlc entry, etc.) as arguments,
// except the per-DLC save tracking at the bottom, which is backed by real
// static fields instead of an HScript instance's own arrays — those stay
// correct and shared no matter which script calls in, unlike statics on a
// separately-loaded HScript class.
class DlcUtils {
	public static function getFolderSize(path:String):Float {
		var total:Float = 0;
		if (!FileSystem.exists(path)) return total;

		var base = path.charAt(path.length - 1) == "/" ? path : path + "/";
		for (entry in FileSystem.readDirectory(base)) {
			var full = base + entry;
			if (FileSystem.isDirectory(full))
				total += getFolderSize(full);
			else {
				try { total += FileSystem.stat(full).size; } catch (e:Dynamic) {}
			}
		}
		return total;
	}

	public static function formatBytes(bytes:Float):String {
		if (bytes >= 1024 * 1024 * 1024) return (Math.round(bytes / (1024 * 1024 * 1024) * 100) / 100) + " GB";
		if (bytes >= 1024 * 1024)        return (Math.round(bytes / (1024 * 1024) * 100) / 100) + " MB";
		if (bytes >= 1024)               return (Math.round(bytes / 1024 * 100) / 100) + " KB";
		return Std.int(bytes) + " B";
	}

	public static function deleteDlcFolder(path:String):Void {
		if (!FileSystem.exists(path)) return;

		var base = path.charAt(path.length - 1) == "/" ? path : path + "/";
		for (entry in FileSystem.readDirectory(base)) {
			var full = base + entry;
			if (FileSystem.isDirectory(full))
				deleteDlcFolder(full);
			else
				FileSystem.deleteFile(full);
		}
		FileSystem.deleteDirectory(path);
	}

	// mainPath is passed in (rather than read off some shared state) so this
	// stays correct regardless of which mod folder is currently active.
	public static function sanitizeDlcId(name:String, mainPath:String):String {
		var lower = name.toLowerCase();
		var cleaned = "";
		for (i in 0...lower.length) {
			var c = lower.charAt(i);
			cleaned += (c == " ") ? "_" : c;
		}
		if (cleaned == "") cleaned = "local_dlc";

		var finalId = cleaned;
		var suffix = 1;
		while (FileSystem.exists(mainPath + finalId)) {
			suffix++;
			finalId = cleaned + "_" + suffix;
		}
		return finalId;
	}

	public static function dlcOwned(dlc:Dynamic, mainPath:String):Bool
		return FileSystem.exists(mainPath + dlc.id);

	public static function dlcLocked(dlc:Dynamic, mainPath:String):Bool
		return !dlcOwned(dlc, mainPath) && (dlc.zipUrl == null || dlc.zipUrl == "");

	public static function normalizeDlcEntry(d:Dynamic):Dynamic {
		if (d.type == null) d.type = "song";
		if (d.type == "week" && d.songs == null) d.songs = [];
		return d;
	}

	// Keeps only the first entry for each id — a safety net so a bug
	// anywhere upstream (remote list + local scan overlapping, a double
	// merge, etc.) can never show the same DLC twice in the grid.
	public static function dedupeDlcsById(list:Array<Dynamic>):Array<Dynamic> {
		var seenIds:Array<String> = [];
		var result:Array<Dynamic> = [];
		for (d in list) {
			if (seenIds.indexOf(d.id) == -1) {
				seenIds.push(d.id);
				result.push(d);
			}
		}
		return result;
	}

	public static function buildLocalDLCList(mainPath:String):Array<Dynamic> {
		var list:Array<Dynamic> = [];
		if (!FileSystem.exists(mainPath)) return list;

		for (entry in FileSystem.readDirectory(mainPath)) {
			var fullPath = mainPath + entry;
			if (!FileSystem.isDirectory(fullPath)) continue;

			var metaPath = fullPath + "/dlc.json";
			var meta:Dynamic = { id: entry, name: entry, zipUrl: null };

			if (FileSystem.exists(metaPath)) {
				try {
					var parsed = Json.parse(File.getContent(metaPath));
					meta = parsed;
					if (meta.id   == null) meta.id   = entry;
					if (meta.name == null) meta.name = entry;
					meta.zipUrl = null;
				} catch (e:Dynamic) {}
			}

			list.push(normalizeDlcEntry(meta));
		}

		return list;
	}

	// Folds any on-disk local DLCs into `existing` (without clobbering
	// whatever's already in it — remote entries included), and drops
	// entries that are neither downloadable nor still on disk. This is what
	// makes locally-created DLCs survive a REFRESH: the remote gist has no
	// idea they exist, so the caller always re-scans the dlc/ folder and
	// merges rather than trusting the remote list alone. Returns a new list
	// rather than mutating `existing`.
	public static function mergeInLocalDlcs(existing:Array<Dynamic>, mainPath:String):Array<Dynamic> {
		var merged = existing.copy();

		if (FileSystem.exists(mainPath)) {
			for (local in buildLocalDLCList(mainPath)) {
				var found = false;
				for (e in merged) if (e.id == local.id) { found = true; break; }
				if (!found) merged.push(local);
			}
		}

		var kept:Array<Dynamic> = [];
		for (d in merged) {
			var stillLocalOnDisk = FileSystem.exists(mainPath + d.id);
			var hasRemote = (d.zipUrl != null && d.zipUrl != "");
			if (stillLocalOnDisk || hasRemote) kept.push(d);
		}
		return dedupeDlcsById(kept);
	}

	// ------------------------------------------------------------------
	// Per-DLC save/progress tracking. Each DLC gets its own FlxSave (bound
	// to "dlc_<id>") instead of sharing one array in the main save. This
	// menu has no visibility into whether a song was actually WON or LOST —
	// PlayState/win-lose handling lives elsewhere and never calls back
	// here — so "played" means "launched from the menu at least once", not
	// "cleared". Swap isWeekFullyPlayed()'s check for a real story-
	// completion flag (XEternalSDataFlags / StateFlags) if one exists for
	// this — this is a self-contained fallback so the feature works
	// without it.
	// ------------------------------------------------------------------

	static var saveIds:Array<String> = [];
	static var saves:Array<FlxSave>  = [];

	static function save(dlcId:String):FlxSave {
		var idx = saveIds.indexOf(dlcId);
		if (idx != -1) return saves[idx];

		var s = new FlxSave();
		s.bind("dlc_" + dlcId);
		if (s.data.playedSongs == null) s.data.playedSongs = [];

		saveIds.push(dlcId);
		saves.push(s);
		return s;
	}

	public static function markSongPlayed(dlcId:String, songId:String):Void {
		var list:Array<String> = save(dlcId).data.playedSongs;
		if (list.indexOf(songId) == -1) {
			list.push(songId);
			save(dlcId).data.playedSongs = list;
			save(dlcId).flush();
		}
	}

	public static function hasPlayedSong(dlcId:String, songId:String):Bool {
		var list:Array<String> = save(dlcId).data.playedSongs;
		return list.indexOf(songId) != -1;
	}

	public static function isWeekFullyPlayed(dlc:Dynamic):Bool {
		if (dlc.type != "week" || dlc.songs == null) return false;
		var songs:Array<Dynamic> = dlc.songs;
		if (songs.length == 0) return false;

		for (s in songs)
			if (!hasPlayedSong(dlc.id, Std.string(s))) return false;
		return true;
	}

	public static function getNextUnplayedSong(dlc:Dynamic):String {
		var songs:Array<Dynamic> = dlc.songs;
		for (s in songs) {
			var songId = Std.string(s);
			if (!hasPlayedSong(dlc.id, songId)) return songId;
		}
		return Std.string(songs[songs.length - 1]); // fully played — replay the last one
	}
}