// Scripted port of funkin.menus.MainMenuState, loaded via ModState + [StateRedirects] in
// this game's game.ini instead of the compiled engine class. See MainMenuState.hx in the
// engine source for the original this was ported from - keep them in sync if you change one.
//
// Everything the compiled class had as a class field becomes a top-level `var` here, and every
// method becomes a top-level `function`. Lifecycle hooks (create/update/onStateSwitch) are
// called automatically by the host MusicBeatState - see MusicBeatState.hx's call()/event() use.

import flixel.FlxObject;
import flixel.effects.FlxFlicker;
import flixel.text.FlxText.FlxTextAlign;
import funkin.backend.scripting.EventManager;
import funkin.backend.scripting.events.NameEvent;
import funkin.backend.scripting.events.menu.MenuChangeEvent;
import funkin.backend.utils.CoolSfx;
import funkin.backend.utils.DiscordUtil;
import funkin.backend.system.Control;
import funkin.editors.EditorPicker;
import funkin.menus.GamesMenu;
import funkin.menus.CideWarning;
import funkin.menus.CideWarningSubstate;
import funkin.menus.credits.CreditsMain;
import funkin.options.OptionsMenu;

var curSelected = 0;
var menuItems:FlxTypedGroup<FlxSprite>;
var optionShit = CoolUtil.coolTextFile(Paths.txt("config/menuItems"));

var bg:FlxSprite;
var magenta:FlxSprite;
var camFollow:FlxObject;
var versionText:FunkinText;

var devModeWarning:FunkinText;

// Main.isReleaseShell is a real runtime value (not a preprocessor flag scripts can't see),
// so a release-shell export of this game keeps the same lockout the compiled class has.
var canAccessDebugMenus = !Main.isReleaseShell && !Flags.DISABLE_EDITORS;

var selectedSomethin = false;
var forceCenterX = true;
var devModeCount = 0;

function create() {
	DiscordUtil.call("onMenuLoaded", ["Main Menu"]);

	CoolUtil.playMenuSong();

	bg = new FlxSprite(-80);
	CoolUtil.loadAnimatedGraphic(bg, Paths.image('menus/menuBG'));
	add(bg);

	camFollow = new FlxObject(0, 0, 1, 1);
	add(camFollow);

	magenta = new FlxSprite(-80);
	CoolUtil.loadAnimatedGraphic(magenta, Paths.image('menus/menuDesat'));
	magenta.visible = false;
	magenta.color = 0xFFfd719b;
	add(magenta);

	for (bgSpr in [bg, magenta]) {
		bgSpr.scrollFactor.set(0, 0.18);
		bgSpr.scale.set(1.15, 1.15);
		bgSpr.updateHitbox();
		bgSpr.screenCenter();
		bgSpr.antialiasing = true;
	}

	menuItems = new FlxTypedGroup<FlxSprite>();
	add(menuItems);

	for (i => option in optionShit) {
		var menuItem = new FlxSprite(0, 60 + (i * 160));
		menuItem.frames = Paths.getFrames('menus/mainmenu/${option}');
		menuItem.animation.addByPrefix('idle', option + " basic", 24);
		menuItem.animation.addByPrefix('selected', option + " white", 24);
		menuItem.animation.play('idle');
		menuItem.ID = i;
		menuItem.screenCenter(FlxAxes.X);
		menuItems.add(menuItem);
		menuItem.scrollFactor.set();
		menuItem.antialiasing = true;
	}

	FlxG.camera.follow(camFollow, null, 0.06);

	var openGamesLine = Main.isReleaseShell ? '' : TranslationUtil.translate("mainMenu.openMods", [controls.getKeyName(Control.SWITCHMOD)]);

	versionText = new FunkinText(5, FlxG.height - 2, 0, [
		Flags.VERSION_MESSAGE,
		TranslationUtil.translate("mainMenu.commit", [Flags.COMMIT_NUMBER, Flags.COMMIT_HASH]),
		openGamesLine,
		''
	].join('\n'));
	versionText.y -= versionText.height;
	versionText.scrollFactor.set();
	add(versionText);

	changeItem();

	devModeWarning = new FunkinText(0, FlxG.height - 50, 1280, "You have to enable DEVELOPER MODE in the Editor Options (Games menu)!", 24);
	devModeWarning.alignment = FlxTextAlign.CENTER;
	add(devModeWarning);
	devModeWarning.scrollFactor.set();
	devModeWarning.alpha = 0;
}

function update(elapsed) {
	if (FlxG.sound.music.volume < 0.8)
		FlxG.sound.music.volume += 0.5 * elapsed;

	if (!selectedSomethin) {
		if (canAccessDebugMenus) {
			if (controls.DEV_ACCESS) {
				persistentUpdate = false;
				persistentDraw = true;
				openSubState(new EditorPicker());
			}
		} else if (Main.isReleaseShell && !Flags.DISABLE_EDITORS && controls.DEV_ACCESS) {
			// Pressing the editor key in a release build: explain instead of doing nothing.
			persistentUpdate = false;
			persistentDraw = true;
			openSubState(new CideWarningSubstate(CideWarning.releaseMessage()));
		}
		if (!Options.devMode && !Main.isReleaseShell && FlxG.keys.justPressed.SEVEN) {
			FlxG.sound.play(Paths.sound(Flags.DEFAULT_EDITOR_DELETE_SOUND));
			if (devModeCount++ == 2) {
				FlxTween.tween(devModeWarning, {alpha: 1}, 0.4);
			}
			FlxTween.completeTweensOf(devModeWarning);
			FlxTween.color(devModeWarning, 0.2, 0xFFFF0000, 0xFFFFFFFF);
			FlxTween.shake(devModeWarning, 0.005, 0.3);
			devModeWarning.y = FlxG.height - 75;
			FlxTween.tween(devModeWarning, {y: FlxG.height - 50}, 0.4);
		}

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var scroll = FlxG.mouse.wheel;

		if (upP || downP || scroll != 0)
			changeItem((upP ? -1 : 0) + (downP ? 1 : 0) - scroll);

		if (controls.BACK)
			FlxG.switchState(new TitleState());

		if (!Main.isReleaseShell && (controls.SWITCHMOD || (FlxG.mouse.justPressed && versionText != null && FlxG.mouse.overlaps(versionText)))) {
			selectedSomethin = true;
			CoolUtil.playMenuSFX(CoolSfx.CONFIRM);
			FlxG.switchState(new GamesMenu());
		}

		if (controls.ACCEPT)
			selectItem();

		if (FlxG.mouse.justPressed && menuItems != null) {
			for (index => sprite in menuItems.members) {
				if (FlxG.mouse.overlaps(sprite)) {
					if (curSelected != index) changeItem(index - curSelected);
					else selectItem();
					break;
				}
			}
		}
	}

	if (forceCenterX && menuItems != null) {
		menuItems.forEach(function(spr) {
			spr.screenCenter(FlxAxes.X);
		});
	}
}

// Fired via MusicBeatState's own "onStateSwitch" cancellable event (see switchTo() in
// MusicBeatState.hx) - the compiled class overrode switchTo() directly, but ModState has
// nothing of its own to override, so this is the equivalent hook for the fade-out.
function onStateSwitch(evt) {
	menuItems.forEach(function(spr) {
		FlxTween.tween(spr, {alpha: 0}, 0.5, {ease: FlxEase.quintOut});
	});
}

function selectItem() {
	selectedSomethin = true;
	CoolUtil.playMenuSFX(CoolSfx.CONFIRM);

	if (Options.flashingMenu) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

	FlxFlicker.flicker(menuItems.members[curSelected], 1, Options.flashingMenu ? 0.06 : 0.15, false, false, function(flick) {
		var daChoice = optionShit[curSelected];

		var evt = event("onSelectItem", EventManager.get(NameEvent).recycle(daChoice));
		if (evt.cancelled) return;
		switch (evt.name) {
			case 'story mode': FlxG.switchState(new StoryMenuState());
			case 'freeplay': FlxG.switchState(new FreeplayState());
			case 'donate', 'credits': FlxG.switchState(new CreditsMain());
			case 'options': FlxG.switchState(new OptionsMenu());
		}
	});
}

function changeItem(huh = 0) {
	var evt = event("onChangeItem", EventManager.get(MenuChangeEvent).recycle(curSelected, FlxMath.wrap(curSelected + huh, 0, menuItems.length - 1), huh, huh != 0));
	if (evt.cancelled) return;

	curSelected = evt.value;

	if (evt.playMenuSFX)
		CoolUtil.playMenuSFX(CoolSfx.SCROLL, 0.7);

	menuItems.forEach(function(spr) {
		spr.animation.play('idle');

		if (spr.ID == curSelected) {
			spr.animation.play('selected');
			var mid = spr.getGraphicMidpoint();
			camFollow.setPosition(mid.x, mid.y);
			mid.put();
		}

		spr.updateHitbox();
		spr.centerOffsets();
	});
}
