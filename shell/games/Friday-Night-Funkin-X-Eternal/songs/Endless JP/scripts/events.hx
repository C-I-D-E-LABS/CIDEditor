import flixel.util.FlxStringUtil;
import flixel.text.FlxTextBorderStyle;

var noteSkinChange:Bool = false;
var beatZoom:Bool = false;
var fastBeatZoom:Bool = false;
var workText:Dynamic;

function onNoteHit(e) {
    if (noteSkinChange)
        e.note.splash = "endlessNoteSplashes";
}

function create() {
    graphicCache.cache(Paths.image("game/notes/Majin_assets"));

    camOther = new FlxCamera();
    camOther.bgColor = 0;
    FlxG.cameras.add(camOther, false);
}

function postCreate() {
    workText = new FunkinText(0, 0, FlxG.width, '', 85, true);
    workText.borderSize = 5;
    workText.alignment = 'center';
    workText.font = Paths.font('sonic-cd-menu-font.ttf');
    workText.cameras = [camOther];
    workText.screenCenter();
    workText.antialiasing = true;
    add(workText);
}

function stepHit(curStep) {
    switch(curStep) {
        case 128, 134, 140, 256, 262, 268, 640, 646, 652, 768, 774, 780, 1280, 1286, 1292, 1536, 1542, 1548, 1664, 1670, 1676, 1792, 1798, 1804, 1920, 1926, 1932, 2112, 2118, 2124, 2240, 2246, 2252:
            defaultCamZoom += 0.2;
        case 148, 660, 1300, 1556, 1680, 1808, 1936, 2132, 2256:
            defaultCamZoom -= 0.6;
        case 270, 788:
            beatZoom = true;
            fastBeatZoom = false;
            defaultCamZoom -= 0.6;
        case 528, 1424:
            fastBeatZoom = true;
            beatZoom = false;
        case 2000:
            beatZoom = false;
            fastBeatZoom = false;
        case 896:
            FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom + 0.3}, 1, {ease: FlxEase.cubeInOut});
            camHUD.flash(FlxColor.BLUE, 0.7);

            for (line in strumLines) {
                for (strum in line) {
                    updateStrumSkin(strum, "game/notes/Majin_assets", strum.ID);
                    strum.y = line.startingPos.y;
                }
                for (note in line.notes)
                    updateNoteSkin(note, "game/notes/Majin_assets");
            }
            noteSkinChange = true;
        case 912:
            camHUD.alpha = 1;
            beatZoom = false;
            fastBeatZoom = false;
    }
}

function updateStrumSkin(newshit:Strum, newSkin:String, id:Int) {
    newshit.frames = Paths.getSparrowAtlas(newSkin);

    newshit.animation.addByPrefix('green', 'arrowUP');
    newshit.animation.addByPrefix('blue', 'arrowDOWN');
    newshit.animation.addByPrefix('purple', 'arrowLEFT');
    newshit.animation.addByPrefix('red', 'arrowRIGHT');

    newshit.setGraphicSize(Std.int(newshit.width * 0.7));

    newshit.animation.addByPrefix('static', 'arrow' + ["left", "down", "up", "right"][id].toUpperCase());
    newshit.animation.addByPrefix('pressed', ["left", "down", "up", "right"][id] + ' press', 24, false);
    newshit.animation.addByPrefix('confirm', ["left", "down", "up", "right"][id] + ' confirm', 24, false);

    newshit.animation.play('static');
    newshit.updateHitbox();

}

function updateNoteSkin(note:Note, newSkin:String) {
    var animName = note.animation.name;
    note.frames = Paths.getSparrowAtlas(newSkin);

    note.animation.addByPrefix(animName, switch(animName) {
        case 'scroll': ['purple', 'blue', 'green', 'red'][note.strumID % 4] + '0';
        case 'hold': ['purple hold piece', 'blue hold piece', 'green hold piece', 'red hold piece'][note.strumID % 4];
        case 'holdend': ['pruple end hold', 'blue hold end', 'green hold end', 'red hold end'][note.strumID % 4] + '0';
    });

    note.animation.play(animName);
    note.updateHitbox();
}

function workThat() {
    workText.text = "WORK";
    new FlxTimer().start(0.2, function(tmr:FlxTimer) {
        workText.text = "WORK THAT";
    });
    new FlxTimer().start(0.4, function(tmr:FlxTimer) {
        workText.text = "WORK THAT SUCKER";
    });
    new FlxTimer().start(0.6, function(tmr:FlxTimer) {
        workText.text = "TO DEATH!";
    });
    new FlxTimer().start(0.9, function(tmr:FlxTimer) {
        workText.text = "COME ON NOW!";
        FlxTween.tween(workText, {alpha: 0}, 0.8, {ease: FlxEase.cubeOut});
    });
}


function beatHit() {
	if (fastBeatZoom || (beatZoom && curBeat % 2 == 0)) {
		FlxG.camera.zoom += 0.06;
		camHUD.zoom += 0.08;
	}
}
