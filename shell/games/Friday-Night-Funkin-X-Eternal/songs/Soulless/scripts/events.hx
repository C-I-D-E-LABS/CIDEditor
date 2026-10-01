var mechanic = false;

function beatHit(curBeat:Int) {
    if (curBeat % 4 == 0 && mechanic) {
        FlxTween.tween(PlayState.instance, {scrollSpeed: PlayState.instance.scrollSpeed - 0.9}, 0.7, {type: FlxTween.PINGPONG, ease: FlxEase.quadInOut});
    } else if (!mechanic) {
        FlxTween.cancelTweensOf(PlayState.instance);
    }
}

function stepHit(curStep:Int) {
    switch(curStep) {
        case 544, 1328:
            mechanic = true;
            camHUD.flash(0xFFB60000, 0.5, false);
        case 800, 1584:
            mechanic = false;
            camHUD.flash(0xFFB60000, 0.5, false);
        case 2096:
            FlxTween.tween(camHUD, {alpha: 0}, 1.5, {ease: FlxEase.quadInOut});
        case 2112:
            for (cam in [camGame, camHUD]) {
                cam.alpha = 1;
                cam.fade(0xFF000000, 1.5, false, null, true);
            }
    }
}
var baseWindowX:Float = 320;
var baseWindowY:Float = 180;

var hoverTime:Float = 0.0;

// Tweak these to taste
var hoverAmplitudeX:Float = 0;   // pixels of horizontal drift
var hoverAmplitudeY:Float = 6;   // pixels of vertical drift
var hoverSpeedX:Float = 0.35;    // cycles per second
var hoverSpeedY:Float = 0.5;     // deliberately different from X — keeps it from looping in a clean circle

function postCreate() {

    window.x = Std.int(baseWindowX);
    window.y = Std.int(baseWindowY);
}


function postUpdate(elapsed) {
    hoverTime += elapsed;

    var offsetX = Math.sin(hoverTime * hoverSpeedX * Math.PI * 2) * hoverAmplitudeX;
    var offsetY = Math.cos(hoverTime * hoverSpeedY * Math.PI * 2) * hoverAmplitudeY;

    window.move(Std.int(baseWindowX + offsetX), Std.int(baseWindowY + offsetY));
}
