import flixel.tweens.FlxTweenType;

var camEvents:FlxCamera;
var RedVG:FlxSprite;
var pixelBGParts:FlxTypedGroup;
var normalBGParts:Array<Dynamic> = [];
var crtShader:CustomShader;
var screamShader:CustomShader;
var screamActive = false;
var screamPower = 0.0;

function create() {
    camEvents = new FlxCamera();
    camEvents.bgColor = new FlxColor(0x00000000);
    FlxG.cameras.add(camEvents, false);

    pixelBGParts = stage.stageScript.get("pixelBGParts");
    for (name in ["Sky", "Trees", "GrassBack", "Grass", "TopOverlay", "TreesFront"]) {
        var sprite = stage.stageScript.get(name);
        if (sprite != null) normalBGParts.push(sprite);
    }

    RedVG = new FlxSprite().loadGraphic(Paths.image("effects/vgs/vg_red"));
    RedVG.cameras = [camEvents];
    RedVG.alpha = 0;
    add(RedVG);

    FlxTween.tween(RedVG, {alpha: 1}, 0.85, {ease: FlxEase.sineInOut, type: FlxTweenType.PINGPONG});

    if (FlxG.save.data.modShaders) {
        crtShader = new CustomShader("vcrDistort");
        crtShader.noiseOn = false;
        crtShader.scanlinesOn = true;
        crtShader.distortionOn = false;
        crtShader.scandistortOn = false;

        screamShader = new CustomShader("scream");
        screamShader.iTime = 0;
        screamShader.power = 0;
    }

    camHUD.alpha = 0;
}

function postUpdate(elapsed:Float) {
    if (screamActive && screamShader != null) {
        screamShader.iTime = Conductor.songPosition / 1000;
        screamPower = Math.min(0.58, screamPower + elapsed * 2.3);
        screamShader.power = screamPower;
    }

    for (strums in [cpuStrums, playerStrums])
        for (strum in strums.members)
            strum.noteAngle = 0;

    if (curStep >= 784) {
        if (health > maxHealth * 0.8)
            health = Math.max(maxHealth * 0.79, health - elapsed * 0.15);

        var shake = 1.5 + Math.max(0, (health / maxHealth) - 0.5) * 12;
        iconP2.offset.x = FlxG.random.float(-shake, shake);
        iconP2.offset.y = FlxG.random.float(-shake, shake);
    }
}

function stepHit(curStep:Int) {
    var quickSpin:Array<Dynamic> = [];
    
    switch(curStep) {
        case 127, 328, 1288:
            defaultCamZoom = 1.3;

        case 536, 540, 568, 573, 599, 603, 631, 636, 664, 668, 696, 700, 728, 732, 760, 764, 1176, 1180, 1208, 1212, 1240, 1245, 1273, 1277, 1303, 1308, 1336, 1340, 1368, 1372, 1400, 1404:
           quickSpin = [cpuStrums, playerStrums];

        case 129:
            FlxTween.tween(camHUD, {alpha: 1}, 1, {ease: FlxEase.sineInOut});
        case 144, 335, 1295:
            defaultCamZoom = 0.65;
        case 521, 1161:
            camGame.shake(0.04, 0.8);
            camHUD.shake(0.025, 0.8);
            dad.cameraOffset.x = -65;
            dad.cameraOffset.y = -25;
            if (FlxG.save.data.modShaders && screamShader != null) {
                screamPower = 0;
                screamShader.power = 0;
                screamActive = true;
                for (cam in [camGame, camHUD])
                    cam.addShader(screamShader);
            }
        case 528:
            health = maxHealth / 2;
            FlxG.cameras.flash(FlxColor.WHITE, 0.7);
            for (i in pixelBGParts) i.alpha = 1;
            for (item in normalBGParts) item.alpha = 0;
            camEvents.alpha = 0;
            if (FlxG.save.data.modShaders && crtShader != null) {
                for (cam in [camGame, camHUD])
                    cam.addShader(crtShader);
            }
        case 529, 1168:
            if (FlxG.save.data.modShaders && screamShader != null) {
                screamPower = 0;
                screamShader.power = 0;
                screamActive = false;
                dad.cameraOffset.x = 0;
                dad.cameraOffset.y = 0;
                for (cam in [camGame, camHUD])
                    cam.removeShader(screamShader);
            }

        case 784:
            health = maxHealth / 2;
            FlxG.cameras.flash(FlxColor.WHITE, 0.7);
            for (i in pixelBGParts) i.alpha = 0;
            for (item in normalBGParts) item.alpha = 1;
            camEvents.alpha = 1;
            if (FlxG.save.data.modShaders && crtShader != null) {
                for (cam in [camGame, camHUD])
                    cam.removeShader(crtShader);
            }
        case 1456:
            for (cam in [camGame, camHUD, camEvents]) {
                cam.visible = false;
            }
    }

    if (quickSpin.length > 0)
        for (strums in quickSpin)
            for (strum in strums.members) {
                strum.angle = 0;
                FlxTween.tween(strum, {angle: 360}, 0.2, {ease: FlxEase.quintOut});
            }
    }
