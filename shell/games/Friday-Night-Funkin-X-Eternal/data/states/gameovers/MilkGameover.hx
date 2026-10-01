function create() {
        FlxG.sound.playMusic(Paths.music('gameovers/sunkyGameover'), 0);
    FlxG.sound.music.fadeIn(5, 0, 0.4);

    bgSonic = new FlxSprite(0, 0, Paths.image('exe/sunky/bfGameover'));
    bgSonic.antialiasing = false;
    bgSonic.screenCenter();
    add(bgSonic);


}

var flipCounter:Int = 0;

function update(elapsed:Float) {
    flipCounter++;
    if (flipCounter % 16 == 0) // every 4th frame — tweak to taste
        //bgSonic.flipY = !bgSonic.flipY;
        bgSonic.flipX = !bgSonic.flipX;

    if(controls.ACCEPT){
        FlxG.switchState(new PlayState());
 
    }
    
}