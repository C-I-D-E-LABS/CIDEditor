var camEvents:FlxCamera;
var RedVG:FlxSprite;
var grpPreyBG:FlxTypedGroup;
var wallBG:FlxTypedGroup;
var leggs:FlxSprite;
var leggsPeelout:FlxSprite;
var floorStarDust:Dynamic;
var deco:Dynamic;
var lamp:Dynamic;

function create() {
    grpPreyBG = stage.stageScript.get("grpPreyBG");
    wallBG = stage.stageScript.get("wallBG");
    leggs = stage.stageScript.get("leggs");
    leggsPeelout = stage.stageScript.get("leggsPeelout");
    floorStarDust = stage.stageScript.get("floorStarDust");
    deco = stage.stageScript.get("deco");
    lamp = stage.stageScript.get("lamp");

    camEvents = new FlxCamera();
    camEvents.bgColor = new FlxColor(0x00000000);
    FlxG.cameras.add(camEvents, false);

    RedVG = new FlxSprite().loadGraphic(Paths.image("effects/vgs/vg_red"));
    RedVG.cameras = [camEvents];
    RedVG.alpha = 0;
    add(RedVG);
}

function stepHit(curStep:Int) {
    switch(curStep) {
        case 246:
            dad.alpha = 1;
            FlxG.sound.play(Paths.sound("cd/startup"), 0.7);
            FlxTween.tween(dad.scale, {x: 1, y: 1}, 2);

        case 496:
            FlxG.sound.play(Paths.sound("cd/prep"), 0.7);
            FlxTween.tween(dad, {x: dad.x - 80}, 1.2, {ease: FlxEase.sineInOut});

        case 512:
            FlxG.camera.flash(FlxColor.WHITE, 0.7);
            FlxG.sound.play(Paths.sound("cd/atk"), 0.7);
            FlxTween.tween(dad, {x: dad.x + 110}, 0.5, {ease: FlxEase.sineInOut});
            FlxTween.tween(bf, {x: bf.x + 30}, 0.5, {ease: FlxEase.sineInOut});
            FlxTween.tween(leggsPeelout, {x: leggsPeelout.x + 30}, 0.5, {ease: FlxEase.sineInOut});
            leggs.visible = false;
            leggsPeelout.visible = true;
            speedModu(false, 100);
            floorStarDust.velocity.x = -800;

        case 1024:
            for (char in [dad, bf])
                char.x -= 30;
            FlxG.camera.flash(FlxColor.WHITE, 0.7);
            wallBG.visible = true;
            speedModu(false, 80, 80);
            floorStarDust.velocity.x = -325;
            deco.velocity.x = -225;
            leggs.visible = true;
            leggsPeelout.visible = false;

        case 1528:
            FlxTween.tween(dad, {x: dad.x - 380}, 2, {ease: FlxEase.sineInOut});

        case 1536:
            leggsPeelout.x -= 30;
            wallBG.visible = false;
            speedModu(false, 100);
            floorStarDust.velocity.x = -500;
            deco.visible = false;
            FlxG.camera.flash(FlxColor.WHITE, 0.7);
            defaultCamZoom = 5.4;
            //lamp.velocity.x = 0;
            FlxTween.tween(camHUD, {alpha: 0}, 0.5);

        case 1545:
            dad.y -= 230;
            dad.cameraOffset.x += 20;
            FlxTween.tween(dad, {x: dad.x + 800}, 2, {ease: FlxEase.sineInOut});

        case 1736:
            FlxG.camera.shake(0.0009, 3.5);
            FlxG.camera.flash(FlxColor.RED, 0.7);
            RedVG.alpha = 1;

        case 1788:
            FlxTween.tween(camHUD, {alpha: 1}, 0.5);
            speedModu(false, 100);
            floorStarDust.velocity.x = -800;
            defaultCamZoom = 3.5;
            leggs.visible = false;
            leggsPeelout.visible = true;

        case 3334:
            FlxTween.tween(dad, {x: dad.x - 800}, 2, {ease: FlxEase.quadInOut});
            for (item in [camHUD, RedVG])
                FlxTween.tween(item, {alpha: 0}, 0.5);
            defaultCamZoom = 6;
            boyfriend.cameraOffset.x -= 60;
            for (spr in grpPreyBG) FlxTween.tween(spr, {alpha: 0}, 2.5);

        case 3364:
            boyfriend.y += 10;
            leggsPeelout.visible = false;
            for (part in [floorStarDust, lamp, deco])
                part.velocity.x = 0;

        case 3392:
            FlxG.camera.shake(0.005, 0.5);

        case 3407:
            for (item in [RedVG, camGame, camHUD])
                item.alpha = 0;
    }
}

function speedModu(plusOrMinus:Bool = false, skySpeed:Int = 30, wallSpeed:Int = 30) {
    var dir = plusOrMinus ? 1 : -1;
    for (spr in grpPreyBG) spr.velocity.x += skySpeed * dir;
    for (spr in wallBG) spr.velocity.x += wallSpeed * dir;
}
