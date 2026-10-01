import haxe.xml.Access;
import flixel.tweens.FlxTweenType;
var windowTitle:String = "I See You...";

function create() {
    window.title = windowTitle; // Song name displayed in the app window
    graphicCache.cache(Paths.image("characters/lordx/LordXGameOver"));
    FlxG.sound.cache(Paths.sound("gigglylordx"));

    FlxG.camera.zoom = 1;
    FlxG.sound.playMusic(Paths.music('LordXGameover'), 0);
    FlxG.sound.music.fadeIn(5, 0, 2);


    sonicexe = new FlxSprite(450, 80);
    sonicexe.frames = Paths.getSparrowAtlas('characters/sonicexe/sonicexe_gameover');
    sonicexe.animation.addByPrefix('idle', 'gameOver', 24, true);
    sonicexe.animation.addByPrefix('confirm', 'LordXGameOver confirm', 24, false);
    sonicexe.animation.play('idle');
    sonicexe.scale.set(1.2, 1.2);
    sonicexe.antialiasing = true;
    add(sonicexe);


    bfdeath = new Character(450, 0, "bf-dead");
    bfdeath.flipX = false;
    bfdeath.scale.set(0.6, 0.6);
    bfdeath.playAnim("firstDeath");
    add(bfdeath);
    new FlxTimer().start(7, function(tmr:FlxTimer){
            bfdeath.dance();
    });

}
var canAccept = false;
function update(elapsed:Float) {
    if(controls.ACCEPT && !canAccept){
        bfdeath.playAnim("deathConfirm");
        FlxG.sound.play(Paths.sound("gigglylordx"), 0.7);
        new FlxTimer().start(7, function(tmr:FlxTimer){
                FlxG.switchState(new PlayState());
        });
    }
    if(controls.BACK){
        FlxG.switchState(new GameState("XEternalStoryMenu"));
    }
}
