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
   
        case 247:
            defaultCamZoom = 1.3;
        case 272, 1164:
            FlxG.camera.flash(FlxColor.BLUE, 0.7);
            defaultCamZoom = 0.7;
            camGame.alpha = 1;
            camGame.stopFX();
        case 1157:
            camGame.alpha = 1;
            camGame.fade(0xFF000000, 0.5, false, null, true);
        case 904: 
            FlxG.camera.flash(FlxColor.BLUE, 0.7);
            changePlayerSkin("Majin_assets");
            noteSkinChange = true;
        case 1936:
            defaultCamZoom = 0.7;
            FlxTween.tween(camHUD, {alpha: 0}, 1.2, {ease: FlxEase.cubeInOut});
        case 1986:
            camGame.alpha = 1;
            camGame.fade(0xFF000000, 2, false, null, true);
            FlxTween.tween(boyfriend.cameraOffset, {y: -500}, 2, {ease: FlxEase.cubeInOut});

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
