//
import funkin.editors.charter.Charter;
import funkin.game.PlayState;
import flixel.text.FlxTextAlign;
import flixel.text.FlxTextBorderStyle;
import flixel.tweens.FlxTweenType;

static var curBotplay:Bool = false;
static var devControlBotplay:Bool = true;
public var botTxt:FlxText;
function postCreate() {
    //importScript("data/scripts/fastforward");
    importScript('data/scripts/resizing');


    instructions = new FlxText(-350, 520, 1280,  "Buttons to Press:\n  6: Enable Botplay \n  7: Charting Menu\n  8: End Current Song\n  9: Restart The State", 32);
    instructions.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, "left", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    instructions.borderSize = 1.25;
    instructions.camera = camHUD;
    add(instructions);

    botTxt = new FlxText(-80, 680, 1280,  "Botplay Enabled", 62);
    botTxt.setFormat(Paths.font("vcr.ttf"), 26, FlxColor.RED, "right", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    botTxt.borderSize = 1.25;
    botTxt.camera = camHUD;
    botTxt.visible = curBotplay;
    add(botTxt);


    FlxTween.tween(instructions, {x: instructions.x + 370}, 0.7);
    new FlxTimer().start(6, () -> FlxTween.tween(instructions, {x: instructions.x - 400}, 0.5));

   
}

function update(elapsed:Float) {

    updateBotplay(elapsed);

    if (FlxG.keys.justPressed.NINE) FlxG.resetState();

    if (FlxG.keys.justPressed.EIGHT && generatedMusic ) endSong();

    if (FlxG.keys.justPressed.SEVEN) {
        ratioThing(1280, 720, true);
        FlxG.switchState(new Charter(PlayState.SONG.meta.name, PlayState.difficulty));
    }

}

public var botplaySine:Float = 0;
function updateBotplay(elapsed:Float) {
    if (!devControlBotplay) return;

    if (FlxG.keys.justPressed.SIX) curBotplay = !curBotplay;
    for(strumLine in strumLines)
    if(!strumLine.opponentSide) strumLine.cpu = FlxG.keys.pressed.FIVE || curBotplay;

    botTxt.visible = curBotplay;
    
    if (!curBotplay) return;

    botplaySine += 180 * elapsed;
    botTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);

}

function updateSpeed(speed:Float)FlxG.timeScale = inst.pitch = vocals.pitch = speed;

function onGamePause() {updateSpeed(1);}
function onSongEnd() {updateSpeed(1);}
function destroy() {FlxG.timeScale = 1;FlxG.sound.muted = false;}

