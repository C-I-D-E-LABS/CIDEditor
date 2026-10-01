import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import funkin.editors.character.CharacterSelection;
import funkin.editors.charter.CharterSelection;
import funkin.editors.stage.StageSelection;

var categoryNames:Array<String> = ["Unlock", "Level Editors", "Gameplay Debug"];
var engineOptionKeys:Array<String> = ["devMode", "ghostTapping"];

var catSelected:Int = 0;
var catTexts:Array<FlxText> = [];

// each entry: [label, key, type]  type = "action" or "toggle"
var categoryOptionsList:Array<Array<Array<String>>> = [
    [
        ["All", "unlock_all", "toggle"],
        ["Story Songs", "unlock_story", "toggle"],
        ["Freeplay Songs", "unlock_freeplay", "toggle"]
    ],
    [
        ["Chart Editor", "editor_chart", "action"],
        ["Stage Editor", "editor_stage", "action"],
        ["Character Editor", "editor_character", "action"]
    ],
    [
        ["Debug Overlay", "debugOvly", "toggle"],
        ["Debug Features", "devMode", "toggle"]
    ]
];

var inCategory:Bool = false;
var optSelected:Int = 0;
var optLabelTexts:Array<FlxText> = [];
var optValueTexts:Array<FlxText> = [];

function create() {
    //add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK));

    var title = new FlxText(200, 40, 800, "DEBUG DEV MENU");
    title.setFormat(Paths.font('sonic-cd-menu-font.ttf'), 40, FlxColor.WHITE, "center");
    add(title);

    for (i in 0...categoryNames.length) {
        var label = new FlxText(60, 140 + (i * 90), 500, categoryNames[i].toUpperCase());
        label.setFormat(null, 32, FlxColor.WHITE, "left");
        add(label);
        catTexts.push(label);
    }

    buildOptionTexts(catSelected);
    updateCategorySelection();
}

function buildOptionTexts(catIndex:Int) {
    for (t in optLabelTexts) remove(t);
    for (t in optValueTexts) remove(t);
    optLabelTexts = [];
    optValueTexts = [];

    var opts = categoryOptionsList[catIndex];
    for (i in 0...opts.length) {
        var locked = opts[i][1] == "unlock_freeplay" && !getOptionValue("unlock_story");

        var label = new FlxText(600, 140 + (i * 90), 400, opts[i][0]);
        label.setFormat(null, 32, locked ? FlxColor.GRAY : FlxColor.WHITE, "left");
        add(label);
        optLabelTexts.push(label);

        var isAction = opts[i][2] == "action";
        var displayText = locked ? "LOCKED" : (isAction ? ">" : (getOptionValue(opts[i][1]) ? "ON" : "OFF"));
        var val = new FlxText(1050, 140 + (i * 90), 200, displayText);
        val.setFormat(null, 32, locked ? FlxColor.GRAY : (isAction ? FlxColor.WHITE : (getOptionValue(opts[i][1]) ? FlxColor.YELLOW : FlxColor.GRAY)));
        add(val);
        optValueTexts.push(val);
    }
    optSelected = 0;
    updateOptionSelection();
}

function update(elapsed:Float) {
    if (!inCategory) {
        if (FlxG.keys.justPressed.UP) {
            catSelected = (catSelected - 1 + categoryNames.length) % categoryNames.length;
            buildOptionTexts(catSelected);
            updateCategorySelection();
        }
        if (FlxG.keys.justPressed.DOWN) {
            catSelected = (catSelected + 1) % categoryNames.length;
            buildOptionTexts(catSelected);
            updateCategorySelection();
        }
        if (FlxG.keys.justPressed.ENTER) {
            inCategory = true;
            updateCategorySelection();
        }
        if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE) {
            FlxG.switchState(new TitleState());
        }
    } else {
        var opts = categoryOptionsList[catSelected];

        if (FlxG.keys.justPressed.UP) {
            optSelected = (optSelected - 1 + opts.length) % opts.length;
            updateOptionSelection();
        }
        if (FlxG.keys.justPressed.DOWN) {
            optSelected = (optSelected + 1) % opts.length;
            updateOptionSelection();
        }
        if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE) {
            var entry = opts[optSelected];
            FlxG.sound.play(Paths.sound("menu/scroll"));
            if (entry[2] == "action") {
                runAction(entry[1]);
            } else if (unlockKeys.contains(entry[1])) {
                toggleUnlock(entry[1]);
                buildOptionTexts(catSelected); // rebuild whole list so freeplay's lock state updates live
            } else {
                toggleOption(entry[1]);
                optValueTexts[optSelected].text = getOptionValue(entry[1]) ? "ON" : "OFF";
                optValueTexts[optSelected].color = getOptionValue(entry[1]) ? FlxColor.YELLOW : FlxColor.GRAY;
            }
        }
        if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE) {
            inCategory = false;
            updateCategorySelection();
        }
    }
}

function runAction(key:String) {
    switch (key) {
        case "editor_chart": FlxG.switchState(new CharterSelection());
        case "editor_stage": FlxG.switchState(new StageSelection());
        case "editor_character": FlxG.switchState(new CharacterSelection());
    }
}
var unlockKeys:Array<String> = ["unlock_all", "unlock_story", "unlock_freeplay"];

function getOptionValue(key:String):Bool {
    if (key == "unlock_story") return FlxG.save.data.songsBeaten == 3;
    if (key == "unlock_freeplay") return FlxG.save.data.soundtestVideoWatched == true;
    if (key == "unlock_all") return getOptionValue("unlock_story") && getOptionValue("unlock_freeplay");

    if (engineOptionKeys.contains(key)) {
        return Reflect.field(Options, key) == true;
    }
    if (Reflect.field(FlxG.save.data, key) == null) return false;
    return Reflect.field(FlxG.save.data, key);
}

function toggleUnlock(key:String) {
    if (key == "unlock_freeplay" && !getOptionValue("unlock_story")) {
        FlxG.sound.play(Paths.sound("menu/scroll"));
        return; // can't toggle freeplay until story is unlocked
    }

    var currentlyOn = getOptionValue(key);

    switch (key) {
        case "unlock_story":
            if (currentlyOn) {
                FlxG.save.data.songsBeaten = 0;
                FlxG.save.data.unlockedSongs = [];
                // turning story off also forces freeplay off, since it depends on story
                FlxG.save.data.soundtestVideoWatched = false;
                FlxG.save.data.diedInCycles = false;
            } else {
                FlxG.save.data.songsBeaten = 3;
                FlxG.save.data.unlockedSongs = ["Too Slow", "Triple Trouble", "You Cant Run"];
            }
        case "unlock_freeplay":
            if (currentlyOn) {
                FlxG.save.data.soundtestVideoWatched = false;
                FlxG.save.data.diedInCycles = false;
                FlxG.save.data.unlockedSongs = ["Too Slow", "Triple Trouble", "You Cant Run"];
            } else {
                FlxG.save.data.soundtestVideoWatched = true;
                FlxG.save.data.diedInCycles = true;
                FlxG.save.data.unlockedSongs = [
                    "Too Slow", "Triple Trouble", "You Cant Run",
                    "Chaos", "Cycles", "Eclipsera", "Endeavors", "Endless", "ILLEGAL INSTRUCTION", "Fate","Hellbent", "Milk", "Personel", "Prey",
                    "Sl4sh3r", "Soulless", "Sunshine", "Too Fest"
                ];
                FlxG.sound.play(Paths.sound('menu/confirm'), 0.6);
            }
        case "unlock_all":
            var bothOn = getOptionValue("unlock_story") && getOptionValue("unlock_freeplay");
            if (bothOn) {
                toggleUnlock("unlock_freeplay");
                toggleUnlock("unlock_story");
            } else {
                if (!getOptionValue("unlock_story")) toggleUnlock("unlock_story");
                if (!getOptionValue("unlock_freeplay")) toggleUnlock("unlock_freeplay");
            }
    }

    FlxG.save.flush();
}

function toggleOption(key:String) {
    if (engineOptionKeys.contains(key)) {
        var current = Reflect.field(Options, key) == true;
        Reflect.setField(Options, key, !current);
        Options.save();
        return;
    }
    var current = getOptionValue(key);
    Reflect.setField(FlxG.save.data, key, !current);
    FlxG.save.flush();
}

function updateCategorySelection() {
    for (i in 0...catTexts.length) {
        catTexts[i].color = (i == catSelected && !inCategory) ? FlxColor.WHITE : FlxColor.GRAY;
        catTexts[i].text = (i == catSelected ? "> " : "") + categoryNames[i].toUpperCase();
    }
}

function updateOptionSelection() {
    for (i in 0...optLabelTexts.length) {
        optLabelTexts[i].color = (i == optSelected) ? FlxColor.WHITE : FlxColor.GRAY;
    }
}
