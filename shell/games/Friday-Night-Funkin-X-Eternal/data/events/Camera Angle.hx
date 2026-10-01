function onEvent(e) {
    if (e.event.name != "Camera Angle") return;

    var cam:FlxCamera = Reflect.field(this, e.event.params[2]);
    var name = (e.event.params[2] == "camHUD" ? "camHUD" : "camGame") + ".angle";

    var tween = eventsTween.get(name);
    if (tween != null) tween.cancel();

    var finalAngle:Float = e.event.params[1];
    if (e.event.params[7] == true) finalAngle *= cam.angle;

    if (e.event.params[0] == false) cam.angle = finalAngle;
    else eventsTween.set(name, FlxTween.tween(cam, {angle: finalAngle}, (Conductor.stepCrochet * 0.001) * e.event.params[3], {ease: CoolUtil.flxeaseFromString(e.event.params[4], e.event.params[5])}));
}