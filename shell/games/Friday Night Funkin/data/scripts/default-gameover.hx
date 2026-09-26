// This game's default game over screen, ported out of the compiled GameOverSubstate (see its
// create()/update() for the original). Set as this game's DEFAULT_GAMEOVER_SCRIPT in
// game.ini's [Flags]; songs that set their own (tank.hx -> week7-balledLines) still override it.
//
// Cancelling the event skips the compiled class's default setup *and* its update() logic, so this
// script builds the character/camera/sound and runs the "wait for the death sfx, then loop the
// game over music" and accept/back handling itself. endBullshit() (retry) and exit() (back to
// menu) stay in the engine - generic behavior that reads the fields assigned below.

import flixel.FlxObject;
import funkin.backend.utils.DiscordUtil;

function create(event) {
	event.cancel();

	character = new Character(event.x, event.y, event.character, event.player);
	character.danceOnBeat = false;
	character.playAnim('firstDeath');
	add(character);

	var camPos = character.getCameraPosition();
	camFollow = new FlxObject(camPos.x, camPos.y, 1, 1);
	add(camFollow);
	FlxG.camera.target = camFollow;

	lossSFX = FlxG.sound.play(Paths.sound(event.lossSFX));
	Conductor.changeBPM(event.bpm);
	cancelConductorUpdate = true;

	DiscordUtil.call("onGameOver", []);
}

function update(elapsed) {
	if (controls.ACCEPT) endBullshit();
	if (controls.BACK) exit();

	if (!isEnding && ((!lossSFX.playing) || (character.getAnimName() == "firstDeath" && character.isAnimFinished()))
		&& (FlxG.sound.music == null || !FlxG.sound.music.playing)) {
		CoolUtil.playMusic(Paths.music(gameOverSong), false, 1, true, Flags.DEFAULT_BPM);
		character.playAnim("deathLoop", true, "DANCE");
		cancelConductorUpdate = false;
	}
}
