var __name__ = __script__.fileName.substring(0, __script__.fileName.lastIndexOf('.'));
var phantomWindow:Float = 55;
var dropTime:Float = 0;
var healthDrop:Float = 0;

function onNoteCreation(event:NoteCreationEvent) {
    if(event.noteType == __name__) {
        event.noteSprite = 'game/notes/' + __name__;
        event.note.avoid = true;
        event.note.updateHitbox();

        if(!FlxG.save.data.pussyMode) {
            event.note.exists = false;
            return;
        }
    }
}

function onNoteUpdate(event) {
    if(event.note.noteType != __name__) return;

    event.cancelWindowUpdate();

    var diff = event.note.strumTime - Conductor.songPosition;
    event.note.canBeHit = diff > -phantomWindow && diff < phantomWindow;

    if(diff < -phantomWindow && !event.note.wasGoodHit)
        event.note.tooLate = true;
}

function onPlayerHit(event) {
    if (event.noteType == __name__) {
        healthDrop += 0.03;
        dropTime = 10;

        event.healthGain = 0;
        event.misses = false;
        event.countScore = false;
        event.countAsCombo = false;
        event.accuracy = null;
        event.showRating = false;
        event.showSplash = false;
        event.preventAnim();
        event.preventStrumGlow();
        event.preventCamZooming();
        event.preventVocalsUnmute();
        event.cancel();
    }
}

function onPlayerMiss(event) {
    if (event.noteType == __name__) {
        event.healthGain = 0;
        event.score = 0;
        event.misses = 0;
        event.accuracy = null;
        event.muteVocals = false;
        event.gfSad = false;
        event.resetCombo = false;
        event.playMissSound = false;
        event.stunned = false;
        event.animCancelled = true;
    }
}

function update(elapsed:Float) {
    if(dropTime > 0) {
        dropTime -= elapsed;
        health -= healthDrop * elapsed;
    }

    if(dropTime <= 0) {
        healthDrop = 0;
        dropTime = 0;
    }
}
