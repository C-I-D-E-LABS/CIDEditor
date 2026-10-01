import Loader;
import funkin.backend.week.Week;

var curSelection:Int = 0; // 0 = Boyfriend (main story), 1 = Girlfriend (side path)
var canSelect:Bool = true;

function create() {

    FlxG.mouse.visible = true;

    title = new FlxText(220, 40, 800, "A FORK IN THE ROAD");
    title.setFormat(Paths.font('sonic-cd-menu-font.ttf'), 40, FlxColor.WHITE, "center");
    add(title);

    talk = new FlxText(80, 200);
    talk.text = "Uh oh! Girlfriend has been sent to the south side of the island but now you are without protection \n do you wish to see where Girlfriend went or continue with the main story?";
    talk.alignment = "center";
    talk.scale.set(2.3,2.3);
    talk.updateHitbox();
    add(talk);
    talk.alpha = 1;

    bfSticker = new FlxSprite(0, 480).loadGraphic(Paths.image("menus/bf-sticker"));
    bfSticker.antialiasing = false;
    bfSticker.scale.set(0.5, 0.5);
    bfSticker.screenCenter(FlxAxes.X);
    add(bfSticker);

    gfSticker = new FlxSprite(0, 430).loadGraphic(Paths.image("menus/gf-sticker"));
    gfSticker.antialiasing = false;
    gfSticker.scale.set(0.45, 0.45);
    gfSticker.screenCenter(FlxAxes.X);
    add(gfSticker);

    gfSticker.x += 180;
    bfSticker.x -= 180;

    FlxG.sound.play(Paths.sound("pause"), 0.5);

    updateSelection(); // set initial highlight state
}

function update(elapsed:Float) {
    if (canSelect) {
        if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A) {
            changeSelection(-1);
        }
        if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D) {
            changeSelection(1);
        }
        if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE) {
            confirmSelection();
        }
    }
}

function changeSelection(dir:Int = 0) {
    curSelection += dir;

    if (curSelection < 0) curSelection = 1;
    if (curSelection > 1) curSelection = 0;

    FlxG.sound.play(Paths.sound("menu/scroll"), 0.4);
    updateSelection();
}

function updateSelection() {
    var bfSelected:Bool = (curSelection == 0);

    // scale + alpha bop for whichever sticker is active
    FlxTween.cancelTweensOf(bfSticker);
    FlxTween.cancelTweensOf(gfSticker);

    var bfTargetScale:Float = bfSelected ? 0.6 : 0.5;
    var gfTargetScale:Float = bfSelected ? 0.45 : 0.55;

    FlxTween.tween(bfSticker.scale, {x: bfTargetScale, y: bfTargetScale}, 0.15, {ease: FlxEase.backOut});
    FlxTween.tween(gfSticker.scale, {x: gfTargetScale, y: gfTargetScale}, 0.15, {ease: FlxEase.backOut});

    bfSticker.alpha = bfSelected ? 1 : 0.6;
    gfSticker.alpha = bfSelected ? 0.6 : 1;

    bfSticker.color = bfSelected ? FlxColor.WHITE : FlxColor.GRAY;
    gfSticker.color = bfSelected ? FlxColor.GRAY : FlxColor.WHITE;
}
var weekName:String = "detour";
function confirmSelection() {
    FlxG.save.flush();

    canSelect = false;
    FlxG.sound.play(Paths.sound("confirmMenu"), 0.7);

    FlxTween.tween(FlxG.camera, {zoom: 2}, 0.3, {
        ease: FlxEase.quadIn,
        onComplete: function(twn:FlxTween) {
            if (curSelection == 0) {
                Loader.loadSongWithReturn("Triple Trouble", "hard", "XEternalStoryMode");
            } else {
                var week = Week.loadWeek(weekName, true);
                Loader.loadWeekWithReturn(week, "hard", "XEternalStoryMode");
            }
        }
    });
}