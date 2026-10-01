function create() {
        FlxG.sound.playMusic(Paths.music('gameovers/majinGameover'), 0);
    FlxG.sound.music.fadeIn(5, 0, 2);

    bgSonic = new FlxSprite(0, 0, Paths.image('exe/majin/majin_screen_bf'));
    bgSonic.antialiasing = false;
    bgSonic.screenCenter();
    bgSonic.setGraphicSize(FlxG.width, FlxG.height);
    add(bgSonic);


}

var canAccept = false;
function update(elapsed:Float) {
    if(controls.ACCEPT && !canAccept){
        FlxG.sound.play(Paths.sound("laughMajin"), 0.7);
        FlxG.sound.music.fadeOut(5, 0, 0);
        new FlxTimer().start(3, function(tmr:FlxTimer){
                FlxG.switchState(new PlayState());
        });
    }
}