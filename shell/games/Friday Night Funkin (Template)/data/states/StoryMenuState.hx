// Scripted port of funkin.menus.StoryMenuState, loaded via ModState + [StateRedirects] in this
// game's game.ini instead of the compiled engine class. See StoryMenuState.hx in the engine
// source for the original this was ported from - keep them in sync if you change one.
//
// The original's MenuItem class (extends FlxSprite, its own per-item update() for the y-lerp and
// selection flash) didn't come along: hscript's custom-class support (CustomClassHandler) makes
// Reflect-style proxy objects, not real compiled FlxSprite subclasses, and FlxTypedGroup's native
// iteration isn't guaranteed to accept those. weekSprites is a plain FlxTypedGroup<FlxSprite>
// instead, with the per-item y-lerp driven from this script's own update() against a parallel
// weekTargetY array (indexed the same as weekSprites.members), and the one-at-a-time selection
// flash tracked with flashingSprite/flashTime instead of a per-item isFlashing/time pair. The
// original's StoryWeeklist class (no inheritance, so actually safe to port as a real hscript
// class) was inlined into loadWeekList() instead since nothing outside loadXMLs() ever read the
// weekList field itself - only weeks.

import flixel.text.FlxText.FlxTextAlign;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import funkin.backend.utils.CoolSfx;
import funkin.backend.utils.FlxInterpolateColor;
import funkin.backend.utils.DiscordUtil;
import funkin.backend.scripting.EventManager;
import funkin.backend.scripting.events.CancellableEvent;
import funkin.backend.scripting.events.menu.MenuChangeEvent;
import funkin.backend.scripting.events.menu.storymenu.WeekSelectEvent;
import funkin.backend.week.Week;
import funkin.savedata.FunkinSave;
import funkin.backend.system.Logs;
import haxe.io.Path;

import funkin.backend.utils.TranslationUtil as TU;

var characters:Map<String, Dynamic> = [];
var weeks:Array<Dynamic> = [];

var scoreText:FlxText;
var tracklist:FlxText;
var weekTitle:FlxText;

var curDifficulty = 0;
var curWeek = 0;

var difficultySprites:Map<String, FlxSprite> = [];
var leftArrow:FlxSprite;
var rightArrow:FlxSprite;
var blackBar:FlxSprite;

var weekBG:FlxSprite;
var interpColor:FlxInterpolateColor;

var lerpScore:Float = 0;
var intendedScore = 0;

var canSelect = true;

var weekSprites:FlxTypedGroup<FlxSprite>;
var weekTargetY:Array<Float> = [];
var flashingSprite:FlxSprite = null;
var flashTime:Float = 0;

var characterSprites:FlxTypedGroup<FunkinSprite>;

function create() {
	loadXMLs();
	persistentUpdate = persistentDraw = true;

	// WEEK INFO
	blackBar = new FlxSprite(0, 0).makeSolid(FlxG.width, 56, 0xFFFFFFFF);
	blackBar.color = 0xFF000000;
	blackBar.updateHitbox();

	scoreText = new FunkinText(10, 10, 0, TU.translate("story.score", ["-"]), 36);
	scoreText.setFormat(Paths.font("vcr.ttf"), 32);

	weekTitle = new FlxText(10, 10, FlxG.width - 20, "", 32);
	weekTitle.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, FlxTextAlign.RIGHT);
	weekTitle.alpha = 0.7;

	weekBG = new FlxSprite(0, 56).makeSolid(FlxG.width, 400, 0xFFFFFFFF);
	weekBG.color = weeks.length > 0 ? weeks[0].bgColor : Flags.DEFAULT_WEEK_COLOR;
	weekBG.updateHitbox();

	weekSprites = new FlxTypedGroup<FlxSprite>();

	// DUMBASS ARROWS
	var assets = Paths.getFrames('menus/storymenu/assets');
	var directions = ["left", "right"];

	leftArrow = new FlxSprite((FlxG.width + 400) / 2, weekBG.y + weekBG.height + 10 + 10);
	rightArrow = new FlxSprite(FlxG.width - 10, weekBG.y + weekBG.height + 10 + 10);
	for (k => arrow in [leftArrow, rightArrow]) {
		var dir = directions[k];

		arrow.frames = assets;
		arrow.animation.addByPrefix('idle', 'arrow $dir');
		arrow.animation.addByPrefix('press', 'arrow push $dir', 24, false);
		arrow.animation.play('idle');
		arrow.antialiasing = true;
		add(arrow);
	}
	rightArrow.x -= rightArrow.width;

	tracklist = new FunkinText(16, weekBG.y + weekBG.height + 44, Std.int(((FlxG.width - 400) / 2) - 80), TU.translate("story.tracks"), 32);
	tracklist.alignment = FlxTextAlign.CENTER;
	tracklist.color = 0xFFE55777;

	add(weekSprites);
	for (e in [blackBar, scoreText, weekTitle, weekBG, tracklist]) {
		e.scrollFactor.set();
		add(e);
	}

	characterSprites = new FlxTypedGroup<FunkinSprite>();
	add(characterSprites);

	for (i => week in weeks) {
		var spr = makeMenuItem(0, (i * 120) + 480, 'menus/storymenu/weeks/${week.sprite}');
		weekSprites.add(spr);
		weekTargetY[i] = 0;

		for (e in week.difficulties) {
			var le = e.toLowerCase();
			if (difficultySprites[le] == null) {
				var diffSprite = new FlxSprite(leftArrow.x + leftArrow.width, leftArrow.y);
				CoolUtil.loadAnimatedGraphic(diffSprite, Paths.image('menus/storymenu/difficulties/${le}'));
				CoolUtil.setUnstretchedGraphicSize(diffSprite, Std.int(rightArrow.x - leftArrow.x - leftArrow.width), Std.int(leftArrow.height), false, 1);
				diffSprite.antialiasing = true;
				diffSprite.scrollFactor.set();
				add(diffSprite);

				difficultySprites[le] = diffSprite;
			}
		}
	}

	interpColor = new FlxInterpolateColor(weekBG.color);

	// default difficulty should be the middle difficulty in the array
	curDifficulty = Math.floor(weeks[0].difficulties.length * 0.5);
	Logs.trace('Middle Difficulty for Week 1 is ${weeks[0].difficulties[curDifficulty]} (ID: $curDifficulty)');

	changeWeek(0, true);

	DiscordUtil.call("onMenuLoaded", ["Story Menu"]);
	CoolUtil.playMenuSong();
}

function makeMenuItem(x:Float, y:Float, path:String) {
	var spr = new FlxSprite(x, y);
	CoolUtil.loadAnimatedGraphic(spr, Paths.image(path, null, true));
	spr.screenCenter(FlxAxes.X);
	spr.antialiasing = true;
	return spr;
}

var __lastDifficultyTween:FlxTween;

function update(elapsed) {
	lerpScore = lerp(lerpScore, intendedScore, 0.5);
	scoreText.text = TU.translate("story.score", [Math.round(lerpScore)]);

	for (k => spr in weekSprites.members)
		spr.y = CoolUtil.fpsLerp(spr.y, (weekTargetY[k] * 120) + 480, 0.17);

	if (flashingSprite != null) {
		flashTime += elapsed;
		flashingSprite.color = (flashTime % 0.1 > 0.05) ? FlxColor.WHITE : 0xFF33ffff;
	}

	if (canSelect) {
		if (leftArrow != null && leftArrow.exists) leftArrow.animation.play(controls.LEFT ? 'press' : 'idle');
		if (rightArrow != null && rightArrow.exists) rightArrow.animation.play(controls.RIGHT ? 'press' : 'idle');

		if (controls.BACK || FlxG.mouse.justPressedRight) {
			goBack();
		}

		changeDifficulty((controls.LEFT_P ? -1 : 0) + (controls.RIGHT_P ? 1 : 0));
		changeWeek((controls.UP_P ? -1 : 0) + (controls.DOWN_P ? 1 : 0) - FlxG.mouse.wheel);

		if (FlxG.mouse.justPressed) {
			if (leftArrow != null && leftArrow.exists && FlxG.mouse.overlaps(leftArrow)) {
				leftArrow.animation.play('press');
				changeDifficulty(-1);
			} else if (rightArrow != null && rightArrow.exists && FlxG.mouse.overlaps(rightArrow)) {
				rightArrow.animation.play('press');
				changeDifficulty(1);
			} else if (weekSprites.members[curWeek] != null && FlxG.mouse.overlaps(weekSprites.members[curWeek])) {
				selectWeek();
			} else if (weekSprites.members[curWeek + 1] != null && FlxG.mouse.overlaps(weekSprites.members[curWeek + 1])) {
				changeWeek(1);
			}
		}

		if (controls.ACCEPT)
			selectWeek();
	} else {
		for (e in [leftArrow, rightArrow])
			if (e != null && e.exists)
				e.animation.play('idle');
	}

	interpColor.fpsLerpTo(weeks[curWeek].bgColor, 0.0625);
	weekBG.color = interpColor.color;
}

// IBeatReceiver dispatch to members already happened before this fires - see
// MusicBeatState.beatHit()'s call("beatHit", ...).
function beatHit(curBeat) {
	if (characterSprites != null)
		characterSprites.forEachAlive(function(spr) {
			spr.beatHit(curBeat);
		});
}

function goBack() {
	var evt = event("onGoBack", new CancellableEvent());
	if (!evt.cancelled)
		FlxG.switchState(new MainMenuState());
}

function changeWeek(change:Int, force = false) {
	if (change == 0 && !force) return;

	var evt = event("onChangeWeek", EventManager.get(MenuChangeEvent).recycle(curWeek, FlxMath.wrap(curWeek + change, 0, weeks.length - 1), change));
	if (evt.cancelled) return;
	curWeek = evt.value;

	if (!force) CoolUtil.playMenuSFX();
	for (k => e in weekSprites.members) {
		weekTargetY[k] = k - curWeek;
		e.alpha = k == curWeek ? 1.0 : 0.6;
	}
	tracklist.text = '${TU.translate("story.tracks")}\n\n${[for (e in weeks[curWeek].songs) if (!e.hide) (e.displayName != null ? e.displayName : e.name).toUpperCase()].join('\n')}';
	weekTitle.text = weeks[curWeek].name != null ? weeks[curWeek].name : "";

	if (characterSprites != null) for (i in 0...3) {
		var char = weeks[curWeek].chars[i];
		var curChar:FunkinSprite = characterSprites.members[i];
		var newChar = char == null ? null : characters[char.name];

		if (char == null || newChar == null) modifyCharacterAt(i);
		else if (curChar == null || newChar.name != curChar.name) modifyCharacterAt(i, newChar);
	}

	changeDifficulty(0, true);

	MemoryUtil.clearMinor();
}

var __oldDiffName:String = null;

function changeDifficulty(change:Int, force = false) {
	if (change == 0 && !force) return;

	var evt = event("onChangeDifficulty", EventManager.get(MenuChangeEvent).recycle(curDifficulty, FlxMath.wrap(curDifficulty + change, 0, weeks[curWeek].difficulties.length - 1), change));
	if (evt.cancelled) return;
	curDifficulty = evt.value;

	var newDiffName = weeks[curWeek].difficulties[curDifficulty].toLowerCase();
	if (__oldDiffName != newDiffName) {
		__oldDiffName = newDiffName;

		for (e in difficultySprites) e.visible = false;

		var diffSprite = difficultySprites[__oldDiffName];
		if (diffSprite != null) {
			diffSprite.visible = true;

			if (__lastDifficultyTween != null)
				__lastDifficultyTween.cancel();
			diffSprite.alpha = 0;
			diffSprite.y = leftArrow.y - 15;

			__lastDifficultyTween = FlxTween.tween(diffSprite, {y: leftArrow.y, alpha: 1}, 0.07);
		}
	}

	intendedScore = FunkinSave.getWeekHighscore(weeks[curWeek].id, weeks[curWeek].difficulties[curDifficulty]).score;
}

function loadXMLs() {
	weeks = loadWeekList(true, false); // will only load week files AND NOT characters too (we will load them later only if needed)!!
	for (week in weeks) for (char in week.chars) if (char != null)
		addCharacter(char.name);
}

function loadWeekList(useTxt = true, loadCharactersData = true) {
	var foundWeeks:Array<Dynamic> = [];

	var loadFromSource = function(source, useTxt, loadCharactersData) {
		var path = Paths.txt('weeks/weeks');
		var weeksFound:Array<String> = useTxt && Paths.assetsTree.existsSpecific(path, "TEXT", source) ? CoolUtil.coolTextFile(path) :
			[for (c in Paths.getFolderContent('data/weeks/weeks/', false, source)) if (Path.extension(c).toLowerCase() == "xml") Path.withoutExtension(c)];

		if (weeksFound.length > 0) {
			for (w in weeksFound) {
				var week = Week.loadWeek(w, loadCharactersData);
				if (week != null) foundWeeks.push(week);
			}
			return false;
		}
		return true;
	};

	switch (Flags.WEEKS_LIST_MOD_MODE) {
		case 'prepend':
			loadFromSource(1, useTxt, loadCharactersData);
			loadFromSource(0, useTxt, loadCharactersData);
		case 'append':
			loadFromSource(0, useTxt, loadCharactersData);
			loadFromSource(1, useTxt, loadCharactersData);
		default: // case 'override'
			if (loadFromSource(1, useTxt, loadCharactersData))
				loadFromSource(0, useTxt, loadCharactersData);
	}

	return foundWeeks;
}

function addCharacter(char:Dynamic) {
	var charObj = null;
	var charName:String;

	if (Std.isOfType(char, String)) {
		charName = cast char;
	} else {
		charObj = cast char;
		charName = charObj.name;
	}

	if (characters[charName] != null) return; // will load only if it can be saved inside the map
	characters[charName] = charObj == null ? Week.loadWeekCharacter(charName) : charObj;
}

function modifyCharacterAt(i:Int, ?data):FunkinSprite {
	var curChar:FunkinSprite = null;

	if (characterSprites != null) {
		var old = characterSprites.members[i];
		if (old != null) {
			characterSprites.remove(old);
			old.destroy();
		}

		if (data != null) {
			curChar = XMLUtil.loadSpriteFromXML(new FunkinSprite(), data.xml, "", 1, true); // 1 = XMLAnimType.BEAT
			curChar.offset.x += curChar.x; curChar.offset.y += curChar.y;
			curChar.setPosition((FlxG.width * 0.25) * (1 + i) - 150, 70);
			curChar.playAnim("idle", true, "DANCE");
			characterSprites.insert(i, curChar);
		} else {
			characterSprites.insert(i, new FunkinSprite()).visible = false;
		}
	}
	return curChar;
}

function selectWeek() {
	var evt = event("onWeekSelect", EventManager.get(WeekSelectEvent).recycle(weeks[curWeek], weeks[curWeek].difficulties[curDifficulty], curWeek, curDifficulty));
	if (evt.cancelled) return;

	canSelect = false;
	CoolUtil.playMenuSFX(CoolSfx.CONFIRM);

	if (characterSprites != null)
		characterSprites.forEachAlive(function(spr) {
			spr.playAnim("confirm", true, "LOCK");
		});

	PlayState.loadWeek(evt.week, evt.difficulty);

	new FlxTimer().start(1, function(tmr) {
		FlxG.switchState(new PlayState());
	});

	flashingSprite = weekSprites.members[evt.weekID];
	flashTime = 0;
}
