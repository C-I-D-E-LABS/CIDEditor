
var stageEN:Array<Dynamic> = [];
var stageJP:Array<Dynamic> = [];
var stageUS:Array<Dynamic> = [];
var stageDF:Array<Dynamic> = [];

var majinJP:Dynamic;
var majinUS:Dynamic;
var majinEn:Dynamic;
var majinDF:Dynamic;

var bfJP:Dynamic;
var bfUS:Dynamic;
var bfEn:Dynamic;
var bfDF:Dynamic;

introLength = 0;

function create() {
    for (item in [screen, floorD, jTxt, light1, light2]) {
        stageEN.push(item);
        item.visible = false;
    }

    for (item in [jpSky, jpPill1, jpBush, jpFloor, jpPill2, jpBushL, jpBushR]) {
        stageJP.push(item);
        item.visible = false;
    }

    for (item in [usSky, usBushes, usFloor, usMajinsL1, usMajinsL2, usMajinsR1, usMajinsR2, usTrees, usFGMajins1, usFGMajins2]) {
        stageUS.push(item);
        item.visible = false;
    }

    for (item in [dfSky, dfBushBACK, dfBush, dfMajinsL, dfMajinsR, dfBushUP, dfFloor]) {
        stageDF.push(item);
        item.visible = false;
    }
    // stage?.characterPoses['boyfriend']?.camxoffset = -100;
    // stage?.characterPoses['boyfriend']?.camyoffset = 0;

}

function postCreate() {
    // trace(strumLines.members[1].characters.length);

    majinEn = strumLines.members[0].characters[0];
    majinEn.y -= 20;
    bfEn = strumLines.members[1].characters[0];
    bfEn.cameraOffset.x -= 220;
    bfEn.cameraOffset.y -= 80;
    //bfEn.y += 20;

    majinJP = strumLines.members[0].characters[1];
    
    bfJP = strumLines.members[1].characters[1];
    bfJP.y += 20;
    majinJP.setPosition(10, 330);
    
    majinUS = strumLines.members[0].characters[2];
    bfUS = strumLines.members[1].characters[2];
    bfUS.scale.set(0.9, 0.9);
    bfUS.y += 20;

    majinUS.setPosition(280, 410);
    majinUS.cameraOffset.x += 80;

    majinDF = strumLines.members[0].characters[3];
   
    bfDF = strumLines.members[1].characters[3];
    bfDF.cameraOffset.x -= 220;
    bfDF.cameraOffset.y -= 80;
    bfDF.y -= 20;
    //stage(3);
}

public function stage(a:Int = 0, resetHealth:Bool = true) {
    for (grp in [stageEN, stageJP, stageUS, stageDF]) {
        for (obj in grp)
            obj.visible = false;
    }

    for (line in [strumLines.members[0], strumLines.members[1]])
        for (char in line.characters)
            char.visible = false;

    var stages = [stageEN, stageJP, stageUS, stageDF];
    if (stages[a] != null) {
        for (obj in stages[a])
            obj.visible = true;
    }

    var curMajin:Dynamic = strumLines.members[0].characters[a];
    var curBF:Dynamic = strumLines.members[1].characters[a];
    for (char in [curMajin, curBF])
        char.visible = true;

    camGame.zoom = defaultCamZoom = (curMajin.xml.exists("zoomAmt") ? curMajin.xml.get("zoomAmt") : 1);
    snappIt = true;
    iconP2.setIcon(curMajin.getIcon());
    iconP1.setIcon(curBF.getIcon());
    if (Options.colorHealthBar) {
        healthBar.createColoredEmptyBar(curMajin.iconColor ?? (PlayState.opponentMode ? 0xFF66FF33 : 0xFFFF0000));
        healthBar.createColoredFilledBar(curBF.iconColor ?? (PlayState.opponentMode ? 0xFFFF0000 : 0xFF66FF33));
    }
    healthBar.updateBar();
    for (cam in [camHUD, camGame])
        cam.flash(0x3901BB, 0.7);

    if (resetHealth) FlxTween.num(health, 1, 0.6, {ease: FlxEase.cubeOut}, (v) -> {health = v;});
    new FlxTimer().start(0.1, (_) -> {snappIt = false;});
}

var snappIt:Bool = false;
function update(elapsed:Float) {
    if (snappIt) FlxG.camera.snapToTarget();
}
