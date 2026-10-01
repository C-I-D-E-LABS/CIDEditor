static var transShader = new CustomShader("classicSonicTransition");
transShader.value = -0.5;

function postCreate() {
	blackSpr?.destroy();
	transitionSprite?.destroy();
	transitionTween?.cancel();

	FlxG.game.addShader(transShader);
	FlxTween.cancelTweensOf(transShader);
	FlxTween.tween(transShader, {value: newState != null ? -1 : -0.5}, 2/3, {onComplete: finishThing});
}

function finishThing(?_) {
	FlxG.game.setFilters([]);
	finish();
}