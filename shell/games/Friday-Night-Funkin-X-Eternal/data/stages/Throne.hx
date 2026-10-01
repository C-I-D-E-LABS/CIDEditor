import flixel.tweens.FlxTweenType;
function create() {
    FlxTween.tween(torch, {y: torch.y - 75}, 1.3, {ease: FlxEase.sineInOut, type: FlxTweenType.PINGPONG});
    FlxTween.tween(torch2, {y: torch2.y - 75}, 1.3, {ease: FlxEase.sineInOut, type: FlxTweenType.PINGPONG, startDelay: 0.25});
    boyfriend_16 = strumLines.members[1].characters[1];

    for(i in [fire, darkness, floorpix]) i.visible = false;

}

function stepHit(curStep:Int) {
    switch (curStep) {
        case 621:
            for(i in [fire, darkness, floorpix]) i.visible = true;
        case 877:
            camHUD.flash(0xFF75F1FF, 0.5);
            FlxTween.tween(fire, {y: fire.y - 150}, 4, {ease: FlxEase.sineInOut});
        case 1165:
             for(i in [throne, torch, torch2, fire, bg, darkness, floorpix, boyfriend_16]) i.visible = false;
    }
}