import flixel.effects.FlxFlicker;

function create() {
    FlxFlicker.flicker(glow, 0, 0.05); 
    
    makoto_tv = strumLines.members[0].characters[0];
    makoto_tv.visible = true;

    yoru_tv = strumLines.members[1].characters[0];
    yoru_tv.visible = true;

    makoto_forest = strumLines.members[0].characters[1];
    makoto_forest.visible = false;

    yoru_forest = strumLines.members[1].characters[1];
    yoru_forest.visible = false;
    fg.visible = false;

    blackScreen = new FlxSprite(0, 0);
    blackScreen.makeGraphic(1280, 720, FlxColor.BLACK);
    blackScreen.setGraphicSize(1280, 720);
    blackScreen.cameras = [camHUD];

    txt = new FlxText(0, 0, 0, "私の手を取ったあなたは愚か者だった");
    txt.setFormat(Paths.font("onryou.ttf"), 66, FlxColor.WHITE);
    txt.screenCenter();
    txt.cameras = [camHUD];
    insert(0, blackScreen);
    insert(1, txt);

    txt.alpha = 0;
    blackScreen.alpha = 0;

}

function stepHit(curStep:Int) {
    switch(curStep) {
        case 882:
            FlxTween.tween(blackScreen, {alpha: 1}, 1.5, {ease: FlxEase.liner});
            FlxTween.tween(txt, {alpha: 1}, 1.5, {ease: FlxEase.liner});
        case 900:
            blackScreen.visible = false;
            txt.visible = false;
            remove(glow);
            room.visible = false;
            redbox.visible = false;
            makoto_tv.visible = false;
            yoru_tv.visible = false;
            fg.visible = true;

            makoto_forest.visible = true;
            yoru_forest.visible = true;
            camGame.addShader(crtShader);
            changePlayerSkin("Nmi_assets");
        case 1668:
            makoto_forest.x += 150;
            makoto_forest.y += 40;
        case 1800:
            makoto_forest.x += 100;
            makoto_forest.y += 40;
            makoto_forest.scale.set(0.5, 0.5);
        case 2180:
            for(i in [camGame, camHUD]) FlxTween.tween(i, {alpha: 0}, 1.5, {ease: FlxEase.quartInOut});
        // case 16:
        //     glow.visible = true;
        //     room.visible = true;
        //     redbox.visible = true;
    }
}

var crtShader:CustomShader;

function postCreate() {
    crtShader = new CustomShader("vcrDistort");

    //crtShader.data.noiseTex.input = Assets.getBitmapData(Paths.image('effects/noise'));
    crtShader.warp = 4.0;
    crtShader.iScanlineAlpha = 0.15; // keep this low, like 0.1-0.2 for subtle lines
    crtShader.iLineCount = 120.0;
    crtShader.scanlinesOn = true;

    // if using scrolling version:
    crtShader.iTime = 0.0;


    
}

function update(elapsed:Float) {
    if (crtShader != null)
        crtShader.iTime += elapsed;
}

function changePlayerSkin(skin) {
    for(strumsForShit in [0, 1]){
        frames = Paths.getSparrowAtlas("game/notes/" + skin);
        
        for (strum in strumLines.members[strumsForShit]) {
        strum.frames = frames;
        strum.animation.addByPrefix("static", "arrowUP");
        strum.animation.addByPrefix("blue", "arrowDOWN");
        strum.animation.addByPrefix("purple", "arrowLEFT");
        strum.animation.addByPrefix("red", "arrowRIGHT");
        
        strum.antialiasing = true;
        strum.setGraphicSize(Std.int(frames.width * 0.7));
        
        var animPrefix = strumLines.members[strumsForShit].strumAnimPrefix[strum.ID % strumLines.members[strumsForShit].strumAnimPrefix.length];
        strum.animation.addByPrefix("static", "arrow" + animPrefix.toUpperCase());
        strum.animation.addByPrefix("pressed", animPrefix + " press", 24, false);
        strum.animation.addByPrefix("confirm", animPrefix + " confirm", 24, false);
        
        strum.updateHitbox();
        strum.playAnim("static");
        }
        
        for (note in strumLines.members[strumsForShit].notes) {
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
        } else
        note.animation.play("scroll");
        }
    }
}