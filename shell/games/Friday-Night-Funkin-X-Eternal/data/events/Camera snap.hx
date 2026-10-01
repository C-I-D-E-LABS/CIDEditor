var skibidi:Bool;
function onEvent(e:EventGameEvent){
    if (e.event.name == "Camera snap" || "Camera_snap" /* mfw discord */){

        if (e.event.params[0] == true) skibidi = true;
        else if (e.event.params[0] == false) skibidi = false;
    }
}

function postUpdate(elapsed)
    if (skibidi)   FlxG.camera.snapToTarget();