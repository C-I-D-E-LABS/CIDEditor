import funkin.backend.system.Logs;

// script name (without extension)
var __name__ = __script__.fileName.substring(0, __script__.fileName.lastIndexOf('.'));

function onNoteCreation(e) {
	if (e.noteType != __name__) return;
	e.noteSprite = 'game/notes/' + __name__;
	e.noteScale = 0.73;
	e.note.updateHitbox();
}

var st:FlxSprite;
var ringSound:FlxSound;
var hitStaticSound:FlxSound;
var shake = false;

function postCreate() {
	st = new FlxSprite();
	st.frames = Paths.getFrames('game/hitStatic');
	st.camera = camHUD;
	st.animation.addByPrefix('idle', 'staticANIMATION', 24, false);
	st.animation.play('idle');
	st.visible = false;
	add(st);

	hitStaticSound = new FlxSound().loadEmbedded(Paths.sound('hitStatic'));
	FlxG.sound.list.add(hitStaticSound);
}

function onPlayerMiss(event) {
	if (event.noteType == __name__) {


		Logs.trace('lol you missed the static note!', 0, 13);
		
		if (FlxG.save.data.camFlashing) {
			hitStaticSound.play();
			shake = true;
			new FlxTimer().start(0.8, tmr -> shake = false);
				st.visible = true;
				st.animation.play('idle');
				new FlxTimer().start(.38, tmr -> st.visible = false);
		}
	}
}

function postUpdate(elapsed:Float) {
	
	if (shake)
		FlxG.camera.shake(0.0025, 0.1);
}

