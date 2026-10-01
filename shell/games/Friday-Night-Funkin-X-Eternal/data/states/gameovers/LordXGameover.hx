import flixel.tweens.FlxTweenType;
var windowTitle:String = "I See You...";

function create() {
    window.title = windowTitle; // Song name displayed in the app window
    graphicCache.cache(Paths.image("characters/lordx/LordXGameOver"));
    FlxG.sound.cache(Paths.sound("gigglylordx"));

    FlxG.camera.zoom = 1;
    FlxG.sound.playMusic(Paths.music('gameovers/lordxGameover'), 0);
    FlxG.sound.music.fadeIn(5, 0, 2);

    lordX = new FlxSprite();
    lordX.frames = Paths.getSparrowAtlas('characters/lordx/lordx_gameover');
    lordX.animation.addByPrefix('idle', 'idle', 12, true);
    lordX.animation.addByPrefix('confirm', 'confirm', 12, false);
    //lordX.scrollFactor.set(1, 1);
    lordX.animation.play('idle');
    lordX.scale.set(3, 3);
    lordX.screenCenter();
    //lordX.x += 170;
    lordX.y += 20;
    add(lordX);


    FlxTween.tween(lordX,{y: lordX.y + 30}, 3.5,{ease: FlxEase.sineInOut, type: FlxTweenType.PINGPONG});



}
var canAccept = false;
function update(elapsed:Float) {
    if(controls.ACCEPT && !canAccept){
        canAccept = true;
        lordX.animation.play("confirm");
        FlxG.sound.play(Paths.sound("gigglylordx"), 0.7);
        new FlxTimer().start(7, function(tmr:FlxTimer){
                FlxG.switchState(new PlayState());
        });
    }
    if(controls.BACK){
         window.title = "There's only one way to leave...";

    }
}
