// Scripted port of funkin.menus.FreeplayState, loaded via ModState + [StateRedirects] in this
// game's game.ini instead of the compiled engine class. See FreeplayState.hx in the engine
// source for the original this was ported from - keep them in sync if you change one.
//
// Written to use only things that exist at runtime (no typedef/enum-abstract imports, no `using`
// extension calls, no macros): ChartMetaData is plain Dynamic, MathUtil.maxSmart (a macro) is
// Math.max chains, HighscoreChange enum values go through Type.createEnum, and the original's
// FreeplaySonglist class is inlined as loadSongList()/getSongsFromSource() below.

import flixel.text.FlxText.FlxTextAlign;
import flixel.util.FlxColor;
import funkin.backend.chart.Chart;
import funkin.backend.scripting.EventManager;
import funkin.backend.scripting.events.menu.MenuChangeEvent;
import funkin.backend.scripting.events.menu.freeplay.FreeplaySongSelectEvent;
import funkin.backend.scripting.events.menu.freeplay.FreeplayAlphaUpdateEvent;
import funkin.backend.system.Logs;
import funkin.backend.utils.CoolSfx;
import funkin.backend.utils.DiscordUtil;
import funkin.backend.utils.FlxInterpolateColor;
import funkin.game.HealthIcon;
import funkin.savedata.FunkinSave;
import funkin.backend.utils.TranslationUtil as TU;

var songs:Array<Dynamic> = [];
var curSong:Dynamic = null;
var curDifficulties:Array<String> = [];
var curDiffMetaKeys:Array<String> = [];

var curSelected = 0;
var curDifficulty = 1;
var curCoopMode = 0;

var scoreText:FlxText;
var diffText:FlxText;
var coopText:FlxText;

var lerpScore:Float = 0;
var intendedScore = 0;

var scoreBG:FlxSprite;
var bg:FlxSprite;

var canSelect = true;
var curPlaying = false;

var grpSongs:FlxTypedGroup<Alphabet>;
var iconArray:Array<HealthIcon> = [];
var interpColor:FlxInterpolateColor;

var TEXT_FREEPLAY_SCORE:Dynamic;
var coopLabels:Array<String> = [];

var __opponentMode = false;
var __coopMode = false;

function create() {
	TEXT_FREEPLAY_SCORE = TU.getRaw("freeplay.score");
	coopLabels = [
		TU.translate("freeplay.solo"),
		TU.translate("freeplay.opponentMode"),
		TU.translate("freeplay.coopMode"),
		TU.translate("freeplay.coopModeSwitched")
	];

	CoolUtil.playMenuSong();
	songs = loadSongList(true, 'songs/', true);

	for (k => s in songs) {
		if (s.name == Options.freeplayLastSong)
			curSelected = k;
	}
	
	updateCurDifficulties();
	for (i => diff in curDifficulties) {
		if (curDiffMetaKeys[i] == Options.freeplayLastVariation && diff == Options.freeplayLastDifficulty)
			curDifficulty = i;
	}

	updateCurSong();

	DiscordUtil.call("onMenuLoaded", ["Freeplay"]);

	bg = new FlxSprite(0, 0);
	CoolUtil.loadAnimatedGraphic(bg, Paths.image('menus/menuDesat'));
	if (songs.length > 0)
	bg.color = songs[0].color;
	bg.antialiasing = true;
	add(bg);
	

	grpSongs = new FlxTypedGroup<Alphabet>();
	add(grpSongs);

	for (i in 0...songs.length) {
		var songText = new Alphabet(0, (70 * i) + 30, songs[i].displayName, "bold");
		songText.isMenuItem = true;
		songText.targetY = i;
		grpSongs.add(songText);

		var icon = new HealthIcon(songs[i].icon);
		icon.sprTracker = songText;
		if (Math.max(icon.width, icon.height) > 150) CoolUtil.setUnstretchedGraphicSize(icon, 150, 150);

		// using a FlxGroup is too much fuss!
		iconArray.push(icon);
		add(icon);
	}

	scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
	scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, FlxTextAlign.RIGHT);

	scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 1, 0xFF000000);
	scoreBG.alpha = 0.6;
	add(scoreBG);

	diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
	diffText.font = scoreText.font;
	add(diffText);

	coopText = new FlxText(diffText.x, diffText.y + diffText.height + 2, 0, "", 24);
	coopText.font = scoreText.font;
	add(coopText);

	add(scoreText);

	changeSelection(0, true);
	changeCoopMode(0, true);

	interpColor = new FlxInterpolateColor(bg.color);
}

function update(elapsed) {
	if (FlxG.sound.music != null && FlxG.sound.music.volume < 0.7) {
		FlxG.sound.music.volume += 0.5 * elapsed;
	}

	lerpScore = lerp(lerpScore, intendedScore, 0.4);

	if (Math.abs(lerpScore - intendedScore) <= 10)
		lerpScore = intendedScore;

	if (canSelect) {
		changeSelection((controls.UP_P ? -1 : 0) + (controls.DOWN_P ? 1 : 0) - FlxG.mouse.wheel);
		changeDiff((controls.LEFT_P ? -1 : 0) + (controls.RIGHT_P ? 1 : 0));
		changeCoopMode((controls.CHANGE_MODE ? 1 : 0));
		// putting it before so that its actually smooth

		if (FlxG.mouse.justPressed && grpSongs != null) {
			for (index => sprite in grpSongs.members) {
				if (curSelected != index && FlxG.mouse.overlaps(sprite)) {
					changeSelection(index - curSelected);
					break;
				}
			}
		}

		updateOptionsAlpha();
	}

	scoreText.text = TEXT_FREEPLAY_SCORE.format([Math.round(lerpScore)]);
	var boxWidth = Math.max(Math.max(diffText.width, scoreText.width), coopText.width) + 8;
	scoreBG.scale.set(boxWidth, (coopText.visible ? coopText.y + coopText.height : 66));
	scoreBG.updateHitbox();
	scoreBG.x = FlxG.width - scoreBG.width;

	scoreText.x = coopText.x = scoreBG.x + 4;
	diffText.x = Std.int(scoreBG.x + ((scoreBG.width - diffText.width) / 2));

	interpColor.fpsLerpTo(curSong.color, 0.0625);
	bg.color = interpColor.color;

	if (controls.BACK || FlxG.mouse.justPressedRight) {
		CoolUtil.playMenuSFX(CoolSfx.CANCEL, 0.7);
		FlxG.switchState(new MainMenuState());
	}

	#if sys
	if (FlxG.keys.justPressed.EIGHT && Sys.args().indexOf("-livereload") != -1)
		convertChart();
	#end

	if (controls.ACCEPT || (FlxG.mouse.justPressed && grpSongs != null && grpSongs.members[curSelected] != null
		&& FlxG.mouse.overlaps(grpSongs.members[curSelected]))) {
		select();
	}
}

function updateCoopModes() {
	__opponentMode = false;
	__coopMode = false;
	if (curSong.coopAllowed && curSong.opponentModeAllowed) {
		__opponentMode = curCoopMode % 2 == 1;
		__coopMode = curCoopMode >= 2;
	} else if (curSong.coopAllowed) {
		__coopMode = curCoopMode == 1;
	} else if (curSong.opponentModeAllowed) {
		__opponentMode = curCoopMode == 1;
	}
}

function select() {
	updateCoopModes();

	if (curDifficulties.length == 0) return;

	var evt = event("onSelect", EventManager.get(FreeplaySongSelectEvent).recycle(curSong.name, curDifficulties[curDifficulty], curSong.variant, __opponentMode, __coopMode));

	if (evt.cancelled) return;

	Options.freeplayLastSong = curSong.name;
	Options.freeplayLastDifficulty = curDifficulties[curDifficulty];
	Options.freeplayLastVariation = curSong.variant;

	PlayState.loadSong(evt.song, evt.difficulty, evt.variant, evt.opponentMode, evt.coopMode);
	FlxG.switchState(new PlayState());
}

function convertChart() {
	trace("Converting " + curSong.name + " " + curDifficulties[curDifficulty] + " " + curSong.variant + " to Codename format...");
	var chart = Chart.parse(curSong.name, curDifficulties[curDifficulty], curSong.variant);
	Chart.save(chart, curDifficulties[curDifficulty], curSong.variant);
}

function changeDiff(change:Int = 0, force:Bool = false) {
	if (change == 0 && !force) return;

	var validDifficulties = curDifficulties.length > 0;
	var evt = event("onChangeDiff", EventManager.get(MenuChangeEvent).recycle(curDifficulty, validDifficulties ? FlxMath.wrap(curDifficulty + change, 0, curDifficulties.length - 1) : 0, change));

	if (evt.cancelled) {
		if (force) updateCurSong();
		return;
	}

	curDifficulty = evt.value;
	updateCurSong();
	updateScore();

	var text = '-';
	if (validDifficulties) {
		text = curDifficulties[curDifficulty].toUpperCase();
		if (curSong != songs[curSelected]) text += " (" + curSong.variant.toUpperCase() + ")";
	}
	diffText.text = curDifficulties.length > 1 ? "< " + text + " >" : text;
}

function updateScore() {
	if (curDifficulties.length == 0) {
		intendedScore = 0;
		return;
	}
	updateCoopModes();

	// HighscoreChange is a plain (non-abstract) enum, so its constructors are made through Type.
	var changeEnum = Type.resolveEnum("funkin.savedata.HighscoreChange");
	var changes:Array<Dynamic> = [];
	if (__coopMode) changes.push(Type.createEnum(changeEnum, "CCoopMode"));
	if (__opponentMode) changes.push(Type.createEnum(changeEnum, "COpponentMode"));
	var saveData = FunkinSave.getSongHighscore(curSong.name, curDifficulties[curDifficulty], curSong.variant, changes);
	intendedScore = saveData.score;
}

function changeCoopMode(change:Int = 0, force:Bool = false) {
	if (change == 0 && !force) return;
	if (!curSong.coopAllowed && !curSong.opponentModeAllowed) return;

	var bothEnabled = curSong.coopAllowed && curSong.opponentModeAllowed;
	var evt = event("onChangeCoopMode", EventManager.get(MenuChangeEvent).recycle(curCoopMode, FlxMath.wrap(curCoopMode + change, 0, bothEnabled ? 3 : 1), change));

	if (evt.cancelled) return;

	curCoopMode = evt.value;

	updateScore();

	var coopBinds = [];
	var bindStrings = [CoolUtil.keyToString(Options.P1_CHANGE_MODE[0]), CoolUtil.keyToString(Options.P2_CHANGE_MODE[0])];
	for (b in bindStrings) if (b != "---") coopBinds.push(b);
	if (coopBinds.length == 2 && coopBinds[1] == coopBinds[0]) coopBinds.pop();
	else if (coopBinds.length == 0) coopBinds.push("---");

	var key = "[" + coopBinds.join(" / ") + "] ";

	if (bothEnabled) {
		coopText.text = key + coopLabels[curCoopMode];
	} else {
		coopText.text = key + coopLabels[curCoopMode * (curSong.coopAllowed ? 2 : 1)];
	}
}

function changeSelection(change:Int = 0, force:Bool = false) {
	if (change == 0 && !force) return;

	var evt = event("onChangeSelection", EventManager.get(MenuChangeEvent).recycle(curSelected, FlxMath.wrap(curSelected + change, 0, songs.length - 1), change));
	if (evt.cancelled) return;

	curSelected = evt.value;
	if (evt.playMenuSFX) CoolUtil.playMenuSFX(CoolSfx.SCROLL, 0.7);

	var prevDiff = curDifficulties[curDifficulty];
	var prevVariant = curDiffMetaKeys[curDifficulty];
	updateCurDifficulties();

	for (i => diff in curDifficulties) {
		if (diff == prevDiff && curDiffMetaKeys[i] == prevVariant) {
			curDifficulty = i;
			break;
		}
	}

	changeDiff(0, true);

	coopText.visible = curSong.coopAllowed || curSong.opponentModeAllowed;
}

function updateOptionsAlpha() {
	var evt = event("onUpdateOptionsAlpha", EventManager.get(FreeplayAlphaUpdateEvent).recycle(0.6, 0.45, 1, 1, 0.25));
	if (evt.cancelled) return;

	var idleAlpha = evt.idleAlpha;
	var selectedAlpha = evt.selectedAlpha;

	for (i in 0...iconArray.length)
		iconArray[i].alpha = lerp(iconArray[i].alpha, idleAlpha, evt.lerp);

	iconArray[curSelected].alpha = selectedAlpha;

	for (i => item in grpSongs.members) {
		item.targetY = i - curSelected;

		item.alpha = lerp(item.alpha, idleAlpha, evt.lerp);

		if (item.targetY == 0)
			item.alpha = selectedAlpha;
	}
}

function updateCurDifficulties() {
	curDiffMetaKeys = [];
	curDifficulties = songs[curSelected].difficulties.copy();
	for (i in 0...curDifficulties.length) curDiffMetaKeys.push(null);

	if (songs[curSelected].variants != null) {
		for (variant in songs[curSelected].variants) {
			var meta = songs[curSelected].metas.get(variant);
			if (meta != null) {
				curDifficulties = curDifficulties.concat(meta.difficulties);
				for (i in 0...meta.difficulties.length) curDiffMetaKeys.push(variant);
			}
		}
	}
}

function updateCurSong() {
	var song = songs[curSelected];
	if (song == null) {
		curSong = null;
	} else {
		curSong = song.metas.get(curDiffMetaKeys[curDifficulty]);
		if (curSong == null) curSong = song;
	}
}

// ------------------------------------------------------------ song list (was FreeplaySonglist)
// Source values are AssetSource's ints: 0 = SOURCE, 1 = MODS.

var EXCLUDE_SUBFOLDERS = ['charts', 'scripts', 'song'];

function isSubSongDirectory(subs) {
	for (i in EXCLUDE_SUBFOLDERS) {
		if (subs.indexOf(i) != -1) return false;
	}
	return true;
}

function collectSongDirs(dirs, startDir, source, songsFound) {
	for (i in dirs) {
		var subs = Paths.getFolderDirectories(startDir + i, false, source);
		if (isSubSongDirectory(subs)) collectSongDirs(subs, startDir + i + "/", source, songsFound);
		else songsFound.push(startDir.substr('songs/'.length) + i);
	}
}

// Returns true if nothing was found in this source (so the caller can fall back to the next).
function getSongsFromSource(outSongs, source, useTxt, startDir, flatten) {
	var songsFound = null;
	if (useTxt) {
		var oldPath = Paths.txt('freeplaySonglist');
		var newPath = Paths.txt('config/freeplaySonglist');
		if (Paths.assetsTree.existsSpecific(newPath, "TEXT", source)) songsFound = CoolUtil.coolTextFile(newPath);
		else if (Paths.assetsTree.existsSpecific(oldPath, "TEXT", source)) {
			Logs.warn("data/freeplaySonglist.txt is deprecated and will be removed in the future. Please move the file to data/config/");
			songsFound = CoolUtil.coolTextFile(oldPath);
		}
	}

	if (songsFound == null) {
		songsFound = [];
		var songDirs = Paths.getFolderDirectories(startDir, false, source);
		if (!flatten) {
			for (i in songDirs) {
				var subs = Paths.getFolderDirectories(startDir + i, false, source);
				songsFound.push(isSubSongDirectory(subs) ? i + "/" : i);
			}
		} else {
			collectSongDirs(songDirs, startDir, source, songsFound);
		}
		// put folders at the top
		var folders = [];
		var files = [];
		for (a in songsFound) {
			if (StringTools.endsWith(a, "/")) folders.push(a);
			else files.push(a);
		}
		songsFound = folders.concat(files);
	}

	if (songsFound.length > 0) {
		for (s in songsFound)
			outSongs.push(Chart.loadChartMeta(startDir.substr('songs/'.length) + s, null, null, source == 1));
		return false;
	}
	return true;
}

function loadSongList(useTxt, startDir, flatten) {
	var out = [];

	switch (Flags.SONGS_LIST_MOD_MODE) {
		case 'prepend':
			getSongsFromSource(out, 1, useTxt, startDir, flatten);
			getSongsFromSource(out, 0, useTxt, startDir, flatten);
		case 'append':
			getSongsFromSource(out, 0, useTxt, startDir, flatten);
			getSongsFromSource(out, 1, useTxt, startDir, flatten);
		default: // case 'override'
			if (getSongsFromSource(out, 1, useTxt, startDir, flatten))
				getSongsFromSource(out, 0, useTxt, startDir, flatten);
	}

	return out;
}
