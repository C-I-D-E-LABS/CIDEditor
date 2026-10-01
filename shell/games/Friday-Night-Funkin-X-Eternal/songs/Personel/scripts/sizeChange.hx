function create() {
	var b = true;
    importScript('data/scripts/resizing');
	ratioThing(1120,  960, false);
}

function destroy() ratioThing(1280, 720, true);