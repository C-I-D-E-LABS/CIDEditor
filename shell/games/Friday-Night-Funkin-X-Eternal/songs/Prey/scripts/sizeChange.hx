function create() {
	var b = true;
    importScript('data/scripts/resizing');
	ratioThing(620,  480, false);
}

function destroy() ratioThing(1280, 720, true);