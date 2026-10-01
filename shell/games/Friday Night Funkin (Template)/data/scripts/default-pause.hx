// This game's default pause menu look, ported out of the compiled PauseSubState (see its create()
// for the original). Set as this game's DEFAULT_PAUSE_SCRIPT in game.ini's [Flags]; songs that
// set their own pause script (week6-pause.hx via pixel.hx) still override it per-song.
//
// Cancelling the event skips the compiled class's default UI *and* its input handling (its
// update() returns early once cancelled), so this script draws the menu and handles up/down/
// accept itself, then hands the chosen item back to the engine's own selectOption() - the
// actual Resume/Restart/Options/Exit behavior stays in the engine, since that's generic.

import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import funkin.backend.utils.TranslationUtil as TU;

var pauseCam:FlxCamera;
var menuGroup:FlxTypedGroup<Alphabet>;

function create(event) {
	event.cancel();

	pauseCam = new FlxCamera();
	pauseCam.bgColor = 0;
	FlxG.cameras.add(pauseCam, false);
	cameras = [pauseCam];

	var bg = new FlxSprite().makeSolid(FlxG.width + 100, FlxG.height + 100, FlxColor.BLACK);
	bg.updateHitbox();
	bg.alpha = 0;
	bg.screenCenter();
	bg.scrollFactor.set();
	add(bg);

	var multiplayerInfo = null;
	if (PlayState.opponentMode) multiplayerInfo = 'pause.opponentMode';
	else if (PlayState.coopMode) multiplayerInfo = 'pause.coopMode';

	var levelInfo = new FunkinText(20, 15, 0, PlayState.SONG.meta.displayName, 32, false);
	var levelDifficulty = new FunkinText(20, 15, 0, TU.translateDiff(PlayState.difficulty).toUpperCase(), 32, false);
	var deathCounter = new FunkinText(20, 15, 0, TU.translate("pause.deathCounter", [PlayState.deathCounter]), 32, false);
	var multiplayerText = null;
	if (multiplayerInfo != null)
		multiplayerText = new FunkinText(20, 15, 0, TU.translate(multiplayerInfo), 32, false);

	for (k => label in [levelInfo, levelDifficulty, deathCounter, multiplayerText]) {
		if (label == null) continue;
		label.scrollFactor.set();
		label.alpha = 0;
		label.x = FlxG.width - (label.width + 20);
		label.y = 15 + (32 * k);
		FlxTween.tween(label, {alpha: 1, y: label.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3 * (k + 1)});
		add(label);
	}

	FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});

	menuGroup = new FlxTypedGroup<Alphabet>();
	add(menuGroup);

	for (i in 0...menuItems.length) {
		var pauseId = "pause." + TU.raw2Id(menuItems[i]);
		var songText = new Alphabet(0, (70 * i) + 30, TU.translate(pauseId), "bold");
		songText.isMenuItem = true;
		songText.targetY = i;
		menuGroup.add(songText);
	}

	refreshSelection(0);
}

function destroy() {
	if (pauseCam != null && FlxG.cameras.list.contains(pauseCam))
		FlxG.cameras.remove(pauseCam, true);
}

function update(elapsed) {
	var upP = controls.UP_P;
	var downP = controls.DOWN_P;
	var scroll = FlxG.mouse.wheel;

	if (upP || downP || scroll != 0)
		refreshSelection((upP ? -1 : 0) + (downP ? 1 : 0) - scroll);

	if (controls.ACCEPT)
		selectOption();
}

// Not named changeSelection on purpose: the compiled class has its own, which walks its own
// grpMenuShit group (never created when the default UI is cancelled).
function refreshSelection(change) {
	curSelected = FlxMath.wrap(curSelected + change, 0, menuItems.length - 1);

	for (i => item in menuGroup.members) {
		item.targetY = i - curSelected;
		item.alpha = (item.targetY == 0) ? 1 : 0.6;
	}
}
