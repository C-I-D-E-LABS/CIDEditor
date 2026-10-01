import flixel.addons.display.FlxBackdrop;

function create() {   
    create_clouds();

    comboGroup.x += 750;
    comboGroup.y += 600;
}

function create_clouds() {
    grpClouds = new FlxTypedGroup();
    insert(members.indexOf(stage.getSprite("floor")),grpClouds);

    for (i in 1...4){
        cloud = new FlxBackdrop(Paths.image('stages/tri/cloud' + i), FlxAxes.X);
        cloud.setPosition(0,100 + (i * 80));
        cloud.scale.set(1.8, 1.8);
        cloud.updateHitbox();
        cloud.velocity.x = -25 * (i * 1.025);
        cloud.scrollFactor.set(0.75 + (i * 0.15), 0.75 + (i * 0.15));
        grpClouds.add(cloud);
    }
}

function onGameOver(e){
    e.cancel(); 
    FlxG.switchState(new PlayState());
}