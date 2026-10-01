import funkin.options.OptionsMenu;
import funkin.editors.charter.Charter;
import funkin.options.keybinds.KeybindsOptions;
import flixel.addons.display.FlxBackdrop;
import flixel.text.FlxText;
import flixel.text.FlxTextBorderStyle;
import OptionsData;
var curPSelected:Int = 0;
var grpItems:FlxTypedGroup;
var pauseCam = null;
var pauseItemTexts:Array<FlxSprite> = [];
var pauseText = null;
var itemCursor = null;
var songName:String = PlayState.SONG.meta.name;
var filter = null;
var pauseShaderCam = null;

var pauseItems:Array<String> = [
    "Resume",
    "Restart",
    "Options",
    "Exit"
];

var weeks:Array<String> = [
    "Too Slow",
    "You Cant Run",
    "Eclipsera",
    "Triple Trouble"
];

function create(event){
    event.music = "none";
	event.cancel();

    pauseCam = new FlxCamera();
    pauseCam.bgColor = 0x99000000;
    FlxG.cameras.add(pauseCam, false);
    FlxG.sound.play(Paths.sound("pause"), 0.7);

    filter = new CustomShader('hsv');
    filter.uHsv = [-1.0, -1.0, -0.5];
    FlxG.camera.addShader(filter);
    pauseShaderCam = PlayState.instance != null ? PlayState.instance.camHUD : null;
    if (pauseShaderCam != null) pauseShaderCam.addShader(filter);

    pauseTextbg = new FlxSprite(0,570).makeGraphic(3000, 42, FlxColor.BLACK);
    pauseTextbg.scrollFactor.set();
    add(pauseTextbg);

    pauseText= new FlxSprite(50, 550).loadGraphic(Paths.image('menus/pause/pauseTxt'));
    pauseText.scale.set(3,3);
    add(pauseText);

    barBg = new FlxSprite(1180,-200).makeGraphic(120, FlxG.height + 500, FlxColor.BLACK);
    barBg.scrollFactor.set();
    add(barBg);
    
    barUP = new FlxBackdrop(Paths.image('menus/pause/bar'), FlxAxes.Y);
    barUP.velocity.y = 40;
    barUP.screenCenter();
    barUP.x += 330;
    barUP.scale.set(3,3);
    add(barUP); 

    grpItems = new FlxTypedGroup();
    pauseItemTexts = [];
	add(grpItems);

    for (i in 0...pauseItems.length) {
        var itemText:FlxSprite = new FlxSprite(1040, 120 + (i * 150)).loadGraphic(Paths.image("menus/pause/menu_" + i));
        itemText.scale.set(3,3);
        grpItems.add(itemText);
        pauseItemTexts.push(itemText);
        itemText.ID = i;
    }
    itemCursor= new FlxSprite(1090, 150).loadGraphic(Paths.image('menus/pause/selectBar'));
    itemCursor.scale.set(3,3);
    add(itemCursor);

    songNameTxt = new FlxText(30, 10, FlxG.width, songName,  30);
    songNameTxt.setFormat(Paths.font('sonic-cd-menu-font.ttf'), 30, 0xffffff, "left", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    songNameTxt.borderSize = 2;
    add(songNameTxt);


	FlxTween.tween(pauseText, {x: pauseText.x + 50}, 0.7, {ease: FlxEase.circOut});

    cameras = [pauseCam];

    switch(songName){
        case "Milk", "ILLEGAL INSTRUCTION":
            pauseCam.zoom = 0.75;
        case "Personel":
            pauseCam.zoom = 0.75;
            songNameTxt.x += 50;
            songNameTxt.y -= 50;
            FlxTween.tween(pauseText, {x: pauseText.x + 150}, 0.7, {ease: FlxEase.circOut});
    }
}

function update(elapsed){
	if(controls.ACCEPT){
        cleanupPause();
        switch(curPSelected){
            case 0:
                close();
                FlxG.sound.play(Paths.sound("unpause"), 0.7);

            case 1:
                parentDisabler.reset();
                PlayState.instance.registerSmoothTransition();
                FlxG.resetState();
            case 2:
                FlxG.save.data.optionsReturnState = "song";
                FlxG.save.data.optionsReturnSongName = PlayState.SONG.meta.name;
                FlxG.save.data.optionsReturnDifficulty = PlayState.difficulty;
                FlxG.save.flush();
                FlxG.switchState(new GameState("XEternalOptions"));
            case 3:
                cleanupPause();
                if (weeks.contains(songName))FlxG.switchState(new StoryMenuState());
                else FlxG.switchState(new FreeplayState());
    
        }
	}

    if(controls.BACK){
        cleanupPause();
        close();
        FlxG.sound.play(Paths.sound("unpause"), 0.7);
    }

    var shiftMult:Int = 1;
    if (controls.UP_P) {
        changePSelection(-1);
    }
    if (controls.DOWN_P) {
        changePSelection(1);
    }

    if(FlxG.mouse.wheel != 0)
    {
        changePSelection(-shiftMult * FlxG.mouse.wheel, false);
    }

    for (item in pauseItemTexts) {
        if (item.ID == curPSelected) {
            item.alpha = 1; 

        } else {
            item.alpha = 0.65;

        }
    }
}

function changePSelection(change:Int = 0, playSound:Bool = true)
{
    if (playSound) FlxG.sound.play(Paths.sound('menu/scroll'), 0.5);
    curPSelected += change;

    if (curPSelected < 0)
        curPSelected = pauseItems.length - 1;

    if (curPSelected >= pauseItems.length)
        curPSelected = 0;

    var selectedItem:FlxSprite = pauseItemTexts[curPSelected];

    FlxTween.cancelTweensOf(itemCursor);

    itemCursor.y = selectedItem.y + 30;

    itemCursor.x = selectedItem.x + 470;
    FlxTween.tween(itemCursor, {x: selectedItem.x + 50}, 0.5, {ease: FlxEase.quadOut});
}

function cleanupPause() {
    if (filter != null) {
        FlxG.camera.removeShader(filter);
        if (pauseShaderCam != null) pauseShaderCam.removeShader(filter);
        pauseShaderCam = null;
        filter = null;
    }

    if (pauseText != null) FlxTween.cancelTweensOf(pauseText);
    if (itemCursor != null) FlxTween.cancelTweensOf(itemCursor);
    for (item in pauseItemTexts)
        if (item != null) FlxTween.cancelTweensOf(item);
    pauseItemTexts = [];

    if (pauseCam != null) {
        if (FlxG.cameras.list.indexOf(pauseCam) != -1)
            FlxG.cameras.remove(pauseCam, true);
        pauseCam = null;
    }
}

function destroy() cleanupPause();
