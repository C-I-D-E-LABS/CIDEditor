import funkin.backend.scripting.events.StateEvent;
import funkin.backend.system.Conductor;
import funkin.options.Options;
import flixel.addons.display.FlxBackdrop;
import funkin.options.keybinds.KeybindsOptions;
import OptionsData;
import funkin.editors.ui.UIWarningSubstate;

var categoryNames:Array<String> = ["Visuals", "Gameplay", "Modifiers"];
var engineOptionKeys:Array<String> = ["downscroll", "ghostTapping"];
var catSelected:Int = 0;
var catTexts:Array<FlxText> = [];

var categoryOptionsList:Array<Array<Array<String>>> = [
    [
        ["Jumpscares", "jumpscares", "toggle"],
        ["Flash & Shake", "camFlashing", "toggle"],
        ["Shaders", "modShaders", "toggle"], 
        ["Skip Opening", "skipIntro", "toggle"], 
    ],
    [
        ["Ghost Tapping", "ghostTapping", "toggle"],
        ["Downscroll", "downscroll", "toggle"],
        ["Keybinds", "keybinds", "action"]
    ],
    [
        ["Phantom Notes", "pussyMode", "toggle"],
        ["Note Movement", "strumMovement", "toggle"], 
        ["RESET SAVE", "data", "action"]
    ]
];

var inCategory:Bool = false;
var optSelected:Int = 0;
var optLabelTexts:Array<FlxText> = [];
var optValueTexts:Array<FlxText> = [];

function create() {
   	FlxG.sound.playMusic(Paths.music('menus/soundtest'), 1);

    sonicbgLoop = new FlxBackdrop(Paths.image('menus/options/sonicbgLoop'));
    sonicbgLoop.velocity.set(-100, 0);
    sonicbgLoop.scrollFactor.set(0, 0);
    add(sonicbgLoop);

    blackBox = new FlxSprite(0, 0).loadGraphic((Paths.image('menus/options/bar')));
    add(blackBox);

        blackBox = new FlxSprite(200, 0).loadGraphic((Paths.image('effects/vgs/vg_black')));
    add(blackBox);

    var title = new FlxText(50, 40, 500, "OPTIONS");
    title.setFormat(Paths.font("sonic3TitleCard.ttf"), 64, FlxColor.WHITE);
    title.underline = true;
    add(title);

    for (i in 0...categoryNames.length) {
        var label = new FlxText(60, 140 + (i * 130), 550, categoryNames[i].toUpperCase());
        label.setFormat(Paths.font("sonic1HUD.ttf"), 64, FlxColor.WHITE);
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
        var label = new FlxText(600, 140 + (i * 130), 550, opts[i][0].toUpperCase());
        label.setFormat(Paths.font("sonic1HUD.ttf"), 64, FlxColor.WHITE);
        add(label);
        optLabelTexts.push(label);

        var isAction = opts[i][2] == "action";
        var val = new FlxText(1080, 140 + (i * 130), 500, isAction ? ">" : (getOptionValue(opts[i][1]) ? "ON" : "OFF"));
        val.setFormat(Paths.font("sonic1HUD.ttf"), 64, isAction ? FlxColor.WHITE : (getOptionValue(opts[i][1]) ? FlxColor.YELLOW : FlxColor.GRAY));
        add(val);
        optValueTexts.push(val);
    }
    optSelected = 0;
    updateOptionSelection();
}

function postCreate() {

}

function update(elapsed:Float) {
    if (!inCategory) {
        if (FlxG.keys.justPressed.UP) {
            FlxG.sound.play(Paths.sound('menu/scroll'), 1);
            catSelected = (catSelected - 1 + categoryNames.length) % categoryNames.length;
            buildOptionTexts(catSelected);
            updateCategorySelection();
        }
        if (FlxG.keys.justPressed.DOWN) {
            FlxG.sound.play(Paths.sound('menu/scroll'), 1);
            catSelected = (catSelected + 1) % categoryNames.length;
            buildOptionTexts(catSelected);
            updateCategorySelection();
        }
        if (FlxG.keys.justPressed.ENTER) {
            FlxG.sound.play(Paths.sound('menu/confirm'),0.6);
            inCategory = true;
            updateCategorySelection();
        }
        if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE) {
            FlxG.save.flush();
            OptionsData.goBack();
        }
    } else {
        var opts = categoryOptionsList[catSelected];

        if (FlxG.keys.justPressed.UP) {
            FlxG.sound.play(Paths.sound('menu/scroll'), 1);
            optSelected = (optSelected - 1 + opts.length) % opts.length;
            updateOptionSelection();
        }
        if (FlxG.keys.justPressed.DOWN) {
            FlxG.sound.play(Paths.sound('menu/scroll'), 1);
            optSelected = (optSelected + 1) % opts.length;
            updateOptionSelection();
        }
        if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE) {
            FlxG.sound.play(Paths.sound('menu/confirm'),0.6);
            var entry = opts[optSelected];
            if (entry[2] == "action") {
                if (entry[1] == "keybinds") {
                    FlxG.save.flush();
                    persistentUpdate = !(persistentDraw = true);
                    openSubState(new KeybindsOptions()); // swap for your actual keybinds state class
                }
                if(entry[1]=="data"){
                    FlxG.save.erase();
                    FlxG.save.flush();
                    Sys.exit(0);
                }
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

function getOptionValue(key:String):Bool {
    if (engineOptionKeys.contains(key)) {
        return Reflect.field(Options, key) == true;
    }
    if (Reflect.field(FlxG.save.data, key) == null) return true;
    return Reflect.field(FlxG.save.data, key);
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
