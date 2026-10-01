var pixelStart:Int = 621; // step the notes change to pixel at
var noteSkin:String = "game/notes/default"; // noteskin they change back from pixel to
var uiChange:Bool = false;
var lastUiChange:Bool = false; // track previous state to detect transitions
var pixelBarShift:Float = 220;

import flixel.text.FlxTextFormat;
import flixel.text.FlxTextAlign;
import flixel.text.FlxTextBorderStyle;

function create() {
    graphicCache.cache(Paths.image('game/pixelUI/NOTE_assets'));
    graphicCache.cache(Paths.image(noteSkin));
    for (asset in ['sick', 'good', 'bad', 'shit', 'num0', 'num1', 'num2', 'num3', 'num4', 'num5', 'num6', 'num7', 'num8', 'num9'])
        graphicCache.cache(Paths.image('game/pixelUI/' + asset));
}

function stepHit(_:Int) {
    if (_ == pixelStart) {
        pixelStrumShit(_ == pixelStart);
    }
    if (_ == pixelStart) uiChange = true;
}

function postUpdate(elapsed:Float) {
    if (uiChange != lastUiChange) {
        lastUiChange = uiChange;
        strumLines.members[0].visible = !uiChange;

        if (uiChange) {
            scoreTxt.text = StringTools.replace(scoreTxt.text, "Score:", "SCORE:");
            missesTxt.text = StringTools.replace(missesTxt.text, "Combo Breaks:", "MISSES:");
            accuracyTxt.text = StringTools.replace(accuracyTxt.text, "Accuracy:", "ACCURACY:");

            for (text in [scoreTxt, accuracyTxt, missesTxt]) {
                text.setFormat(Paths.font("sonic1HUD.ttf"), 48, FlxColor.WHITE, "left", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
                text.borderSize = 2;
            }

            for (item in [healthBar, healthBarBG, iconP1, iconP2]) item.x += pixelBarShift;
            var barIndex = members.indexOf(iconP1) - 1;
            if (barIndex >= 0 && members[barIndex] != null) members[barIndex].x += pixelBarShift;

            scoreTxt.y -= 650;
            missesTxt.y -= 600;
            accuracyTxt.y -= 550;
        } else {
            scoreTxt.text = StringTools.replace(scoreTxt.text, "SCORE:", "Score:");
            missesTxt.text = StringTools.replace(missesTxt.text, "MISSES:", "Combo Breaks:");
            accuracyTxt.text = StringTools.replace(accuracyTxt.text, "ACCURACY:", "Accuracy:");

            for (text in [scoreTxt, accuracyTxt, missesTxt]) {
                text.setFormat(Paths.font("PhantomMuff.ttf"), 22, FlxColor.WHITE, "left", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
                text.borderSize = 1;
                text.clearFormats();
            }

            for (item in [healthBar, healthBarBG, iconP1, iconP2]) item.x -= pixelBarShift;
            var barIndex = members.indexOf(iconP1) - 1;
            if (barIndex >= 0 && members[barIndex] != null) members[barIndex].x -= pixelBarShift;

            scoreTxt.y += 650;
            missesTxt.y += 600;
            accuracyTxt.y += 550;
        }
    }

    if (!uiChange) return;

    var yellowLabel = new FlxTextFormat(FlxColor.YELLOW);

    for (text in [scoreTxt, missesTxt, accuracyTxt]) {
        text.clearFormats();
        text.addFormat(yellowLabel, 0, text.text.indexOf(":") + 1);
    }
}
function pixelStrumShit(kms:Bool) {
	for (z in strumLines)
		for (a in z.members) {
			a.antialiasing = !kms;
			if (kms) {
				a.loadGraphic(Paths.image('game/pixelUI/NOTE_assets'), true, 17, 17);
				a.animation.add("static", [a.ID]);
				a.animation.add("pressed", [4 + a.ID, 8 + a.ID], 12, false);
				a.animation.add("confirm", [12 + a.ID, 16 + a.ID], 24, false);
			
				a.scale.set(6, 6);
				a.updateHitbox();
			} else {
				a.frames = Paths.getSparrowAtlas(noteSkin);
				a.setGraphicSize(Std.int(a.width * 0.7));
				a.animation.addByPrefix('static', 'arrow' + ["left", "down", "up", "right"][a.ID].toUpperCase());
				a.animation.addByPrefix('pressed', ["left", "down", "up", "right"][a.ID] + ' press', 24, false);
				a.animation.addByPrefix('confirm', ["left", "down", "up", "right"][a.ID] + ' confirm', 24, false);		
			}
			a.animation.play('static');
			a.updateHitbox();
		}
}

function onPlayerHit(event) {
    if (!uiChange) return;

    event.ratingPrefix = "game/pixelUI/";
    event.ratingScale = 4.2;
    event.ratingAntialiasing = false;
    event.numScale = 4.2;
    event.numAntialiasing = false;
}
