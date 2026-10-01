var frozenCharacters:Array<Character> = [];

// Removes Looped animation for holds
function onNoteHit(e) {
    for (char in e.characters) {
        if (char == null) continue;

        if (e.note.animation.name == "holdend") {
            frozenCharacters.remove(char);
            if (char.animation.curAnim != null) char.animation.curAnim.paused = false;
        } else if (e.note.isSustainNote && !frozenCharacters.contains(char)) {
            frozenCharacters.push(char);
        }
    }
}

function postUpdate(elapsed:Float) {
    for (char in frozenCharacters)
        if (char != null && char.animation.curAnim != null)
            char.animation.curAnim.paused = true;
}

function onPlayerMiss(e){
    for (char in e.characters) {
        frozenCharacters.remove(char);
        if (char != null && char.animation.curAnim != null) char.animation.curAnim.paused = false;
    }
}
