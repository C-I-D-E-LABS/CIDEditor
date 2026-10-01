import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.text.FlxTextBorderStyle;
import funkin.backend.assets.GamesFolder;
import sys.FileSystem;
import sys.io.File;

var bubbleText:FlxText;
var bubbleActive:Bool = false;

var bubbleIndex:Int = 0;
var bubbleLines = [];
var bfNormal;
var bfChicken;

function create() {
    bfNormal = strumLines.members[1].characters[0];
    bfChicken = strumLines.members[1].characters[1];

    bfChicken.x = 75;
    bfChicken.y = -50;
    bfChicken.visible = false;

    var whiteBG = new FlxSprite(-2000, -1200).makeGraphic(2, 2, FlxColor.WHITE);
    whiteBG.scale.set(2200, 1600);
    whiteBG.updateHitbox();
    whiteBG.scrollFactor.set();
    insert(0, whiteBG);

    var bubble = stage.getSprite("bubble");
    bubbleText = new FlxText(bubble.x + 200, bubble.y + 155, 430, "", 34);
    bubbleText.setFormat(Paths.font("vcr.ttf"), 34, FlxColor.BLACK, "left", FlxTextBorderStyle.NONE, FlxColor.BLACK);
    add(bubbleText);

    var path = "games/" + GamesFolder.currentModFolder + "/songs/Personel/personelBubble.txt";
    if (FileSystem.exists(path))
        for (line in File.getContent(path).split("\n")) {
            line = line.split("\r").join("");
            if (line == "" || line.substr(0, 1) == "#")
                continue;

            var split = line.indexOf("|");
            if (split > -1)
                bubbleLines.push([Std.parseFloat(line.substr(0, split)), line.substr(split + 1)]);
        }
}

function postUpdate(elapsed:Float) {
    comboGroup.x = 10080;
    comboGroup.y = 0;

    bubbleText.x = stage.getSprite("bubble").x + 200;
    bubbleText.y = stage.getSprite("bubble").y + 155;

    if (bubbleIndex > 0 && Conductor.songPosition < bubbleLines[bubbleIndex - 1][0]) {
        bubbleIndex = 0;
        bubbleActive = false;
        bubbleText.text = "";
    }

    while (bubbleIndex < bubbleLines.length && Conductor.songPosition >= bubbleLines[bubbleIndex][0]) {
        if (bubbleLines[bubbleIndex][1] == "") {
            bubbleActive = false;
            bubbleText.text = "";
        } else {
            bubbleActive = true;
            bubbleText.text += bubbleLines[bubbleIndex][1];
        }

        bubbleIndex++;
    }

    if (!bubbleActive && dad.animation.curAnim != null)
        if (dad.animation.curAnim.name == "idle")
            bubbleText.text = "";
}

function stepHit(curStep:Int) {
    switch(curStep) {
        case 1312:
            bfNormal.visible = false;
            bfChicken.visible = true;

        case 1696:
            bfNormal.visible = true;
            bfChicken.visible = false;
    }
}

function onNoteHit(e) {
    if (bubbleActive || !e.characters.contains(strumLines.members[0].characters[0]))
        return;

    if (e.note.isSustainNote) {
        switch(e.note.noteData % 4) {
            case 0: bubbleText.text += "UU";
            case 1: bubbleText.text += "OO";
            case 2: bubbleText.text += "AA";
            case 3: bubbleText.text += "EE";
        }
    } else {
        switch(e.note.noteData % 4) {
            case 0: bubbleText.text = "UU";
            case 1: bubbleText.text = "OO";
            case 2: bubbleText.text = "AA";
            case 3: bubbleText.text = "EE";
        }
    }
}

function lyric(text:String) {
    bubbleActive = text != "";
    bubbleText.text = text;
}

function onSongEnd() {
    CoolUtil.openURL("https://coldsteelcool.newgrounds.com");
}
