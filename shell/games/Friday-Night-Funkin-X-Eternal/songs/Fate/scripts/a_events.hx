function create() {
        camEvents = new FlxCamera();
    camEvents.bgColor = new FlxColor(0x00000000);
    FlxG.cameras.add(camEvents, false);

    vg_black = new FlxSprite().loadGraphic(Paths.image("effects/vgs/vg_black"));
    vg_black.cameras = [camEvents];
    vg_black.alpha = 0;
    add(vg_black);
}

function stepHit(curStep:Int) {
	switch(curStep){
        case 1984:
            vg_black.alpha = 1;
            manualZoom = true;
            defaultCamZoom = 1.5;
            bf.cameraOffset.x += 150;
        case 2316:
            vg_black.alpha = 0;
            manualZoom = false;
            defaultCamZoom = 0.45;
    }
}