// Original Script by John Ezax, Edited by N1ckolasN4me
import haxe.Json;
import sys.io.File;
import sys.FileSystem;
import flixel.text.FlxTextBorderStyle;
import funkin.backend.assets.GamesFolder;

var creditBG:FlxSprite;
var creditText:FlxText;
var camHUD:FlxCamera;

function create() {
    graphicCache.cache(Paths.image("game/box"));

    camHUD = new FlxCamera(0, 0, 1280, 720);
    FlxG.cameras.add(camHUD, false);
    camHUD.bgColor = FlxColor.TRANSPARENT;
}

// ─────────────────────────────────────────────
//  Resolve the credits.json path for a song.
//  Checks standard mod path first, then every
//  DLC subfolder:
//    mods/<modDirectory>/dlc/<dlcName>/songs/<songName>/credits.json
//  Returns null if nothing is found.
// ─────────────────────────────────────────────
function findCreditsPath(songName:String):String
{
    var modBase:String = "games/" + GamesFolder.currentModFolder;

    // 1. Standard location
    var standard:String = modBase + "/songs/" + songName + "/credits.json";
    if (FileSystem.exists(standard)) return standard;

    // 2. Any DLC subfolder
    var dlcRoot:String = modBase + "/dlc/";
    if (FileSystem.exists(dlcRoot))
    {
        for (dlcId in FileSystem.readDirectory(dlcRoot))
        {
            if (!FileSystem.isDirectory(dlcRoot + dlcId)) continue;

            var dlcPath:String = dlcRoot + dlcId + "/songs/" + songName + "/credits.json";
            if (FileSystem.exists(dlcPath)) return dlcPath;
        }
    }

    return null;
}

function onSongStart() {
    var cd:Dynamic = null;

    if (PlayState.SONG != null && PlayState.SONG.meta != null) {
        var songName:String = PlayState.SONG.meta.name != null
            ? PlayState.SONG.meta.name
            : (PlayState.SONG.meta.displayName != null ? PlayState.SONG.meta.displayName : "unknown");

        trace("credits.hx: songName = " + songName);

        var creditsPath:String = findCreditsPath(songName);

        trace("credits.hx: resolved credits path = " + Std.string(creditsPath));
        trace("credits.hx: file exists = " + (creditsPath != null));

        if (creditsPath != null) {
            try {
                var rawJson:String = File.getContent(creditsPath);
                trace("credits.hx: raw json = " + rawJson);
                cd = Json.parse(rawJson);
                trace("credits.hx: cd = " + Std.string(cd));
            } catch (e:Dynamic) {
                trace("credits.hx: error reading credits.json -> " + Std.string(e));
            }
        }
    } else {
        trace("credits.hx: PlayState.SONG or meta is null");
    }

    if (cd == null) {
        trace("credits.hx: cd is null, returning early");
        return;
    }

    creditBG = add(new FlxSprite(0, -1200, Paths.image("game/box")));
    creditBG.setGraphicSize(creditBG.height * 0.8);
    creditBG.screenCenter(FlxAxes.X);

    creditText = add(new FlxText(0, -1200, FlxG.width, cd.text));
    creditText.setFormat(Paths.font("sonic-cd-menu-font.ttf"), cd.size, FlxColor.WHITE, "center", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    creditText.screenCenter(FlxAxes.X);

    for (creditFuck in [creditBG, creditText]) {
        creditFuck.camera = camHUD;
        creditFuck.updateHitbox();
        creditFuck.screenCenter(FlxAxes.X);

        var stayTime = cd.endTime;
        var startDelay = cd.time;

        new FlxTimer().start(startDelay, function(timer:FlxTimer) {
            FlxTween.tween(creditFuck, {y: FlxG.height / 2 - creditFuck.height / 2}, 0.5, {
                ease: FlxEase.circIn,
            });
        });

        new FlxTimer().start(startDelay + stayTime, function(timer:FlxTimer) {
            FlxTween.tween(creditFuck, {y: -creditFuck.height}, 0.5, {
                ease: FlxEase.circOut,
                onComplete: function(twn:FlxTween) {
                    remove(creditFuck);
                }
            });
        });
    }
}
