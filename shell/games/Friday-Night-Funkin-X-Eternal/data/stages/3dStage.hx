var bganims:FlxSprite;
var tailsdoll:Dynamic;
var tailsdollalt:Dynamic;

function create() {
    defaultCamZoom = 0.5;
    dad.y += 150;
    dad.x += 400;

    boyfriend.y += 140;
    boyfriend.x += 880;

    tailsdoll = strumLines.members[0].characters[0];
    tailsdollalt = strumLines.members[0].characters[1];
    tailsdollalt.visible = false;

    if (bganims != null) {
        bganims.animation.play('play');
        bganims.animation.frameIndex = 0;
        bganims.animation.stop();
    }

    if (FlxG.save.data.modShaders) {
        crtShader2 = new CustomShader("vcrDistort");
        camHUD.addShader(crtShader2);
        crtShader2.scandistortOn = true;

        crtShader = new CustomShader("vcrDistort");
        camGame.addShader(crtShader);
        crtShader.noiseOn = false; // or false to disable
        crtShader.scanlinesOn = true;
    }
}

function stepHit(curStep:Int) {
    switch(curStep) {
        case 588:
            tailsdollalt.visible = true;
            tailsdoll.visible = false;
            curIcon = strumLines.members[0].characters[1];
            iconP2.setIcon(curIcon.getIcon());
        case 860:
            tailsdollalt.visible = false;
            tailsdoll.visible = true;
            curIcon = strumLines.members[0].characters[0];
            iconP2.setIcon(curIcon.getIcon());
    }
}
