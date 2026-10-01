import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.input.keyboard.FlxKey;

// ---------------------------------------------------------------------
// Song-select submenu — split out of XEternalDlcMenu.hx the same way the
// New Local DLC creator was (see XEternalNewDlcSubstate.hx). Shown when a
// "full week" DLC has already been fully played, letting the player jump
// straight to any song in it instead of always auto-picking the next
// unplayed one.
//
// Hand-off: the parent stashes songSelectDlcName + songSelectSongs into
// FlxG.save.data before calling openSubState() (separately-loaded HScript
// instances can't share fields directly — same reason as the DLC creator
// substate). Picking a song writes songSelectPickedSong and closes; BACK
// just closes without writing anything, so the parent knows nothing was
// picked once it resumes.
// ---------------------------------------------------------------------

// Palette — duplicated from XEternalDlcMenu.hx rather than shared, for
// the reason above. Keep these in sync by hand if the parent's palette
// changes.
var COLOR_ACCENT_DIM:Int = 0xFF501212;
var COLOR_BTN_IDLE:Int   = 0xEB200A0A;
var COLOR_BTN_HOVER:Int  = 0xF5601616;
var LABEL_FONT:String    = "sonic3TitleCard.ttf";

var songButtons:Array<FlxSprite> = [];
var songLabels:Array<FlxText>    = [];
var songIds:Array<String>        = [];

var backButton:FlxSprite;

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
    var backdrop = new FlxSprite(0, 0);
    backdrop.makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(6, 0, 0, 180));
    backdrop.scrollFactor.set(0, 0);
    add(backdrop);

    var dlcName:String = FlxG.save.data.songSelectDlcName;
    var title = new FlxText(0, 70, FlxG.width, (dlcName != null ? dlcName : "") + " - Select a song");
    title.setFormat(Paths.font(LABEL_FONT), 32, FlxColor.WHITE, "center");
    title.scrollFactor.set(0, 0);
    add(title);

    backButton = makeBorderedBox(FlxG.width / 2 - 80, FlxG.height - 70, 160, 36, COLOR_BTN_IDLE);

    var backLabel = new FlxText(backButton.x, backButton.y + 8, 160, "BACK");
    backLabel.setFormat(Paths.font(LABEL_FONT), 20, FlxColor.WHITE, "center");
    backLabel.scrollFactor.set(0, 0);
    add(backLabel);

    var songs:Array<Dynamic> = FlxG.save.data.songSelectSongs;
    var startY = 140;
    if (songs != null)
    {
        for (i in 0...songs.length)
        {
            var songId = Std.string(songs[i]);

            var btn = makeBorderedBox(FlxG.width / 2 - 200, startY + i * 52, 400, 40, COLOR_BTN_IDLE);

            var lbl = new FlxText(btn.x, btn.y + 8, 400, songId);
            lbl.setFormat(Paths.font(LABEL_FONT), 22, FlxColor.WHITE, "center");
            lbl.scrollFactor.set(0, 0);
            add(lbl);

            songButtons.push(btn);
            songLabels.push(lbl);
            songIds.push(songId);
        }
    }
}

function update(elapsed:Float)
{
    // Plain key check rather than controls.BACK — not verified that the
    // controls binding is available inside a substate script, and this
    // avoids relying on it (same call the DLC-creator substate makes).
    if (FlxG.keys.justPressed.ESCAPE)
    {
        close();
        return;
    }

    var hovered = -1;
    for (i in 0...songButtons.length)
    {
        if (FlxG.mouse.overlaps(songButtons[i]))
        {
            hovered = i;
            break;
        }
    }
    for (i in 0...songButtons.length)
        songButtons[i].color = (i == hovered) ? COLOR_BTN_HOVER : COLOR_BTN_IDLE;

    var backHovered = FlxG.mouse.overlaps(backButton);
    backButton.color = backHovered ? COLOR_BTN_HOVER : COLOR_BTN_IDLE;

    if (!FlxG.mouse.justReleased) return;

    if (backHovered)
    {
        close();
        return;
    }

    if (hovered >= 0)
    {
        FlxG.save.data.songSelectPickedSong = songIds[hovered];
        FlxG.save.flush();
        close();
    }
}