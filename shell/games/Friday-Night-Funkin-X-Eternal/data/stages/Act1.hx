//
public var unlockedStoryMenu:Bool = false;
var grpBGparts:FlxTypedGroup;

function create() {
    FlxG.camera.bgColor = 0xFF860000;
    defaultCamZoom = 0.9;
    boyfriend.cameraOffset.y += 25;

}


function stepHit(curStep:Int) {
    switch(curStep) {
        case 286:
            FlxTween.tween(camHUD, {alpha: 0}, 1.2);

        case 297:
            defaultCamZoom = 1.6;
            FlxG.camera.flash(FlxColor.RED, 0.8);
            wave(true, "y", 10);
            dad.cameraOffset.x -= 50;


        case 329:
            FlxTween.tween(camHUD, {alpha: 1}, 0.5);
            defaultCamZoom = 0.5;
            dad.cameraOffset.x +=50;

        case 585:
            defaultCamZoom = 1.2;
        case 710:
            wave(false);
        case 713:
            defaultCamZoom = 0.5;
          wave(true, "x", 10);
             
        case 840:
            //defaultCamZoom = 1.1;
            FlxTween.tween(camHUD, {alpha: 0}, 1.2);


        case 969:
            defaultCamZoom = 0.5;
            FlxTween.tween(camHUD, {alpha: 1}, 1.2);
        case 1224, 1240, 1289, 1305, 1476:
            defaultCamZoom = 1.1;
        case 1232, 1248, 1296, 1313:
            defaultCamZoom = 0.5;
        case 1481:
            FlxG.camera.shake(0.0075, 3);
            defaultCamZoom = 0.5;

    }
}

var waveTweens:Array<FlxTween> = [];
function wave(toggle:Bool, axis:String = "y", offset:Float = 10)
{
    var groups = [cpu, player];

    if (toggle)
    {
        waveTweens = waveTweens.filter(t -> t != null && t.active);
        if (waveTweens.length > 0) return;
        if (cpu == null || player == null) return;

        for (group in groups)
        {
            for (i in 0...4)
            {
                var strum = group.members[i];
                if (strum == null) continue;

                var target:Dynamic = switch (axis)
                {
                    case "x": { x: strum.x + offset };
                    case "y": { y: strum.y + offset };
                    default:  { y: strum.y + offset };
                };

                waveTweens.push(
                    FlxTween.tween(strum, target, 1, {
                        type: FlxTween.PINGPONG,
                        ease: FlxEase.quadInOut,
                        startDelay: 0.25 * i
                    })
                );
            }
        }
    }
    else
    {
        for (t in waveTweens)
            if (t != null) t.cancel();
        waveTweens.resize(0);
    }
}