import flixel.text.FlxTextBorderStyle;
import flixel.effects.FlxFlicker;
import funkin.backend.utils.DiscordUtil;

var transitioning:Bool = false;
public var displayName = DiscordUtil.user.globalName;

function create() {
    FlxG.mouse.visible = true;
    FlxG.sound.cache(Paths.sound('menu/confirm'));

    talk = new FlxText();
		talk.text = "Hello there " + displayName +", my name is N1ck, and if you've downloaded this build,\n" +
                    "this is what my vision of EXEternal was meant to be, if it had been completed.\n" +
                    "Some assets are the same as the original, while others are completely different,\n" +
                    "but either way, I truly hope you enjoy this mod as much as I do.\n\n" +
                    "Thank you to all of the EXEternal devs for your amazing artwork, songs, code, and ideas.\n" +
                    "You all mean so much to me even though I haven’t met most of you personally.\n" +
                    "I made this mod to showcase my love for all of you and for the project itself.\n\n" +
                    "So, with all that out of the way... please enjoy my masterpiece!\n\n" +
                    "With love,\n" +
                    "N1ckolasN4me <3";
		talk.alignment = "center";
		talk.scale.set(2.3,2.3);
		talk.updateHitbox();
		talk.screenCenter();
		add(talk);
        talk.alpha = 1;

	//FlxTween.tween(talk, {alpha: 1}, 1, {ease: FlxEase.sineInOut});

    ocs = new FlxSprite(540, 580).loadGraphic(Paths.image("menus/credits/ocs"));
    ocs.antialiasing = false;
    ocs.scale.set(2, 2);
    add(ocs);

    var title = new FlxText(250, 40, 800, "DIRECTORS NOTE");
    title.setFormat(Paths.font('sonic-cd-menu-font.ttf'), 40, FlxColor.WHITE, "center");
    add(title);

    //FlxG.sound.play(Paths.sound("pause"), 0.5);

}

function update(e) {
        if(!transitioning){
        if(FlxG.keys.justPressed.ENTER){
            FlxG.sound.play(Paths.sound('menu/confirm'));           
            transitioning = true;
            new FlxTimer().start(1, function(tmr:FlxTimer){
                FlxG.switchState(new GameState("XEternalTitleMenu"));

            });
        }
        var skipIntro:Bool = FlxG.save.data.skipIntro == true;
        if (skipIntro) {
             FlxG.switchState(new GameState("XEternalTitleMenu"));
        }
    }
}
