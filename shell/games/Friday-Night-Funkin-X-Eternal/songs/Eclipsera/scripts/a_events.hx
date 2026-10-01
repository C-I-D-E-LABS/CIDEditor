function create() {
	
	camExt = new FlxCamera();
	camExt.bgColor = 0x00000000;
	FlxG.cameras.add(camExt, false);

	bf.cameraOffset.x = 60;
	bf.cameraOffset.y = 100;
	dad.color = 0xFF000000;

	pixelShader = null;
	lastCamTarget = -1;

	vignette = new FlxSprite().loadGraphic(Paths.image("effects/vgs/vg_black"));
	redVignette = new FlxSprite().loadGraphic(Paths.image("effects/vgs/vg_red"));
	smoke = new FlxSprite().loadGraphic(Paths.image("effects/vgs/vg_smoke"));

	for (sprite in [vignette, redVignette, smoke]) {
		sprite.scrollFactor.set();
		sprite.cameras = [camHUD];
		sprite.setGraphicSize(FlxG.width, FlxG.height);
		sprite.updateHitbox();
		sprite.screenCenter();
		sprite.active = false;
		add(sprite);
	}

	vignette.alpha = 1;

	for (sprite in [redVignette, smoke])
		sprite.alpha = 0;
	smoke.visible = false;


}

function postCreate() {
	FlxG.save.data.cameFromStoryMenu = true;

	for (cam in [camGame, camHUD]) {
		cam.visible = true;
		cam.alpha = 1;
		cam.fade(0xFF000000, 0.001, false, null, true);
	}

	iconP2.color = 0xFF000000;
	healthBar.createColoredEmptyBar(0xFF000000);
	healthBar.updateBar();
	strumLines.members[0].visible = false;
}

function postUpdate(elapsed:Float) {
	if (curStep >= 1488 && curStep < 2000) {
		if (lastCamTarget != curCameraTarget) {
			lastCamTarget = curCameraTarget;
			defaultCamZoom = 1.2;
			FlxTween.cancelTweensOf(PlayState.instance, ["defaultCamZoom"]);
			FlxTween.tween(PlayState.instance, {defaultCamZoom: 1.8}, 10);
		}

		camGame.angle = CoolUtil.fpsLerp(camGame.angle, curCameraTarget == 0 ? 5 : -5, elapsed * 0.8);
	}
}

function stepHit(curStep:Int) {
	switch(curStep) {
		case 128:
			for (cam in [camGame, camHUD]) {
				FlxTween.cancelTweensOf(cam);
				cam.visible = true;
				cam.alpha = 1;
				cam.fade(0xFF000000, 1, true, null, true);
			}

		case 648:
			for (cam in [camGame, camHUD]) {
				cam.visible = true;
				cam.alpha = 1;
				FlxTween.cancelTweensOf(cam);
				cam.fade(0xFF000000, 1.5, false, null, true);
			}

		case 688, 692, 696, 700:
			count(Std.int((curStep - 688) / 4));

		case 704:
			for (cam in [camGame, camHUD]) {
				FlxTween.cancelTweensOf(cam);
				cam.visible = true;
				cam.alpha = 1;
				cam.stopFX();
			}
			FlxG.cameras.flash(0xFFFFFFFF, Conductor.stepCrochet * 0.001 * 7);
			defaultCamZoom = 1.5;

		case 950, 1472:
			FlxTween.tween(vignette, {alpha: 1}, 0.5);
			defaultCamZoom = 3;

		case 960:
			FlxG.cameras.flash(0xFFFFFFFF, Conductor.stepCrochet * 0.001 * 7);
			FlxTween.tween(camGame, {angle: 360}, 0.5, {ease: FlxEase.circInOut});
			defaultCamZoom = 1.3;
			vignette.alpha = 0;
			dad.color = 0x00FFFFFF;

			bf.cameraOffset.x = 0;
			bf.cameraOffset.y = 0;
			iconP2.color = 0xFFFFFFFF;
			healthBar.createColoredEmptyBar(dad.iconColor ?? (PlayState.opponentMode ? 0xFF66FF33 : 0xFFFF0000));
			healthBar.updateBar();
			strumLines.members[0].visible = true;

		case 1216:
			bf.cameraOffset.x = 60;
			bf.cameraOffset.y = 100;
			defaultCamZoom = 2.1;
			vignette.alpha = 0.8;

		case 1480:
			FlxTween.tween(camGame, {angle: -360}, 0.8, {ease: FlxEase.circInOut});

		case 1488, 1616:
			if (curStep == 1488) {
				FlxG.cameras.flash(0xFFFFFFFF, Conductor.stepCrochet * 0.001 * 10);
				defaultCamZoom = 1.2;
				lastCamTarget = curCameraTarget;
				FlxTween.cancelTweensOf(camGame, ["angle"]);
				camGame.angle = 0;

				vignette.alpha = 0;
				bf.cameraOffset.x = 0;
				bf.cameraOffset.y = 50;
				smoke.visible = true;

				for (sprite in [redVignette, smoke])
					FlxTween.tween(sprite, {alpha: 1}, 7);
			}

			FlxTween.cancelTweensOf(PlayState.instance, ["defaultCamZoom"]);
			FlxTween.tween(PlayState.instance, {defaultCamZoom: 1.8}, 15);

		case 1744:
			for (cam in [camGame, camHUD]) {
				cam.visible = false;
				FlxTween.cancelTweensOf(cam);
			}

		case 1748:
			for (cam in [camGame, camHUD]) {
				cam.visible = true;
				cam.stopFX();
			}
			FlxG.cameras.flash(0xFFFF0808, Conductor.stepCrochet * 0.001 * 10);

		case 2000:
			lastCamTarget = -1;
			FlxTween.cancelTweensOf(camGame, ["angle"]);
			camGame.angle = 0;

			if (FlxG.save.data.modShaders) {
				pixelShader = new CustomShader("pixel");
				pixelShader.iTime = 0;
				pixelShader.scale = 0.1;

				for (cam in [camGame, camHUD, camExt])
					cam.addShader(pixelShader);

				FlxTween.num(0.1, 15, 1.4, {ease: FlxEase.linear}, (v:Float) -> {
					if (pixelShader != null) pixelShader.scale = v;
				});
			}

			for (cam in [camGame, camHUD]) {
				cam.visible = true;
				cam.alpha = 1;
				FlxTween.cancelTweensOf(cam);
				cam.fade(0xFF000000, 2, false, null, true);
			}

			FlxTween.tween(PlayState.instance, {defaultCamZoom: 1.3}, 1.5);

		case 2160:
			if (pixelShader != null) {
				for (cam in [camGame, camHUD, camExt])
					cam.removeShader(pixelShader);
				pixelShader = null;
			}

			lastCamTarget = -1;
			FlxTween.cancelTweensOf(camGame, ["angle"]);
			camGame.angle = 0;
			bf.cameraOffset.x = 25;
			bf.cameraOffset.y = 100;
			defaultCamZoom = 2;
			redVignette.alpha = 0;
			vignette.alpha = 0.6;

			for (cam in [camGame, camHUD]) {
				FlxTween.cancelTweensOf(cam);
				cam.visible = true;
				cam.alpha = 1;
				cam.stopFX();
			}
			FlxG.cameras.flash(0xFFFF0000, Conductor.stepCrochet * 0.001 * 10);

		case 2544:
			defaultCamZoom = 1.7;

		case 2688:
			FlxTween.tween(PlayState.instance, {defaultCamZoom: 2.2}, 2);
			FlxTween.tween(bf.cameraOffset, {y: bf.cameraOffset.y - 500}, 2);

			for (cam in [camGame, camHUD]) {
				cam.visible = true;
				cam.alpha = 1;
				FlxTween.cancelTweensOf(cam);
				cam.fade(0xFF000000, 2, false, null, true);
			}
	}
}
