
function onEvent(event) {
	switch (event.event.name) {
		case 'endeavorsStage':
			stage(event.event.params[0],event.event.params[1]);
	}
}