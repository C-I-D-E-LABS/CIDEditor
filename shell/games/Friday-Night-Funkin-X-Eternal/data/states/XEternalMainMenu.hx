import flixel.addons.display.FlxBackdrop;
import flixel.effects.FlxFlicker;
import flixel.text.FlxTextBorderStyle;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import funkin.editors.EditorPicker;
import funkin.options.OptionsMenu;
import flixel.tweens.FlxTweenType;
import OptionsData;
var shader = null;
var camBelow = null;
var camAbove = null;

var freeplayLocked:Bool = (FlxG.save.data.songsBeaten == null ? 0 : FlxG.save.data.songsBeaten) < 3;

var transitioning:Bool = false;
var grpMenuItems:FlxTypedGroup<FlxSpriteGroup>;
var menuBoxes:Array<FlxSprite> = [];
static var curSelectedA:Int = 0;

var menuLabels:Array<String> = ["Story Mode", "Sound Test", "Freeplay", "Options", "Extras"];
var lockedMenuItems:Array<Int> = [1, 2, 4];
var debugUnlockTxt:FlxText;
var downArrow:FlxText;

var itemSpacingY:Float = 105;
var menuStartY:Float = 195;
var visibleSlots:Int = 4;
var itemFixedX:Float = 830;

function create() {
    FlxG.mouse.visible = true;
    freeplayLocked = (FlxG.save.data.songsBeaten == null ? 0 : FlxG.save.data.songsBeaten) < 3;

    for (sound in ['menu/scroll', 'menu/confirm', 'menu/denied'])
        FlxG.sound.cache(Paths.sound(sound));
    for (asset in [
        'menus/storymode/bgclouds', 'exe/tt-stage/x/Static',
        'menus/mainmenu/menuGraphic', 'menus/TitleScreen/logo',
        'menus/mainmenu/barDOWN', 'menus/mainmenu/barUP',
        'menus/mainmenu/menu_box', 'effects/heatwave'
    ])
        graphicCache.cache(Paths.image(asset));

    var boxAssetPath:String = Paths.image('menus/mainmenu/menu_box');

    camBelow = new FlxCamera();
    camAbove = new FlxCamera();
    for (cam in [camBelow, camAbove]) {
        cam.bgColor = new FlxColor(0x00000000);
        FlxG.cameras.add(cam, false);
    }

    window.title = windowTitle + " - MainMenu";
    shader = new CustomShader("lineBoil");
    shader.data.distortTexture.input = Assets.getBitmapData(Paths.image('effects/heatwave'));
    shader.INTENSITY = 0.006;

    Conductor.changeBPM(160);
    FlxG.sound.playMusic(Paths.music('menus/main'), 0);
    FlxG.sound.music.fadeIn(5, 0, 0.7);

    wall = new FlxBackdrop(Paths.image('menus/storymode/bgclouds'), FlxAxes.X);
    wall.scale.y = 0.5;
    wall.scale.x = 0.5;
    add(wall);
    wall.alpha = 1;
    wall.velocity.x -= 30;
    wall.y -= 500;

    bg = new FlxBackdrop(null, FlxAxes.XY, 0, 0);
	bg.frames = Paths.getSparrowAtlas('exe/tt-stage/x/Static');
	bg.animation.addByPrefix('skyAnim', 'Static', 12, true);
	bg.animation.play('skyAnim');
    bg.alpha = 0.4;
    bg.updateHitbox();
    add(bg);

    menuGraphic = new FlxSprite(400,-100).loadGraphic(Paths.image('menus/mainmenu/menuGraphic'));
	menuGraphic.antialiasing = true;
    menuGraphic.scale.set(0.7, 0.85);
	add(menuGraphic);
    if (shader != null) menuGraphic.shader = shader;

    logo = new FlxSprite(-2170, -1200).loadGraphic(Paths.image('menus/TitleScreen/logo'));
	logo.antialiasing = true;
    logo.scale.set(0.13, 0.13);
	add(logo);
    FlxTween.tween(logo, {y: logo.y - 30}, 2.5, {ease: FlxEase.sineInOut, type: FlxTweenType.PINGPONG});

    mainMenuTxt= new FlxText(-110, 65, FlxG.width, "MAIN MENU",  60);
    mainMenuTxt.setFormat(Paths.font('sonic-cd-menu-font.ttf'), 40, 0xffffff, "right", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    mainMenuTxt.borderSize = 2;
    add(mainMenuTxt);

    versionTxt= new FlxText(23, 680, FlxG.width, "X-Eternal: v2",  0);
    versionTxt.setFormat(null, 20, 0xffffff, "left", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    versionTxt.borderSize = 2;
    versionTxt.camera = camAbove;
    add(versionTxt);

    debugUnlockTxt = new FlxText(0, 555, FlxG.width, "Hahah you unlock the secret debug mode.\n\nwhat, do you want a medal?", 26);
    debugUnlockTxt.setFormat(Paths.font('sonic-cd-menu-font.ttf'), 26, 0xFFFFFFFF, "center", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    debugUnlockTxt.borderSize = 3;
    debugUnlockTxt.scrollFactor.set();
    debugUnlockTxt.alpha = 0;
    add(debugUnlockTxt);

    downArrow = new FlxText(itemFixedX + 135, menuStartY + itemSpacingY * visibleSlots - 10, 80, ">");
    downArrow.setFormat(Paths.font("sonic3TitleCard"), 68, FlxColor.WHITE, "center");
    downArrow.angle = 90;
    downArrow.scrollFactor.set();
    downArrow.visible = false;
    add(downArrow);

    grpMenuItems = new FlxTypedGroup();
    add(grpMenuItems);
    menuBoxes = [];

    var bmd = Assets.getBitmapData(boxAssetPath);
    var frameW:Int = bmd.width;
    var frameH:Int = Std.int(bmd.height / 2);

    for (i in 0...menuLabels.length) {
        var itemGroup:FlxSpriteGroup = new FlxSpriteGroup();
        itemGroup.ID = i;

        var box:FlxSprite = new FlxSprite();
        box.loadGraphic(boxAssetPath, true, frameW, frameH);
        box.animation.add('idle', [0], 0, false);
        box.animation.add('selected', [1], 0, false);
        box.animation.play('idle');
        itemGroup.add(box);
        menuBoxes.push(box);

        var label:FlxText = new FlxText(0, 0, frameW, menuLabels[i], 32);
        label.setFormat(Paths.font('sonic-cd-menu-font.ttf'), 22, 0xFFFFFFFF, "center", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        label.borderSize = 2;
        label.y = (frameH - label.height) / 2;
        itemGroup.add(label);

        itemGroup.x = itemFixedX;
        grpMenuItems.add(itemGroup);
    }

    if (freeplayLocked && lockedMenuItems.contains(curSelectedA))
        curSelectedA = 0;

    updateMenuPositions(true);
    refreshLockedItems();

    for (i in [wall, bg, menuGraphic, logo]) i.camera = camBelow;
    for (i in [mainMenuTxt, grpMenuItems, debugUnlockTxt, downArrow]) i.camera = camAbove;
}

function updateMenuPositions(instant:Bool = false) {
    var total:Int = menuLabels.length;

    var scrollOffset:Int = Std.int(Math.max(0, Math.min(curSelectedA - (visibleSlots - 1), total - visibleSlots)));
    if (curSelectedA < scrollOffset) scrollOffset = curSelectedA;

    for (item in grpMenuItems.members) {
        var slot:Int = item.ID - scrollOffset;
        var isVisible:Bool = slot >= 0 && slot < visibleSlots;
        var isLocked:Bool = freeplayLocked && lockedMenuItems.contains(item.ID);

        var targetY:Float = menuStartY + slot * itemSpacingY;
        var targetAlpha:Float = isVisible ? (isLocked ? 0.6 : 1.0) : 0.0;

        item.x = itemFixedX;

        FlxTween.cancelTweensOf(item);

        if (instant) {
            item.y = targetY;
            item.alpha = targetAlpha;
            item.visible = isVisible;
        } else {
            if (isVisible) item.visible = true;
            FlxTween.tween(item, {y: targetY, alpha: targetAlpha}, 0.2, {
                ease: FlxEase.quadOut,
                onComplete: (_) -> if (!isVisible) item.visible = false
            });
        }

        var box:FlxSprite = menuBoxes[item.ID];
        box.animation.play(item.ID == curSelectedA ? 'selected' : 'idle');
    }
}

function changeSelection(change:Int = 0) {
    if (change == 0) return;

    var dir:Int = change > 0 ? 1 : -1;
    var steps:Int = change < 0 ? -change : change;

    for (_ in 0...steps) {
        var tries:Int = 0;
        do {
            curSelectedA += dir;
            if (curSelectedA < 0) curSelectedA = menuLabels.length - 1;
            if (curSelectedA >= menuLabels.length) curSelectedA = 0;
            tries++;
        } while (freeplayLocked && lockedMenuItems.contains(curSelectedA) && tries < menuLabels.length);
    }

    updateMenuPositions();
}

var localTime:Float = 0;
var shiftMult:Int = 1;
function update(e) {
    localTime += e;
    if (shader != null) shader.iTime = localTime;

    camBelow.scroll.x = FlxMath.lerp(camBelow.scroll.x, (FlxG.mouse.screenX - FlxG.width / 2) * -0.03, FlxMath.bound(e * 4, 0, 1));
    camBelow.scroll.y = FlxMath.lerp(camBelow.scroll.y, (FlxG.mouse.screenY - FlxG.height / 2) * -0.02, FlxMath.bound(e * 4, 0, 1));

    if(!transitioning){
        var mouseAccept:Bool = false;

        downArrow.visible = !freeplayLocked && curSelectedA == 3;
        downArrow.alpha = downArrow.visible && FlxG.mouse.overlaps(downArrow) ? 1 : 0.6;

        if (downArrow.visible && FlxG.mouse.overlaps(downArrow)) {
            curSelectedA = 4;
            FlxG.sound.play(Paths.sound('menu/scroll'), 1);
            updateMenuPositions();
        }

        for (item in grpMenuItems.members)
            if (item != null && item.visible && item.alpha > 0.2) {
                var overItem:Bool = FlxG.mouse.screenX >= item.x && FlxG.mouse.screenX <= item.x + menuBoxes[item.ID].width &&
                    FlxG.mouse.screenY >= item.y && FlxG.mouse.screenY <= item.y + menuBoxes[item.ID].height;

                if (overItem && !(freeplayLocked && lockedMenuItems.contains(item.ID))) {
                    if (item.ID != curSelectedA) {
                        curSelectedA = item.ID;
                        FlxG.sound.play(Paths.sound('menu/scroll'), 1);
                        updateMenuPositions();
                    }
                    if (FlxG.mouse.justPressed) mouseAccept = true;
                }
            }

        if (FlxG.keys.justPressed.P)
            unlockDebugMode();

        if(controls.ACCEPT || mouseAccept){
            if (freeplayLocked && lockedMenuItems.contains(curSelectedA)) {
                FlxG.sound.play(Paths.sound('menu/denied'),0.6);
                for (cam in [camBelow, camAbove])
                    if (cam != null) cam.shake(0.01, 0.15);
                return;
            }
            FlxTween.tween(FlxG.sound.music, {volume: 0}, 1.0);
            transitioning = true;
            FlxG.sound.play(Paths.sound('menu/confirm'),0.6);
            for (item in grpMenuItems.members) {
                FlxTween.cancelTweensOf(item);
                if (item.ID != curSelectedA)
                    FlxTween.tween(item, {alpha: 0}, 0.65, {ease: FlxEase.quadOut});
            }
            FlxFlicker.flicker(grpMenuItems.members[curSelectedA], 1, 0.06, false, false);
            new FlxTimer().start(1, (_) -> {
                switch(curSelectedA) {
                    case 0: FlxG.switchState(new StoryMenuState());
                    case 1: FlxG.switchState(new GameState("XEternalSoundTest"));
                    case 2: FlxG.switchState(new FreeplayState());
                    case 3: 
                        FlxG.save.data.optionsReturnState = "menu";
                        FlxG.save.flush();                
                        FlxG.switchState(new GameState("XEternalOptions"));
                        FlxG.switchState(new OptionsMenu()); 
                    case 4: FlxG.switchState(new GameState("XEternalExtras"));
                }
            });
        }

        shiftMult = FlxG.keys.pressed.SHIFT ? 3 : 1;

        if (controls.UP_P || controls.DOWN_P) {
            FlxG.sound.play(Paths.sound('menu/scroll'), 1);
            changeSelection(controls.UP_P ? -shiftMult : shiftMult);
        }

        if(FlxG.mouse.wheel != 0){
            FlxG.sound.play(Paths.sound('menu/scroll'), 1);
            changeSelection(-shiftMult * FlxG.mouse.wheel);
        }

        if (controls.BACK)FlxG.switchState(new GameState("XEternalTitleMenu"));
    }


}

function refreshLockedItems() {
    for (i in lockedMenuItems) {
        var g = grpMenuItems.members[i];
        g.color = freeplayLocked ? 0xFF3D3D3D : 0xFFFFFFFF;
        g.alpha = g.visible ? (freeplayLocked ? 0.6 : 1.0) : 0.0;
    }
}

function destroy() {
    if (menuGraphic != null) menuGraphic.shader = null;
    shader = null;

    for (cam in [camBelow, camAbove])
        if (cam != null && FlxG.cameras.list.indexOf(cam) != -1)
            FlxG.cameras.remove(cam, true);

    camBelow = null;
    camAbove = null;
}
