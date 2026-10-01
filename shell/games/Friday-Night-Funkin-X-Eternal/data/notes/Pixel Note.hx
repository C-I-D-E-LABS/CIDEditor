
function onNoteCreation(e) 
	if (e.note.noteType == "Pixel Note") {
		e.cancel();
		e.note.loadGraphic(Paths.image('game/pixelUI/'+ (e.note.isSustainNote ? 'NOTE_assetsENDS' : 'NOTE_assets')), true, e.note.isSustainNote ? 7 : 17, e.note.isSustainNote ? 6 : 17);
		e.note.animation.add("hold", [e.strumID]);
		e.note.animation.add(e.note.isSustainNote ? "holdend" : "scroll", [4 + e.strumID]);

		e.note.scale.set(6, 6);
		e.note.updateHitbox();
	}

function onPostNoteCreation(e){
    if (e.note.noteType == "Pixel Note"){
        e.note.splash = 'pixel-default';
    }
}
