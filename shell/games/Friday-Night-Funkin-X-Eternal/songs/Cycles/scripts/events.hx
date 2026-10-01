import openfl.display.BlendMode;

var skyX:FlxSprite;

function create() {
    skyX = stage.stageScript.get("skyX");

    camEvents = new FlxCamera();
    camEvents.bgColor = new FlxColor(0x00000000);
    FlxG.cameras.add(camEvents, false);
    camEvents.fade(0xFF000000, 0.001, false, null, true);
    
    redOV = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF646464);
    redOV.cameras = [camEvents];
    redOV.alpha = 0;
    redOV.blend = BlendMode.SUBTRACT;
    add(redOV);

    camHUD.alpha = 0;

    manualZoom = true;
}

function stepHit(curStep:Int) {
    switch(curStep) {
        case 2:
            camEvents.fade(0xFF000000, 2, true, null, true);
        case 128:
            defaultCamZoom = 0.75;
            FlxTween.tween(camHUD, {alpha: 1}, 2, {ease: FlxEase.quadInOut});
        case 416:
            defaultCamZoom = 0.6;
            boyfriend.cameraOffset.x -= 50;
       
        case 664:
            FlxTween.color(skyX, 1.5, skyX.color, 0x7C800000, {ease: FlxEase.quadInOut});
            FlxTween.tween(redOV, {alpha: 1}, 1.5, {ease: FlxEase.quadInOut});
            manualZoom = false;
        case 1320:
            FlxTween.color(skyX, 1.5, skyX.color, 0xFFFF8800, {ease: FlxEase.quadInOut});
            FlxTween.tween(redOV, {alpha: 0}, 1.5, {ease: FlxEase.quadInOut});
            FlxG.camera.flash(0xFF000000, 1.5, false);
    }
}
