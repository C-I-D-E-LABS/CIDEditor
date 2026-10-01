var bganims:FlxSprite;

function create() {
    bganims = stage.stageScript.get("bganims");
    bganims.animation.play('play');
    bganims.animation.frameIndex = 0;
    bganims.animation.stop();
}

function stepHit(curStep:Int) {
    switch(curStep) {
        case 576:
            bganims.animation.play('play', true);
            defaultCamZoom = 1.2;

        case 588:
            for (i in playerStrums) i.x -= 350;
            for (i in cpuStrums) i.alpha = 0;
            for (i in cpuStrums.notes) i.alpha = 0;

            defaultCamZoom = 0.8;
            for (item in [bganims, boyfriend])
                item.alpha = 0;

        case 860:
            FlxG.camera.flash(FlxColor.WHITE, 0.7);
            for (i in playerStrums) i.x += 350;
            for (i in cpuStrums) i.alpha = 1;
            for (i in cpuStrums.notes) i.alpha = 1;
            defaultCamZoom = 0.5;
            for (item in [bganims, boyfriend])
                item.alpha = 1;
            bganims.animation.frameIndex = 0;
            bganims.animation.stop();
    }
}
