//
import flixel.FlxObject;
import flixel.FlxObject.FlxCameraFollowStyle;

public var camBetterFollow:FlxObject;
public var camBetterFollowLerp:Float = 0.1;
public var preventCameraMovement:Bool = false;

function postCreate() {
    camBetterFollow = new FlxObject(camFollow.x, camFollow.y, 2, 2);
    FlxG.camera.follow(camBetterFollow, FlxCameraFollowStyle.LOCKON, 0.04);
}
public var cameraDisplacement:Float = 50;//Change This
public function getDisplacement(char:Character, ?amount:Float = null) {
    var d = [0, 0];
    var amt = amount == null ? cameraDisplacement : amount;

    switch char.getAnimName() {
        case "singLEFT":    d[0] -= amt;
        case "singDOWN":    d[1] += amt;
        case "singUP":      d[1] -= amt;
        case "singRIGHT":   d[0] += amt;

        case "singLEFT-alt":    d[0] -= amt;
        case "singDOWN-alt":    d[1] += amt;
        case "singUP-alt":      d[1] -= amt;
        case "singRIGHT-alt":   d[0] += amt;
    }

    return d;
}

function onCameraMove(e) {
    if (preventCameraMovement || curCameraTarget < 0 || strumLines.members[curCameraTarget] == null || strumLines.members[curCameraTarget].characters[0] == null) {
        e.cancel();
        return;
    }

    var displacement = getDisplacement(strumLines.members[curCameraTarget].characters[0]);
    e.position.x += displacement[0];
    e.position.y += displacement[1];

    camBetterFollow.x = FlxMath.lerp(camBetterFollow.x, camFollow.x, camBetterFollowLerp);
    camBetterFollow.y = FlxMath.lerp(camBetterFollow.y, camFollow.y, camBetterFollowLerp);
}
