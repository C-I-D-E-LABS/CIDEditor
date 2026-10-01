import openfl.display.BlendMode;

function create() {
    ovly = new FlxSprite(-500, -300);
    ovly.makeGraphic(FlxG.width *1.6, FlxG.height *1.6, FlxColor.RED);
    ovly.blend = BlendMode.SOFT_LIGHT;
    ovly.scrollFactor.set(0.9, 0.9);
    ovly.alpha = 0.15;
    add(ovly);

     
    ovlyB = new FlxSprite(-500, -300);
    ovlyB.makeGraphic(FlxG.width *1.6, FlxG.height *1.6, FlxColor.BLACK);
    ovlyB.scrollFactor.set(0.9, 0.9);
    add(ovlyB);

    FlxTween.tween(ovlyB, {alpha: 0}, 31, {ease: FlxEase.linear});

    vg = new FlxSprite(-200, -80);
    vg.loadGraphic(Paths.image("effects/vgs/vg_black"));
    vg.scrollFactor.set(0.9, 0.9);
    add(vg);
    vg.setGraphicSize(FlxG.width *1.6, FlxG.height *1.6);


    defaultCamZoom = 1;
    dad.y -= 120;
    dad.x -= 80;
    //dad.cameraOffset.y -= 30;
    //dad.cameraOffset.x -= 0;

    bf.y -= 100;
    bf.x -= 380;
   // bf.cameraOffset.y -= 130;
   // bf.cameraOffset.x -= 145;
    bf.visible = false;

    if (FlxG.save.data.modShaders) {
        crtShader = new CustomShader("vcrDistort");
        for (cam in [camGame, camHUD])
            cam.addShader(crtShader);
        crtShader.noiseOn = false; // or false to disable
        crtShader.scanlinesOn = true;
    }

   
}

function postCreate() {


    healthTxt = new FlxText(30, 580, 700, "Health: " + Math.round((health / maxHealth) * 100) + "%", 75);
    add(healthTxt);
    healthTxt.font = Paths.font("Bleakfall.ttf");
    
    healthTxt.cameras = [camHUD];

   
    for (item in [healthBar, healthBarBG, accuracyTxt, scoreTxt, missesTxt, iconP1, iconP2])
        item.visible = false;
}

function postUpdate(elapsed:Float) {
    healthTxt.text = "Health: " + Math.round((health / maxHealth) * 100) + "%";

    if (curCameraTarget == 0) {
       defaultCamZoom = 0.95;
       camGameZoomLerp = 0.03;
    }
    else {
       defaultCamZoom = 0.7;
       camGameZoomLerp = 0.03;
    }
}

