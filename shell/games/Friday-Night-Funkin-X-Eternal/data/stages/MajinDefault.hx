var grpBGparts:FlxTypedGroup;

function create() {
    grpBGparts = new FlxTypedGroup();
    insert(0, grpBGparts);

    defaultCamZoom = 0.6;

    dad.y += 20;
    dad.x -= 350;
    // boyfriend.x = dad.x + 900;
    // boyfriend.y = dad.y - 20;

    dad.cameraOffset.y -=50;
    boyfriend.cameraOffset.y = dad.cameraOffset.y;


    dad.scale.set(1, 1);
    boyfriend.scale.set(0.9, 0.9);

    
}
