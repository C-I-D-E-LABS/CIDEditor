import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.input.keyboard.FlxKey;

// ---------------------------------------------------------------------
// New Local DLC creator — split out of XEternalDlcMenu.hx into its own
// substate (opened via openSubState(new GameSubState("XEternalNewDlcSubstate")))
// so the main menu script doesn't carry the name-entry/type-toggle UI and
// its input handling inline. Flixel pauses the parent state's update()
// while a substate is open (persistentUpdate defaults to false) and still
// draws it underneath (persistentDraw defaults to true), which is exactly
// the "frozen grid behind a modal" look the inline version had before —
// we get that for free here instead of hand-rolling a creatingLocalDlc
// gate in the parent's update().
//
// Substate scripts run as their own separate HScript instance and can't
// reach into XEternalDlcMenu.hx's fields directly (same reason
// cross-script statics don't share state in this fork). So this substate
// only collects a name + type from the player; the actual folder/dlc.json
// creation and grid rebuild happen back in the parent, which picks the
// result up via FlxG.save.data — the same cross-script hand-off pattern
// the project already uses (cameFromDLCMenu / returnState).
// ---------------------------------------------------------------------

// Palette — duplicated from XEternalDlcMenu.hx rather than shared, for
// the reason above. Keep these in sync by hand if the parent's palette
// changes.
var COLOR_BG_PANEL:Int     = 0xEB100606;
var COLOR_ACCENT_DIM:Int   = 0xFF501212;
var COLOR_BTN_IDLE:Int     = 0xEB200A0A;
var COLOR_BTN_HOVER:Int    = 0xF5601616;
var COLOR_BTN_SELECTED:Int = 0xFAC32828;
var COLOR_TEXT_DIM:Int     = 0xFFBE9696;
var LABEL_FONT:String      = "sonic3TitleCard.ttf";

var nameBuffer:String = "";
var dlcType:String    = "song"; // "song" | "week"

var backdrop:FlxSprite;
var panel:FlxSprite;
var promptText:FlxText;
var hintText:FlxText;

var typeButtons:Array<FlxSprite> = [];
var typeLabels:Array<FlxText>    = [];
var typeValues:Array<String>     = ["song", "week"];

// Parallel-array letter lookup (avoids relying on regex / map-literal
// support that isn't reliable in this fork's HScript parser).
var letterKeys:Array<FlxKey> = [
    FlxKey.A, FlxKey.B, FlxKey.C, FlxKey.D, FlxKey.E, FlxKey.F, FlxKey.G,
    FlxKey.H, FlxKey.I, FlxKey.J, FlxKey.K, FlxKey.L, FlxKey.M, FlxKey.N,
    FlxKey.O, FlxKey.P, FlxKey.Q, FlxKey.R, FlxKey.S, FlxKey.T, FlxKey.U,
    FlxKey.V, FlxKey.W, FlxKey.X, FlxKey.Y, FlxKey.Z
];
var letterChars:Array<String> = [
    "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q",
    "r","s","t","u","v","w","x","y","z"
];

function makeBorderedBox(x:Float, y:Float, w:Float, h:Float, idleColor:Int):FlxSprite
{
    var border = new FlxSprite(x - 3, y - 3);
    border.makeGraphic(Std.int(w + 6), Std.int(h + 6), COLOR_ACCENT_DIM);
    border.scrollFactor.set(0, 0);
    add(border);

    var box = new FlxSprite(x, y);
    box.makeGraphic(Std.int(w), Std.int(h), idleColor);
    box.scrollFactor.set(0, 0);
    add(box);

    return box;
}

function postCreate()
{
    backdrop = new FlxSprite(0, 0);
    backdrop.makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(6, 0, 0, 195));
    backdrop.scrollFactor.set(0, 0);
    add(backdrop);

    var panelW = 560;
    var panelH = 270;
    var panelX = (FlxG.width  - panelW) / 2;
    var panelY = (FlxG.height - panelH) / 2;

    panel = makeBorderedBox(panelX, panelY, panelW, panelH, COLOR_BG_PANEL);

    promptText = new FlxText(panel.x + 20, panel.y + 20, 520, "Name your new local DLC:\n_");
    promptText.setFormat(Paths.font(LABEL_FONT), 26, FlxColor.WHITE, "center");
    promptText.scrollFactor.set(0, 0);
    add(promptText);

    var typeY = panel.y + 135;
    var typeLabelsText = ["SINGLE SONG", "FULL WEEK"];
    for (i in 0...2)
    {
        var bx = panel.x + 40 + i * 250;

        var btn = makeBorderedBox(bx, typeY, 220, 36, COLOR_BTN_IDLE);

        var lbl = new FlxText(bx, typeY + 8, 220, typeLabelsText[i]);
        lbl.setFormat(Paths.font(LABEL_FONT), 18, FlxColor.WHITE, "center");
        lbl.scrollFactor.set(0, 0);
        add(lbl);

        typeButtons.push(btn);
        typeLabels.push(lbl);
    }

    hintText = new FlxText(panel.x + 20, panel.y + panel.height - 36, 520,
        "Letters + space only  -  pick a type above  -  ENTER to create  -  ESC to cancel");
    hintText.setFormat(Paths.font(LABEL_FONT), 15, COLOR_TEXT_DIM, "center");
    hintText.scrollFactor.set(0, 0);
    add(hintText);
}

function flxKeyToLetter(key:FlxKey):String
{
    var idx = letterKeys.indexOf(key);
    if (idx == -1) return null;
    return letterChars[idx];
}

function update(elapsed:Float)
{
    // Type toggle — always live so clicking works even without typing.
    for (i in 0...typeButtons.length)
    {
        var isSelected = (typeValues[i] == dlcType);
        var isHovered  = FlxG.mouse.overlaps(typeButtons[i]);

        typeButtons[i].color = isSelected
            ? COLOR_BTN_SELECTED
            : (isHovered ? COLOR_BTN_HOVER : COLOR_BTN_IDLE);

        if (isHovered && FlxG.mouse.justReleased)
            dlcType = typeValues[i];
    }

    var justKey = FlxG.keys.firstJustPressed();
    if (justKey == FlxKey.NONE) return;

    if (justKey == FlxKey.ENTER)
    {
        confirmAndClose();
        return;
    }
    if (justKey == FlxKey.ESCAPE)
    {
        close();
        return;
    }
    if (justKey == FlxKey.BACKSPACE)
    {
        if (nameBuffer.length > 0)
            nameBuffer = nameBuffer.substr(0, nameBuffer.length - 1);
    }
    else if (justKey == FlxKey.SPACE)
    {
        if (nameBuffer.length < 24)
            nameBuffer += " ";
    }
    else
    {
        var letter = flxKeyToLetter(justKey);
        if (letter != null && nameBuffer.length < 24)
        {
            var shiftHeld = FlxG.keys.pressed.SHIFT;
            nameBuffer += shiftHeld ? letter.toUpperCase() : letter;
        }
    }

    promptText.text = "Name your new local DLC:\n" + nameBuffer + "_";
}

function confirmAndClose()
{
    // Handed off to XEternalDlcMenu.hx, which does the actual folder/
    // dlc.json creation (including sanitizing/uniquifying the id) and
    // rebuilds its grid once it sees these set — see the top of its
    // update().
    FlxG.save.data.pendingNewDlcName = nameBuffer;
    FlxG.save.data.pendingNewDlcType = dlcType;
    FlxG.save.flush();

    close();
}