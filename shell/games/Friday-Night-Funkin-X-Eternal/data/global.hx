// libraries
import funkin.backend.utils.WindowUtils;
import funkin.backend.system.MainState;
import funkin.backend.system.framerate.Framerate;
import lime.graphics.Image;
import funkin.backend.utils.ShaderResizeFix;
import openfl.system.Capabilities;

// variables
var winWidth:Int;
var winHeight:Int;
static var release:Bool = false;
static var windowTitle:String = "Friday Night Funkin': X-Eternal";

function new() {
    // window.borderless = true;
    // window.resizable = false;

    MainState.betaWarningShown = true;
    Framerate.debugMode = 0;
    FlxG.save.bind('X-Eternal', 'X-Eternal');

    if (FlxG.save.data.songsBeaten == null) {
        FlxG.save.data.songsBeaten = 0;
        FlxG.save.flush();
    }

    if (FlxG.save.data.unlockedSongs == null) {
        FlxG.save.data.unlockedSongs = [];
        FlxG.save.flush();
    }

    if (FlxG.save.data.soundtestVideoWatched == null) {
        FlxG.save.data.soundtestVideoWatched = false;
        FlxG.save.flush();
    }

    FlxG.save.data.pussyMode ??= false;
    FlxG.save.data.skipIntro ??= false;
    FlxG.save.data.modShaders ??= true;
    FlxG.save.data.camFlashing ??= true;
    FlxG.save.data.jumpscares ??= true;
    FlxG.save.data.debugOvly ??= false;
}

static function t_steps(step:Float):Float {
    return (Conductor.stepCrochet / 1000) * step;
}

function preStateSwitch() {
    codenameFieldHandler(true);
    WindowUtils.resetTitle();
    window.title = windowTitle;
    window.setIcon(Image.fromBytes(Assets.getBytes(Paths.image('icon'))));
    FlxG.camera.bgColor = 0xFF000000;

    if (Std.isOfType(FlxG.game._requestedState, StoryMenuState) || Std.isOfType(FlxG.game._requestedState, FreeplayState)) {
        var returnTo:String = FlxG.save.data.returnState;
        if (returnTo != null) {
            FlxG.game._requestedState = new GameState(returnTo);
            FlxG.save.data.returnState = null;
            FlxG.save.flush();
        }
    }
 
}

function codenameFieldHandler(mod:Bool = true) {
    switch(mod) {
        case true:
            WindowUtils.winTitle = window.title = windowTitle;
            FlxG.camera.bgColor = 0xFF000000;

            if (release) {
                Framerate.memoryCounter.visible = false;
                Framerate.codenameBuildField.text = "FNF: X-ETERNAL";
            }
            else Framerate.codenameBuildField.text = "FNF: X-ETERNAL - INDEV";
        case false:
            Framerate.codenameBuildField.text = 'Codename Engine ' + Main.releaseCycle + '\nVersion ' + Main.releaseVersion;
    }
}

function destroy() {
    FlxG.camera.bgColor = 0xFF000000;
    windowShit(1280, 720);
}
