//xd

import flixel.ui.FlxBar;
import flixel.util.FlxStringUtil;

static var timeBar:FlxBar;
static var timeBarBG:FlxSprite;
var camTime:FlxCamera;
var timeTxt:FunkinText;
public var songName:String = PlayState.SONG.meta.name;


// ── Color Palette ─────────────────────────────────────────────────
var sunkyBarPalette:Array<Int> = [

    0xFFFF0000,  // red
    0xFF00FFFF,  // cyan
    0xFFFF00EA,  // magenta
    0xFFFFFF00,  // yellow
    0xFF00FF00   // lime green
];
// ── End ───────────────────────────────────────────────────────────
function create() {
    camTime = new FlxCamera();
    camTime.bgColor = new FlxColor(0x00000000);
    FlxG.cameras.add(camTime, false);
    camTime.alpha = camHUD.alpha; // Sync alpha with camHUD for consistent fade effects
    camTime.visible = camHUD.visible; // Sync visible with camHUD for consistent fade effects

    timeTxt = new FunkinText(42 + (FlxG.width) - 248, 19, 400, "X:XX", 32, true);
    timeTxt.borderSize = 2;
    timeTxt.alignment = "center";
    timeTxt.screenCenter(FlxAxes.X);

    timeBarBG = new FlxSprite();
    timeBarBG.loadGraphic(Paths.image("game/healthBar"));
    timeBarBG.setGraphicSize(1285,20);
    timeBarBG.updateHitbox();
    timeBarBG.color = FlxColor.BLACK;
    timeBarBG.x = timeTxt.x - 443;
    timeBarBG.y = timeTxt.y + timeTxt.height + 651;

    timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, FlxBar.FILL_LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), Conductor, 'songPosition', 0, 1);
    timeBar.numDivisions = 400;
    timeBar.unbounded = true;

    timeBarBG.x = timeBar.x - 4;
    timeBarBG.y = timeBar.y - 4;

    for (i in [timeBarBG, timeBar]) {
        i.cameras = [camTime];
        i.scrollFactor.set();
        add(i);
    }
    switch(songName){
        case"Endless", "Endless US", "Endless JP", "Endeavors":
            timeBar.createFilledBar(0x00FF0000,0xFF1100FF);
        case "Personel":
            timeBar.createFilledBar(0x00FF0000,0xFFFF0000);
            //timeBar.width = Std.int(timeBarBG.width - 500);
            
            timeBar.setGraphicSize(900,20);
            //timeBar.x = timeBarBG.x + 180;
            timeBar.y = timeBarBG.y + 8;

        case "Milk", "ILLEGAL INSTRUCTION":
            timeBar.createFilledBar(0x00FF0000, sunkyBarPalette[fromIdx]);
            timeBar.setGraphicSize(900,20);
            timeBar.x = timeBarBG.x - 30;
            timeBar.y = timeBarBG.y + 8;
        case "Chaos":
             for (i in [timeBarBG, timeBar]) i.visible = false;
        default:
            timeBar.createFilledBar(0x00FF0000,0xFFFF0000);
    }
   
    
}
// ── Config ────────────────────────────────────────────────────────
var LERP_SPEED:Float = 2.0;  // higher = faster fade between colors

var timer:Float     = 0.0;
var fromIdx:Int     = 0;
var targetIdx:Int   = 1;


function update(elapsed:Float) {
    camTime.alpha = camHUD.alpha;
    camTime.visible = camHUD.visible;

    if (FlxG.cameras.list.indexOf(camTime) != -1 && FlxG.cameras.list[FlxG.cameras.list.length - 1] != camTime) {
        FlxG.cameras.remove(camTime, false);
        FlxG.cameras.add(camTime, false);
    }

    if (inst != null && timeBar != null && timeBar.max != inst.length) timeBar.setRange(0, Math.max(1, inst.length));
    timeTxt.text = FlxStringUtil.formatTime((inst.length-inst.time) / 1000, false);

   timer += elapsed * LERP_SPEED;

    if (timer >= 1.0) {
        timer -= 1.0;
        fromIdx   = targetIdx;
        targetIdx = randDifferentFrom(fromIdx);
    }

    if (songName == "Milk") {
    var color:Int = lerpColor(sunkyBarPalette[fromIdx], sunkyBarPalette[targetIdx], timer);
    timeBar.createFilledBar(0x00FF0000, color);
    }else return;
    //End of Sunky bar stuffs
}

// ── Helpers ───────────────────────────────────────────────────────
function randDifferentFrom(exclude:Int):Int {
    var idx:Int = exclude;
    while (idx == exclude)
        idx = Std.int(Math.random() * sunkyBarPalette.length);
    return idx;
}


function lerpColor(a:Int, b:Int, t:Float):Int {
    var ar:Int = (a >> 16) & 0xFF;
    var ag:Int = (a >> 8)  & 0xFF;
    var ab:Int =  a        & 0xFF;
    var br:Int = (b >> 16) & 0xFF;
    var bg:Int = (b >> 8)  & 0xFF;
    var bb:Int =  b        & 0xFF;
    var r:Int    = Std.int(ar + (br - ar) * t);
    var g:Int    = Std.int(ag + (bg - ag) * t);
    var bOut:Int = Std.int(ab + (bb - ab) * t);
    return 0xFF000000 | (r << 16) | (g << 8) | bOut;
}
