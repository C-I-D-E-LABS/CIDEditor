var camEvents:FlxCamera;
var camExt:FlxCamera;
var daP3Static:FlxSprite;
var xenP3Left2:Dynamic;
var iconswapshit:Bool = false;
var cpuStrumX = [];
var playerStrumX = [];

function create() {
    for (asset in ["effects/jumps/tails", "effects/jumps/xeno", "effects/jumps/knuckles", "effects/jumps/eggman"])
        graphicCache.cache(Paths.image(asset));
    for (sound in ["souls/tails", "souls/xeno", "souls/knuckles", "souls/eggman"])
        FlxG.sound.cache(Paths.sound(sound));

    camEvents = new FlxCamera();
    camEvents.bgColor = new FlxColor(0x00000000);
    FlxG.cameras.add(camEvents, false);

    camExt = new FlxCamera();
    camExt.bgColor = new FlxColor(0x00000000);
    FlxG.cameras.add(camExt, false);

    xenP3Left2 = stage.stageScript.get("xenP3Left2");

    camGame.alpha = 1;
    camGame.fade(0xFF000000, 0.001, false, null, true);
    camHUD.alpha = 1;
    tipleTubleStatic();
}

function postCreate() {
    FlxG.save.data.cameFromStoryMenu = true;

    for (strum in cpuStrums.members)
        cpuStrumX.push(strum.x);
    for (strum in playerStrums.members)
        playerStrumX.push(strum.x);

    updateIconPositions = () -> {
        var iconOffset = 26;
        var healthPercent = healthBar.percent / 100;
        var center = healthBar.x + healthBar.width * FlxMath.remapToRange(healthBar.percent, 0, 100, 1, 0);
        var iconY = downscroll ? FlxG.height - healthBar.y - healthBar.height : healthBar.y;

        if (iconswapshit) {
            center = healthBar.x + healthBar.width * healthPercent;
            iconP1.x = center - (iconP1.width - iconOffset);
            iconP2.x = center - iconOffset;
        } else {
            iconP1.x = center - iconOffset;
            iconP2.x = center - (iconP2.width - iconOffset);
        }

        iconP1.y = iconY - (iconP1.height / 2);
        iconP2.y = iconY - (iconP2.height / 2);
        iconP1.health = healthPercent;
        iconP2.health = 1 - healthPercent;
        iconP1.flipX = iconP2.flipX = iconswapshit;
    };
}

function onSongStart() {
    FlxG.camera.zoom = 5;
    FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2, {ease: FlxEase.quadInOut});
    camGame.fade(0xFF000000, 2, true, null, true);
    camHUD.alpha = 1;
}

function stepHit(curStep:Int) {
    var curIcon:Dynamic = null;
    var hudSwap:Dynamic = null;
    var spinStrums = false;

    switch(curStep) {
        case 80, 96, 112, 128, 140:
            defaultCamZoom += 0.2;
        case 152, 216, 280, 344, 536, 600, 664, 728, 920, 984, 1176, 1240, 1432, 1496, 1560, 1624, 1816, 1880, 1944, 2008, 2072, 2136, 2200, 2264, 2584, 2648, 2712, 2776, 2968, 3032, 3096, 3160, 3224, 3288, 3352, 3416, 3480, 3544, 3608, 3672, 3736, 3800, 3864, 3928, 4120, 4184, 4248, 4312, 4376, 4440, 4504, 4568, 4632, 4696, 4760, 4824, 4888, 4952, 5016, 5080:
            spinStrums = true;
        case 144:
            defaultCamZoom = 0.75;
            characterJump('tails');

        case 400:
            defaultCamZoom = 0.75;
        case 416:
            defaultCamZoom = 0.80;
        case 432:
            defaultCamZoom = 0.85;
        case 448:
            defaultCamZoom = 0.9;
        case 464:
            defaultCamZoom = 0.95;
        case 480:
            defaultCamZoom = 1;
        case 496:
            defaultCamZoom = 1.05;
        case 512:
            defaultCamZoom = 1.1;
        case 528:
            defaultCamZoom = 0.7;

        case 1032:
            defaultCamZoom = 1;

        case 1152:
            defaultCamZoom = 1.1;

        case 1168:
            defaultCamZoom = 0.7;

        case 1680:
            defaultCamZoom = 0.9;

        case 1920:
            defaultCamZoom = 1.1;
        case 1924:
            defaultCamZoom = 1.3;
        case 1928:
            defaultCamZoom = 1.5;
        case 1932:
            defaultCamZoom = 1.7;
        case 1936:
            defaultCamZoom = 0.7;

        case 2312:
            defaultCamZoom = 1.1;

        case 3216:
            defaultCamZoom = 0.8;

        case 3472:
            defaultCamZoom = 0.7;

        case 4104:
            defaultCamZoom = 1.1;

        case 4232:
            defaultCamZoom = 1.1;

        case 4240:
            defaultCamZoom = 0.7;

        case 1025, 1088, 1216, 1280, 2304, 2816, 2944, 3200, 3456, 4096, 4608, 5152:
            tipleTubleStatic();

        case 1040:
            defaultCamZoom = 0.7;
            characterJump('xeno');
            cpuStrumFade(true);
            curIcon = strumLines.members[0].characters[1];
            iconP2.setIcon(curIcon.getIcon());
            if (Options.colorHealthBar) healthBar.createColoredEmptyBar(curIcon.iconColor ?? (PlayState.opponentMode ? 0xFF66FF33 : 0xFFFF0000));
            healthBar.updateBar();
            for (i in 0...cpuStrums.members.length) FlxTween.tween(cpuStrums.members[i], {x: cpuStrumX[i] + 320}, 1);
            for (i in 0...playerStrums.members.length) FlxTween.tween(playerStrums.members[i], {x: playerStrumX[i] - 320}, 1);

        case 1296:
            characterJump('knuckles');
            cpuStrumFade(false);
            hudSwap = true;
            curIcon = strumLines.members[0].characters[2];
            iconP2.setIcon(curIcon.getIcon());
            if (Options.colorHealthBar) healthBar.createColoredEmptyBar(curIcon.iconColor ?? (PlayState.opponentMode ? 0xFF66FF33 : 0xFFFF0000));
            healthBar.updateBar();
            for (i in 0...cpuStrums.members.length) FlxTween.tween(cpuStrums.members[i], {x: cpuStrumX[i] + 640}, 1);
            for (i in 0...playerStrums.members.length) FlxTween.tween(playerStrums.members[i], {x: playerStrumX[i] - 640}, 1);
            defaultCamZoom = 0.7;

        case 2320:
            defaultCamZoom = 0.7;
            characterJump('xeno');
            cpuStrumFade(true);
            curIcon = strumLines.members[0].characters[3];
            iconP2.setIcon(curIcon.getIcon());
            if (Options.colorHealthBar) healthBar.createColoredEmptyBar(curIcon.iconColor ?? (PlayState.opponentMode ? 0xFF66FF33 : 0xFFFF0000));
            healthBar.updateBar();
            for (i in 0...cpuStrums.members.length) FlxTween.tween(cpuStrums.members[i], {x: cpuStrumX[i] + 320}, 1);
            for (i in 0...playerStrums.members.length) FlxTween.tween(playerStrums.members[i], {x: playerStrumX[i] - 320}, 1);

        case 2832:
            characterJump('eggman');
            cpuStrumFade(false);
            hudSwap = false;
            curIcon = strumLines.members[0].characters[4];
            iconP2.setIcon(curIcon.getIcon());
            if (Options.colorHealthBar) healthBar.createColoredEmptyBar(curIcon.iconColor ?? (PlayState.opponentMode ? 0xFF66FF33 : 0xFFFF0000));
            healthBar.updateBar();
            for (i in 0...cpuStrums.members.length) FlxTween.tween(cpuStrums.members[i], {x: cpuStrumX[i]}, 1);
            for (i in 0...playerStrums.members.length) FlxTween.tween(playerStrums.members[i], {x: playerStrumX[i]}, 1);

        case 4112:
            defaultCamZoom = 0.7;
            cpuStrumFade(true);
            characterJump('xeno');
            curIcon = strumLines.members[0].characters[5];
            iconP2.setIcon(curIcon.getIcon());
            if (Options.colorHealthBar) healthBar.createColoredEmptyBar(curIcon.iconColor ?? (PlayState.opponentMode ? 0xFF66FF33 : 0xFFFF0000));
            healthBar.updateBar();
            for (i in 0...cpuStrums.members.length) FlxTween.tween(cpuStrums.members[i], {x: cpuStrumX[i] + 320}, 1);
            for (i in 0...playerStrums.members.length) FlxTween.tween(playerStrums.members[i], {x: playerStrumX[i] - 320}, 1);

        case 5168:
            FlxG.camera.flash(FlxColor.WHITE, 0.7);
            xenP3Left2.visible = false;
    }

    if (hudSwap != null) {
        iconswapshit = hudSwap;
        for (item in [healthBar, healthBarBG, newBar])
            if (item != null) item.flipX = hudSwap;
        updateIconPositions();
    }

    if (spinStrums)
        for (strums in [cpuStrums, playerStrums])
            for (strum in strums.members) {
                strum.angle = 0;
                FlxTween.tween(strum, {angle: 360}, 0.2, {ease: FlxEase.quintOut});
            }
}

function postUpdate(elapsed:Float) {
    updateIconPositions();

    for (strums in [cpuStrums, playerStrums])
        for (strum in strums.members)
            strum.noteAngle = 0;
}

function cpuStrumFade(fadedStrums:Bool = false) {
    if (fadedStrums) {
        for (i in cpuStrums.notes) FlxTween.tween(i, {alpha: 0.25}, 3);
        for (i in cpuStrums.members) FlxTween.tween(i, {alpha: 0.45}, 3);
    } else {
        for (i in cpuStrums.notes) i.alpha = 1;
        for (i in cpuStrums.members) i.alpha = 1;
    }
}

function characterJump(name:String = '') {
    if (!FlxG.save.data.jumpscares) return;

    var simplejump:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image("effects/jumps/" + name));
    simplejump.setGraphicSize(FlxG.width, FlxG.height);
    simplejump.screenCenter();
    simplejump.cameras = [camEvents];
    add(simplejump);

    FlxG.camera.shake(0.0025, 0.50);
    FlxTween.tween(simplejump, {alpha: 0}, 0.5);
    new FlxTimer().start(1, function(tmr:FlxTimer) remove(simplejump));
    FlxG.sound.play(Paths.sound('souls/' + name), .1);
}

function tipleTubleStatic() {
    if (!FlxG.save.data.camFlashing) return;

    daP3Static = new FlxSprite();
    daP3Static.frames = Paths.getSparrowAtlas('effects/static/Phase3Static');
    daP3Static.animation.addByPrefix('P3Static', 'Phase3Static instance ', 24, false);
    daP3Static.screenCenter();
    daP3Static.scale.set(4, 4);
    daP3Static.alpha = 0.7;
    daP3Static.cameras = [camExt];
    add(daP3Static);
    daP3Static.animation.play('P3Static');

    daP3Static.animation.finishCallback = function(pog:String) {
        daP3Static.alpha = 0;
        remove(daP3Static);
    }
}
