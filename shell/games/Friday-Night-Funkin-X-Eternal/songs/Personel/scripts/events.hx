var spinpower:Float = 0;
var spin:Int = 0;

function postCreate() {
    camGame.alpha = 0;

    for (item in [iconP1, iconP2, healthBar, healthBarBG])
        item.alpha = 0;

    for (text in [missesTxt, accuracyTxt, scoreTxt])
        text.visible = false;
}

function stepHit(curStep:Int) {
    switch(curStep) {
        case 32:
            camGame.alpha = 1;

        case 288, 1696:
            FlxTween.cancelTweensOf(camGame, ["angle"]);
            camGame.angle = 0;
            FlxTween.tween(camGame, {angle: 360}, 0.8, {ease: FlxEase.cubeInOut, onComplete: (_) -> camGame.angle = 0});

        case 1070, 1088, 1098, 1102, 1134, 1152, 1163, 1166:
            for (strums in [cpuStrums, playerStrums])
                for (strum in strums.members)
                    strum.angle += 35;

            for (char in [dad, boyfriend])
                char.angle += 35;

        case 1200:
            defaultCamZoom = 0.6;
            spinpower = 0;
            spin = 1;

        case 1264:
            spinpower = 0;
            spin = 0;

        case 1312:
            spinpower = 0.35;
            spin = 2;
            defaultCamZoom = 0.7;

        case 1400:
            spin = 0;
            defaultCamZoom = 0.5;
            spinpower = 0;

            spin = 0;

            for (char in [dad, boyfriend]) {
                FlxTween.cancelTweensOf(char, ["angle"]);
                char.angle = 0;
            }

            FlxTween.cancelTweensOf(camGame, ["angle"]);
            camGame.angle = 0;

            for (strums in [cpuStrums, playerStrums])
                for (strum in strums.members)
                    FlxTween.tween(strum, {angle: 0}, 0.5, {ease: FlxEase.circOut});
    }
}

function postUpdate(elapsed:Float) {
    for (strums in [cpuStrums, playerStrums])
        for (strum in strums.members) {
            strum.noteAngle = 0;

            if (spin > 0) {
                strum.angle += spinpower;
                spinpower += 0.0003;
            }
        }

    if (spin > 0) {
        for (char in [dad, boyfriend]) {
            char.angle += spinpower;
            spinpower += 0.00003;
        }

        if (spin == 2)
            camGame.angle += spinpower;
    }
}
