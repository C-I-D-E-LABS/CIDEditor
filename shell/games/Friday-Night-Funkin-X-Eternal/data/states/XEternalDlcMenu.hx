package data.states;


import flixel.effects.FlxFlicker;
import flixel.text.FlxTextAlign;
import flixel.text.FlxTextBorderStyle;
import flixel.math.FlxMath;
import openfl.text.TextFormatAlign;
import flixel.addons.display.FlxBackdrop;
import flixel.tweens.FlxTweenType;
import funkin.options.OptionsMenu;


var menuItems:Array<String> = [
    "Downloads",
    "Settings",
    "Exit"
];

var curSelected:Int = 0;

function create() {
    FlxG.mouse.visible = true;
    FlxG.sound.playMusic(Paths.music('menus/dlc'), 0);
    FlxG.sound.music.fadeIn(5, 0, 0.6);

    wall = new FlxBackdrop(Paths.image('menus/dlc/cloudsGrey'), FlxAxes.X);
    add(wall);
    wall.velocity.x -= 30;

    leftBox = new FlxSprite(0, 100).loadGraphic(Paths.image('menus/dlc/leftBox'));
    leftBox.scale.set(1.1, 1);
    add(leftBox);

    rightBox = new FlxSprite(700, 280).loadGraphic(Paths.image('menus/dlc/rightBox'));
    add(rightBox);

    rfLogo = new FlxSprite(-2440, -1450).loadGraphic(Paths.image('menus/TitleScreen/redactedFiles/logoRF'));
    add(rfLogo);
    rfLogo.setGraphicSize(Std.int(rfLogo.width * 0.07));

    leftBox = new FlxSprite(800, 80).loadGraphic(Paths.image('menus/dlc/NMI_Render'));
    add(leftBox);

    grpItems = new FlxTypedGroup();
    pauseItemTexts = [];
    add(grpItems);

    for (i in 0...menuItems.length) {
        var itemText:FlxSprite = new FlxSprite(0 + (i * 70), 220 + (i * 150)).loadGraphic(Paths.image("menus/dlc/button_" + i));
        grpItems.add(itemText);
        pauseItemTexts.push(itemText);
        itemText.ID = i;
    }

    changeSelection(0);
}

function update(elapsed:Float) {
    FlxG.camera.scroll.x = FlxMath.lerp(FlxG.camera.scroll.x, (FlxG.mouse.screenX - FlxG.width / 2) * -0.02, FlxMath.bound(elapsed * 4, 0, 1));
    FlxG.camera.scroll.y = FlxMath.lerp(FlxG.camera.scroll.y, (FlxG.mouse.screenY - FlxG.height / 2) * -0.015, FlxMath.bound(elapsed * 4, 0, 1));

    if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.DOWN)
        changeSelection(FlxG.keys.justPressed.UP ? -1 : 1);

    for (i in 0...pauseItemTexts.length)
        if (FlxG.mouse.overlaps(pauseItemTexts[i])) {
            if (i != curSelected) changeSelection(i - curSelected);
            else if (FlxG.mouse.justPressed) selectItem();
        }

    if (FlxG.keys.justPressed.ENTER)
        selectItem();
}

function changeSelection(change:Int = 0, playSound:Bool = true) {
        FlxG.sound.play(Paths.sound('menu/scroll'), 1);

    curSelected += change;

    if (curSelected < 0)
        curSelected = menuItems.length - 1;

    if (curSelected >= menuItems.length)
        curSelected = 0;

    for (i in 0...pauseItemTexts.length) {
        var item:FlxSprite = pauseItemTexts[i];
        item.alpha = i == curSelected ? 1 : 0.6;
    }
}

function selectItem() {
    FlxG.sound.play(Paths.sound('menu/confirm'), 0.7);
    FlxFlicker.flicker(grpItems.members[curSelected], 1, 0.06, false, false);
    new FlxTimer().start(1, (_) -> { 
    switch (curSelected) {
        case 0:
            FlxG.switchState(new GameState("XEternalDlcSelector"));
        case 1:
            FlxG.save.data.optionsReturnState = "dlc";
            FlxG.save.flush();
            FlxG.switchState(new OptionsMenu());
        case 2:
            FlxG.switchState(new GameState("XEternalTitleMenu"));
    }});
}
