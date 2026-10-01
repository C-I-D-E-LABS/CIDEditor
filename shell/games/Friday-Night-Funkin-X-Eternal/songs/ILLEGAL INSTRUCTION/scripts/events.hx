function stepHit(curStep:Int) {
    switch(curStep) {
        case 128:
            FlxG.camera.flash(0xFFFFFFFF, 1);
        case 512:
            FlxG.camera.flash(0xFFFFFFFF, 1);
            defaultCamZoom = 1.25;
        case 768:
            FlxG.camera.flash(0xFFFFFFFF, 1);
            FlxTween.tween(camGame, {angle: 360}, 0.5, { ease: FlxEase.circOut});
            defaultCamZoom = 1;
        case 1024:      
            FlxG.camera.flash(0xFFFFFFFF, 1);
            defaultCamZoom = 1.25;
            camHUD.downscroll = true;
        case 1536:
            for (cam in [camGame, camHUD])
                FlxTween.tween(cam, {alpha: 0}, 1.5, { ease: FlxEase.circOut});

        case 1568:
            for (cam in [camHUD, camGame])
                cam.alpha = 1;
            FlxG.camera.flash(0xFFFFFFFF, 1);
            defaultCamZoom = 1;
            camHUD.downscroll = false;


    }
}
