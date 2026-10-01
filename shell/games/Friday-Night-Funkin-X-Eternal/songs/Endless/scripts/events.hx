var lockCamera:Bool = false;
var countdownSprites:Array<FlxSprite> = [];
var noteSkinChange:Bool = false;

function create() {
    graphicCache.cache(Paths.image("game/notes/Majin_assets"));

    for (asset in ["three", "two", "one", "goFun"]) {
        var sprite = new FlxSprite().loadGraphic(Paths.image("effects/countDown/" + asset));
        sprite.scrollFactor.set();
        sprite.updateHitbox();
        sprite.alpha = 0;
        countdownSprites.push(sprite);

        if (!FlxG.save.data.authentix)
            add(sprite);
    }
}

function onNoteHit(e) {
    if (noteSkinChange)
        e.note.splash = "endlessNoteSplashes";
}

function stepHit() {
    switch(curStep) {
        //case 10: FlxG.sound.play(Paths.sound('laughMajin'), 3);
        case 272 | 276 | 336 | 340 | 400 | 404 | 464 | 468 | 528 | 532 | 592 | 596 | 656 | 660 | 720 | 724 | 789 | 793 | 863 | 867 | 912 | 916 | 976 | 980 | 1040 | 1044 | 1104 | 1108 | 1168 | 1172 | 1232 | 1235 | 1296 | 1300 | 1360 | 1364 | 1424 | 1428 | 1488 | 1552 | 1556 | 1616 | 1620:
            for (strums in [cpuStrums, playerStrums]) {
                for (strum in strums.members) {
                    strum.angle = 0;
                    FlxTween.tween(strum, {angle: 360}, 0.2, {ease: FlxEase.quintOut});
                }
            }
        case 888:
            lockCamera = true;
            camFollow.setPosition(FlxG.width / 2 + 100, FlxG.height / 4 * 3 + 30);
            FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.3}, 0.7, {ease: FlxEase.cubeInOut});
            funInfiniteShit(0);
        case 892:
            FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.3}, 0.7, {ease: FlxEase.cubeInOut});
            funInfiniteShit(1);
        case 896:
            FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.3}, 0.7, {ease: FlxEase.cubeInOut});
            funInfiniteShit(2);
        case 900:
            lockCamera = false;
            FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.7, {ease: FlxEase.cubeInOut});
            funInfiniteShit(3);
        case 904: 
            FlxG.camera.flash(FlxColor.BLUE, 0.7);
            changePlayerSkin("Majin_assets");
            noteSkinChange = true;

    }
}

function changePlayerSkin(skin) {
    var frames = Paths.getSparrowAtlas("game/notes/" + skin);

    for (lineID in [0, 1]) {
        var strumLine = strumLines.members[lineID];
        
        for (strum in strumLine) {
            strum.frames = frames;
            strum.animation.addByPrefix("static", "arrowUP");
            strum.animation.addByPrefix("blue", "arrowDOWN");
            strum.animation.addByPrefix("purple", "arrowLEFT");
            strum.animation.addByPrefix("red", "arrowRIGHT");
        
            strum.antialiasing = true;
            strum.setGraphicSize(Std.int(frames.width * 0.7));
        
            var animPrefix = strumLine.strumAnimPrefix[strum.ID % strumLine.strumAnimPrefix.length];
            strum.animation.addByPrefix("static", "arrow" + animPrefix.toUpperCase());
            strum.animation.addByPrefix("pressed", animPrefix + " press", 24, false);
            strum.animation.addByPrefix("confirm", animPrefix + " confirm", 24, false);
        
            strum.updateHitbox();
            strum.playAnim("static");
        }
        
        for (note in strumLine.notes) {
            note.frames = frames;
        
            switch (note.noteData % 4) {
                case 0:
                    note.animation.addByPrefix("scroll", "purple0");
                    note.animation.addByPrefix("hold", "purple hold piece");
                    note.animation.addByPrefix("holdend", "pruple end hold");
                case 1:
                    note.animation.addByPrefix("scroll", "blue0");
                    note.animation.addByPrefix("hold", "blue hold piece");
                    note.animation.addByPrefix("holdend", "blue hold end");
                case 2:
                    note.animation.addByPrefix("scroll", "green0");
                    note.animation.addByPrefix("hold", "green hold piece");
                    note.animation.addByPrefix("holdend", "green hold end");
                case 3:
                    note.animation.addByPrefix("scroll", "red0");
                    note.animation.addByPrefix("hold", "red hold piece");
                    note.animation.addByPrefix("holdend", "red hold end");
            }
        
            note.scale.set(0.7, 0.7);
            note.antialiasing = true;
            note.updateHitbox();
        
            if (note.isSustainNote) {
                note.animation.play("holdend");
                note.updateHitbox();
        
                if (note.nextSustain != null)
                    note.animation.play('hold');
            } else {
                note.animation.play("scroll");
            }
        }
    }
}

function onCameraMove(_) {
    if (lockCamera) _.cancelled = true;
    else _.cancelled = false;
}

/*
fixes everything angling and not just the strumLine...
*/

function postUpdate() {
    for (strums in [cpuStrums, playerStrums])
        for (strum in strums.members)
            strum.noteAngle = 0;
}

function funInfiniteShit(display) {
    var sprite = countdownSprites[display];
    if (sprite == null) return;

    if (FlxG.save.data.authentix) add(sprite);
    sprite.alpha = 0.5;
    sprite.screenCenter();
    sprite.y -= 100;

    FlxTween.tween(sprite, {y: sprite.y + 100, alpha: 0}, Conductor.crochet / 1000, {
        ease: FlxEase.cubeInOut,
        onComplete: function(twn:FlxTween) {
            sprite.destroy();
        }
    });
}
