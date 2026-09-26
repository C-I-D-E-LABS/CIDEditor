// Scripted port of funkin.menus.TitleState, loaded via ModState + [StateRedirects] in this
// game's game.ini instead of the compiled engine class. See TitleState.hx in the engine
// source for the original this was ported from - keep them in sync if you change one.
//
// The nested IntroText class from the original couldn't come along as-is: its show() method
// cast(FlxG.state, TitleState) to reach back into the state, but FlxG.state is a ModState here,
// not a TitleState. titleLines is now Map<Int, Array<Dynamic>> (String lines or {name,path,
// flipX,flipY,scale} sprite objects) and showIntroLine() below does what IntroText.show() did,
// inline against this script's own top-level vars/functions instead of a cast-back instance.

import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import funkin.backend.MusicBeatState;
import funkin.backend.MusicBeatGroup;
import funkin.backend.utils.DiscordUtil;
import funkin.backend.utils.CoolSfx;
import funkin.backend.utils.XMLUtil;
import funkin.backend.system.Logs;
import haxe.xml.Access;
import openfl.Assets;
#if UPDATE_CHECKING
import funkin.backend.system.updating.UpdateUtil;
import funkin.backend.system.updating.UpdateAvailableScreen;
#end

using StringTools;
using funkin.backend.utils.CoolUtil;

var curWacky:Array<String> = [];

var blackScreen:FlxSprite;
var textGroup:FlxGroup;
var titleText:FlxSprite;
var titleScreenSprites:MusicBeatGroup;
var transitioning = false;
var skippedIntro = false;

var xml:Access;
var titleLength = 16;

// TitleState.initialized/hasCheckedUpdates stay real static fields on the compiled class (not
// top-level vars here) on purpose: MainState.hx and the "reloadIntro" console command both write
// TitleState.initialized directly to reset the "has the intro played once already" flag on mod
// switch, and top-level script vars reset every time this script is re-instantiated - they can't
// hold state across that. Same reasoning as Main.isReleaseShell in the MainMenuState port.
var titleLines:Map<Int, Array<Dynamic>> = [];

var titleSprites:Map<String, FlxSprite> = [];

// Built with .set() calls instead of a map literal - hscript's parser is picky about "=>" in a
// literal that mixes null values and nested object literals.
function setDefaultTitleLines() {
	titleLines.set(1, ["ninjamuffin99", "phantomArcade", "kawaisprite", "evilsk8er"]);
	titleLines.set(3, ["ninjamuffin99", "phantomArcade", "kawaisprite", "evilsk8er", "present"]);
	titleLines.set(4, null);
	titleLines.set(5, ["In association", "with"]);
	titleLines.set(7, ["In association", "with", "newgrounds", {
		name: "newgroundsLogo",
		path: "menus/titlescreen/newgrounds_logo",
		scale: 0.8
	}]);
	titleLines.set(8, null);
	titleLines.set(9, ["{introText1}"]);
	titleLines.set(11, ["{introText1}", "{introText2}"]);
	titleLines.set(12, null);
	titleLines.set(13, ["Friday"]);
	titleLines.set(14, ["Friday", "Night"]);
	titleLines.set(15, ["Friday", "Night", "Funkin'"]);
}

function create() {
	setDefaultTitleLines();
	curWacky = FlxG.random.getObject(getIntroTextShit());

	MusicBeatState.skipTransIn = true;

	startIntro();

	DiscordUtil.call("onMenuLoaded", ["Title Screen"]);
}

function startIntro() {
	if (!TitleState.initialized)
		CoolUtil.playMenuSong(true);

	persistentUpdate = true;

	var bg = new FlxSprite().makeSolid(FlxG.width, FlxG.height, FlxColor.BLACK);
	add(bg);

	titleScreenSprites = new MusicBeatGroup();
	add(titleScreenSprites);
	loadXML();

	if (titleText == null) {
		titleText = new FlxSprite(0, FlxG.height * 0.8);
		titleText.frames = Paths.getFrames('menus/titlescreen/titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = true;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		titleText.screenCenter(FlxAxes.X);
	}
	add(titleText);

	textGroup = new FlxGroup();

	blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
	add(blackScreen);

	FlxG.mouse.visible = false;

	if (TitleState.initialized)
		skipIntro();
	else
		TitleState.initialized = true;

	add(textGroup);
}

function getIntroTextShit() {
	var fullText = Assets.getText(Paths.txt('titlescreen/introText'));

	var firstArray = fullText.split('\n');
	var swagGoodArray = [];

	for (i in firstArray)
		swagGoodArray.push(i.split('--'));

	return swagGoodArray;
}

function update(elapsed) {
	var pressedEnter = FlxG.keys.justPressed.ENTER;

	#if mobile
	for (touch in FlxG.touches.list) {
		if (touch.justPressed)
			pressedEnter = true;
	}
	#end

	var gamepad = FlxG.gamepads.lastActive;

	if (gamepad != null) {
		if (gamepad.justPressed.START)
			pressedEnter = true;

		#if switch
		if (gamepad.justPressed.B)
			pressedEnter = true;
		#end
	}

	if (pressedEnter && transitioning && skippedIntro) {
		FlxG.camera.stopFX();
		goToMainMenu(false);
	}

	if (pressedEnter && !transitioning && skippedIntro) {
		pressEnter();
	}

	if (pressedEnter && !skippedIntro)
		skipIntro();
}

function pressEnter() {
	titleText.animation.play('press');

	FlxG.camera.flash(FlxColor.WHITE, 1);
	CoolUtil.playMenuSFX(CoolSfx.CONFIRM, 0.7);

	transitioning = true;

	new FlxTimer().start(2, function(_) goToMainMenu(false));
}

function goToMainMenu(force = true) {
	#if UPDATE_CHECKING
	if (!force && !Flags.DISABLE_AUTOUPDATER) {
		var self = FlxG.state;
		UpdateUtil.waitForUpdates(false, function(report) {
			TitleState.hasCheckedUpdates = true;
			if (FlxG.state != self) return;

			if (!report.newUpdate) goToMainMenu(true);
			else FlxG.switchState(new UpdateAvailableScreen(report));
		}, true);
	}
	else
	#end
	{
		// TitleState is only ever reached after a game's been explicitly chosen via GamesMenu's
		// Edit/Run (see MainState.hx's isFirstBoot check), so at this point this really is that
		// game's own Main Menu, not the engine's loader - stays MainMenuState.
		FlxG.switchState(new MainMenuState());
	}
}

function createCoolText(textArray:Array<String>) {
	for (i => text in textArray) {
		if (text == "" || text == null) continue;
		var money = new Alphabet(0, (i * 60) + 200, text, "bold");
		money.screenCenter(FlxAxes.X);
		textGroup.add(money);
	}
}

function addMoreText(text:String) {
	var coolText = new Alphabet(0, (textGroup.length * 60) + 200, text, "bold");
	coolText.screenCenter(FlxAxes.X);
	textGroup.add(coolText);
}

function deleteCoolText() {
	while (textGroup.members.length > 0) {
		textGroup.members[0].destroy();
		textGroup.remove(textGroup.members[0], true);
	}
}

// IBeatReceiver dispatch to members already happened before this fires - see
// MusicBeatState.beatHit()'s call("beatHit", ...) - so this is purely the intro-advance logic.
function beatHit(curBeat) {
	if (curBeat >= titleLength || skippedIntro) {
		if (!skippedIntro) skipIntro();
		return;
	}
	if (titleLines.exists(curBeat))
		showIntroLine(titleLines.get(curBeat));
}

function showIntroLine(lines:Array<Dynamic>) {
	deleteCoolText();
	if (lines == null) return;

	for (e in lines) {
		if (Std.isOfType(e, String)) {
			var text:String = e;
			for (k => w in curWacky)
				text = StringTools.replace(text, "{introText" + (k + 1) + "}", StringTools.trim(w));
			addMoreText(text);
		} else {
			var image = e;
			if (image.path != null) {
				var scale:Float = image.scale != null ? image.scale : 1;

				var yPos:Float = 200;
				if (textGroup.members.length > 0) {
					var lastLine:FlxSprite = cast textGroup.members[textGroup.members.length - 1];
					yPos = lastLine.y + lastLine.height + 10;
				}

				var sprite = new FlxSprite(0, yPos);
				CoolUtil.loadAnimatedGraphic(sprite, Paths.image(image.path));
				sprite.flipX = image.flipX == true;
				sprite.flipY = image.flipY == true;
				sprite.scale.set(scale, scale);
				sprite.updateHitbox();
				sprite.screenCenter(FlxAxes.X);
				sprite.antialiasing = true;
				textGroup.add(sprite);
			}
		}
	}
}

// Raw Xml API on purpose (not haxe.xml.Access): Access's `xml.node.intro` / `xml.has.length`
// style is a compile-time Dynamic-resolve trick that hscript can't do ("invalid access to field").
function xmlAtt(x, name, def) {
	return x.exists(name) ? x.get(name) : def;
}

function xmlChild(x, name) {
	var it = x.elementsNamed(name);
	return it.hasNext() ? it.next() : null;
}

function loadXML() {
	try {
		var root = Xml.parse(Assets.getText(Paths.xml('titlescreen/titlescreen'))).firstElement();
		var intro = xmlChild(root, "intro");
		if (intro != null) {
			titleLines.clear();
			var len = Std.parseInt(xmlAtt(intro, "length", "16"));
			titleLength = len != null ? len : 16;

			for (node in root.elementsNamed("sprites")) {
				var parentFolder:String = xmlAtt(node, "folder", "");
				if (parentFolder != "" && !StringTools.endsWith(parentFolder, "/")) parentFolder += "/";
				for (sprNode in node.elements()) {
					var spr = null;
					try {
						// createSpriteFromXML is an `inline` wrapper that doesn't survive being called
						// from hscript, so this does what it does directly. 1 = XMLAnimType.BEAT
						// (enum abstract over Int, not reachable from hscript).
						spr = XMLUtil.loadSpriteFromXML(new FunkinSprite(), sprNode, parentFolder, 1, true);
					} catch (err:Dynamic) {
						Logs.error("Title sprite '" + sprNode.get("name") + "' failed to load: " + err);
					}
					if (spr == null) continue;
					if (sprNode.nodeName == "press-enter") {
						titleText = spr;
					} else {
						titleScreenSprites.add(spr);
					}
					if (node.exists("name")) titleSprites[node.get("name")] = spr;
				}
			}

			for (text in intro.elementsNamed("text")) {
				var beatNum = Std.parseInt(xmlAtt(text, "beat", "0"));
				var beat:Int = beatNum != null ? beatNum : 0;
				var texts:Array<Dynamic> = [];
				for (node in text.elements()) {
					var nodeName = node.nodeName;
					if (nodeName == "line") {
						if (node.exists("text")) texts.push(node.get("text"));
					} else if (nodeName == "introtext") {
						if (node.exists("line")) texts.push("{introText" + node.get("line") + "}");
					} else if (nodeName == "sprite") {
						if (node.exists("path")) {
							var scaleNum = Std.parseFloat(xmlAtt(node, "scale", "1"));
							texts.push({
								name: xmlAtt(node, "name", null),
								path: node.get("path"),
								flipX: xmlAtt(node, "flipX", "false") == "true",
								flipY: xmlAtt(node, "flipY", "false") == "true",
								scale: Math.isNaN(scaleNum) ? 1 : scaleNum
							});
						}
					}
				}
				titleLines.set(beat, texts);
			}
		}
	} catch (e:Dynamic) {
		Logs.error("Failed to load titlescreen XML: " + e);
	}
}

function skipIntro() {
	if (!skippedIntro) {
		FlxG.camera.flash(FlxColor.WHITE, 4);
		remove(blackScreen);
		blackScreen.destroy();
		remove(textGroup);
		skippedIntro = true;
	}
}
