import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.text.FlxTextBorderStyle;
import flixel.tween.FlxTween;
import flixel.tweens.FlxEase; 
import flixel.effects.FlxFlicker;

var selectedIndex:Int = 0;
var songIndex:Int = 0;

var firstTime = false;
var transitioning:Bool = false;

var ExtrasButtons : Array<Dynamic> = [
    {Label: "CHARACTER BIOS", Description: "Read up on some interesting LORE!!!!!", Path: "extras/biosMenu", Function: () -> {FlxG.switchState(new GameState("extras/biosMenu"));}},
    {Label: "MUSIC PLAYER", Description: "Listen to all the mods OST's.", Path: "extras/musicPlayer", Function: () -> {FlxG.switchState(new GameState("extras/musicPlayer"));}},
    {Label: "CREDITS", Description: "The Creators and people behind it all!!", Path: "extras/creditsRoll", Function: () -> {FlxG.switchState(new GameState("extras/creditsRoll"));}}
];

var viewportStartIndex:Int = 0;
var viewportSize:Int = 6;

var descText = new FlxText(140, 640, 1240, ExtrasButtons[selectedIndex].Description, 20);
descText.font = Paths.font('greenm03.ttf');
descText.antialiasing = true;
descText.scale.set(1.2, 1.2);

var songNames = ["Sonic 3 & Knuckles: Data Select"];
var composers = ["SEGA Sound Team"];

var menuTextArray = [];

var colorRed:FlxColor = 0xff781800;


function create() {
    FlxG.mouse.visible = true;
    FlxG.sound.playMusic(Paths.music('extras/S3DataSelect'), 0);
        FlxG.sound.music.fadeIn(2, 0, 1);
    FlxG.sound.play(Paths.sound("pause"), 0.5);

}

function updateMenuItemsViewport() {
    for (item in menuTextArray) remove(item);
    menuTextArray = [];

    for (i in 0...viewportSize) {
        var labelIndex = viewportStartIndex + i;
        if (labelIndex >= ExtrasButtons.length) break;

        var item = new FlxText(90, 175 + (i * 50), 1000, ExtrasButtons[labelIndex].Label, 32);
        item.scale.y = 1.35;
        item.setFormat(Paths.font('greenm03.ttf'), 32, FlxColor.WHITE, "left");
        item.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1.2);
        item.antialiasing = true;
        add(item);
        menuTextArray.push(item);
    }
    
    var selectedViewportIndex = selectedIndex - viewportStartIndex;
    if (selectedViewportIndex >= 0 && selectedViewportIndex < menuTextArray.length) {
        menuTextArray[selectedViewportIndex].color = FlxColor.WHITE;
        menuTextArray[selectedViewportIndex].setBorderStyle(FlxTextBorderStyle.OUTLINE, colorRed, 1.4);
        selectionBox.x = menuTextArray[selectedViewportIndex].x - 15;
        selectionBox.y = menuTextArray[selectedViewportIndex].y - 20;
    }
    
    descText.text = ExtrasButtons[selectedIndex].Description;

    if (!firstTime)
    {
        for (text in 0...menuTextArray.length)
        {
            menuTextArray[text].x = -350;

            FlxTween.tween(menuTextArray[text], {x: 90}, 0.5, {ease: FlxEase.quartOut, startDelay: text * 0.1 + 0.2, onComplete: (_) -> {if (text == menuTextArray.length - 1) firstTime = true;}});
        }
    }

}

var bg = new FlxSprite(0, 0).loadGraphic(Paths.image('menus/extras/extrasBG'));
add(bg);

var descBox = new FlxSprite(0, 620).makeGraphic(FlxG.width, 110, FlxColor.BLACK);
descBox.alpha = 0.7;
add(descBox);

var selectionBox = new FlxSprite(75, 162);
selectionBox.loadGraphic(Paths.image('menus/extras/SelectionBox'));
add(selectionBox);
FlxTween.tween(selectionBox, {alpha: 0.5}, 0.5, {type: 4, ease: FlxEase.quadInOut});

var title = new FlxSprite(85, 60).loadGraphic(Paths.image('menus/extras/extras'));
add(title);

updateMenuItemsViewport();

vinyl = new FlxSprite(40, 480).loadGraphic(Paths.image('menus/extras/justAnormalCD'));
add(vinyl);

var nowPlayingText = new FlxText(190, 500, 0, "NOW PLAYING", 20);
nowPlayingText.font = Paths.font('greenm03.ttf');
var songTitleText = new FlxText(210, 530, 0, songNames[songIndex], 20);
songTitleText.font = Paths.font('greenm03.ttf');
var composerText = new FlxText(190, 560, 0, "BY: " + composers[songIndex], 20);
composerText.font = Paths.font('greenm03.ttf');
add(nowPlayingText);
add(songTitleText);
add(composerText);

add(descText);

function update(elapsed:Float) {
    if (FlxG.keys.justPressed.ESCAPE && !transitioning) {
        FlxG.switchState(new MainMenuState());
    }

    if (firstTime && !transitioning)
    {
        var mouseAccept:Bool = false;

        if (controls.UP_P || controls.DOWN_P || FlxG.mouse.wheel != 0) {
            changeSelection(controls.UP_P ? -1 : controls.DOWN_P ? 1 : -FlxG.mouse.wheel);
            FlxG.sound.play(Paths.sound('menu/scroll'), 0.5);
        }

        for (i in 0...menuTextArray.length)
            if (FlxG.mouse.overlaps(menuTextArray[i])) {
                var newIndex:Int = viewportStartIndex + i;
                if (newIndex != selectedIndex) {
                    changeSelection(newIndex - selectedIndex);
                    FlxG.sound.play(Paths.sound('menu/scroll'), 0.5);
                }

                if (FlxG.mouse.justPressed)
                    mouseAccept = true;
        }

        if (controls.ACCEPT || mouseAccept) {
            var btn = ExtrasButtons[selectedIndex];
            if (btn.Path != null && btn.Function != null) {
                FlxG.sound.play(Paths.sound('menu/confirm'), 0.5);
                transitioning = true;

                var selectedViewportIndex = selectedIndex - viewportStartIndex;
                for (i in 0...menuTextArray.length)
                    if (i != selectedViewportIndex)
                        FlxTween.tween(menuTextArray[i], {alpha: 0}, 0.65, {ease: FlxEase.quadOut});

                FlxFlicker.flicker(selectionBox, 1, 0.06, false, false);
                FlxFlicker.flicker(menuTextArray[selectedViewportIndex], 1, 0.06, false, false);
                new FlxTimer().start(1, (_) -> btn.Function());
            } else {
                FlxG.sound.play(Paths.sound('menu/denied'), 0.5);
            }
        }
    }

    vinyl.angle += 45 * elapsed;
}

function changeSelection(dir:Int) {
    var oldViewportIndex = selectedIndex - viewportStartIndex;
    if (oldViewportIndex >= 0 && oldViewportIndex < menuTextArray.length) {
        menuTextArray[oldViewportIndex].setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 4);
        menuTextArray[oldViewportIndex].color = FlxColor.WHITE;
    }

    selectedIndex += dir;
    if (selectedIndex < 0) selectedIndex = ExtrasButtons.length - 1;
    if (selectedIndex >= ExtrasButtons.length) selectedIndex = 0;

    if (selectedIndex < viewportStartIndex) {
        viewportStartIndex = selectedIndex;
    } else if (selectedIndex >= viewportStartIndex + viewportSize) {
        viewportStartIndex = selectedIndex - viewportSize + 1;
    }

    updateMenuItemsViewport();
}
