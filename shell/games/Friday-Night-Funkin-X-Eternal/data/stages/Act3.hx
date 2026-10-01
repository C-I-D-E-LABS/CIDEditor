// TIPLE TUBLE STAGE!!
import flixel.addons.display.FlxBackdrop;

var grpBGparts:FlxTypedGroup;


var xenoSky:Dynamic;
var skyTT:Dynamic;
var backTreesTT:Dynamic;
var grassAngleTT:Dynamic;
var grassFlatTT:Dynamic;
var frontTreesTT:Dynamic;

var backTreesXTT:Dynamic;
var grassAngleXTT:Dynamic;
var grassFlatXTT:Dynamic;
var frontTreesXTT:Dynamic;
var crystalsXTT:Dynamic;

function create() {
    soulTails = strumLines.members[0].characters[0];
    xenP3Left = strumLines.members[0].characters[1];
    soulKnux = strumLines.members[0].characters[2];
    xenP3Right = strumLines.members[0].characters[3];
    soulEggman = strumLines.members[0].characters[4];
    xenP3Left2 = strumLines.members[0].characters[5];

    xenP3Right.setPosition(1600, 400);
    soulEggman.setPosition(700, 550);
    xenP3Left2.setPosition(1100, 400);

    soulTails.visible = true;
    for (char in [soulKnux, soulEggman, xenP3Left, xenP3Right, xenP3Left2])
        char.visible = false;

    xenP3Left.x += 750;
    xenP3Left.y += 325;
    soulKnux.x += 850;
    soulKnux.y += 360;

    dad.x += 700;
    dad.y += 450;
    boyfriend.x += 950;
    boyfriend.y += 500;

    grpBGparts = new FlxTypedGroup();
    insert(0, grpBGparts);

    xenoSky = new FlxBackdrop(null, FlxAxes.XY, 0, 0);
    xenoSky.frames = Paths.getSparrowAtlas('exe/tt-stage/x/Static');
    xenoSky.animation.addByPrefix('skyAnim', 'Static', 12, true);
    xenoSky.animation.play('skyAnim');
    xenoSky.alpha = 0;
    xenoSky.updateHitbox();
    grpBGparts.add(xenoSky);

    setStageVariant(false);
    crystalsXTT.visible = false;
}

function stepHit(curStep:Int) {
    switch(curStep) {
        case 1040:
            setStagePart(1);

        case 1296:
            setStagePart(2);

        case 2320:
            setStagePart(3);

        case 2832:
            setStagePart(4);

        case 4112:
            setStagePart(5);
    }
}

function setStageVariant(useXStage:Bool) {
    xenoSky.alpha = useXStage ? 1 : 0;
    skyTT.alpha = useXStage ? 0 : 1;

    for (part in [backTreesTT, grassAngleTT, grassFlatTT, frontTreesTT])
        part.visible = !useXStage;

    for (part in [backTreesXTT, grassAngleXTT, grassFlatXTT, frontTreesXTT])
        part.visible = useXStage;
}

function setStagePart(curChar:Int) {
    for (char in [soulTails, soulKnux, soulEggman, xenP3Left, xenP3Right, xenP3Left2])
        char.visible = false;

    crystalsXTT.visible = curChar == 1 || curChar == 3 || curChar == 5;
    crystalsXTT.alpha = crystalsXTT.visible ? 0.6 : 0;

    switch(curChar) {
        case 1:
            xenP3Left.visible = true;
            for (part in [xenoSky, backTreesXTT, grassAngleXTT, grassFlatXTT, frontTreesXTT, crystalsXTT])
                part.flipX = false;
            frontTreesXTT.x = 0;
            setStageVariant(true);

        case 2:
            soulKnux.visible = true;
            setStageVariant(false);

        case 3:
            xenP3Right.visible = true;
            for (part in [xenoSky, backTreesXTT, grassAngleXTT, grassFlatXTT, frontTreesXTT, crystalsXTT])
                part.flipX = true;
            frontTreesXTT.x = -225;
            setStageVariant(true);

        case 4:
            soulEggman.visible = true;
            for (part in [xenoSky, backTreesXTT, grassAngleXTT, grassFlatXTT, frontTreesXTT, crystalsXTT])
                part.flipX = false;
            frontTreesXTT.x = 0;
            boyfriend.x += 200;
            setStageVariant(false);

        case 5:
            xenP3Left2.visible = true;
            for (part in [xenoSky, backTreesXTT, grassAngleXTT, grassFlatXTT, frontTreesXTT, crystalsXTT])
                part.flipX = false;
            frontTreesXTT.x = 0;
            setStageVariant(true);
    }
}
var flipCounter:Int = 0;

function update(elapsed:Float) {
    flipCounter++;
    if (flipCounter % 6 == 0) // every 4th frame — tweak to taste
        skyTT.flipY = !skyTT.flipY;
        skyTT.flipX = !skyTT.flipX;
}