function create() {
	var b = true;
    importScript('data/scripts/resizing');
	ratioThing(960,  720, false);
}

function destroy() ratioThing(1280, 720, true);