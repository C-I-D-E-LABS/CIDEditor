var grpBGparts:FlxTypedGroup;

function create() {
    grpBGparts = new FlxTypedGroup();
    insert(0, grpBGparts);

    //defaultCamZoom = 0.55;

    dad.y += 250;
    dad.x += 0;

    boyfriend.y += 120;
    boyfriend.x += 200;

    boyfriend.cameraOffset.x -= 330;
    boyfriend.cameraOffset.y -= 100;


    dad.scale.set(1.4, 1.4);
    boyfriend.scale.set(1.1, 1.1);

    // sky = new FlxSprite(-400, -200);
    // sky.frames = Paths.getSparrowAtlas('exe/majin/JP/sky');
    // sky.animation.addByPrefix('sky', "sky instance 1", 24, true);
    // sky.animation.play('sky');
    // sky.scale.set(1.4,1.4);
    // grpBGparts.add(sky);

    // pillars = new FlxSprite(-250, 0).loadGraphic(Paths.image("exe/majin/JP/pillers-back"));
    // pillars.scale.set(1.4,1.4);
    // grpBGparts.add(pillars);

    // bushes = new FlxSprite(-490, 200).loadGraphic(Paths.image("exe/majin/JP/bushes"));
    // bushes.scale.set(1.4,1.2);
    // grpBGparts.add(bushes);

    // floor = new FlxSprite(-300, 800).loadGraphic(Paths.image("exe/majin/JP/floor"));
    // floor.setGraphicSize(Std.int(floor.width * 1.5));
    // grpBGparts.add(floor);

    // trees_front = new FlxSprite(0, -200);
    // trees_front.frames = Paths.getSparrowAtlas('exe/majin/JP/trees_front');
    // trees_front.animation.addByPrefix('front', "trees mazins front instance 1", 24, true);
    // trees_front.animation.play('front');
    // trees_front.setGraphicSize(Std.int(trees_front.width * 1.4));
    // grpBGparts.add(trees_front);



}
