import hxvlc.flixel.FlxVideoSprite;

var mlgVideo:FlxVideoSprite;
var glasses:FlxVideoSprite;
var videoLayer;
var camVideos;
var greenScreen;
var mlgOn:Bool = false;

function postCreate() {
	cancelIntro = false;

	graphicCache.cache(Paths.image("game/splashes/hitmarker"));
	FlxG.sound.cache(Paths.sound("hitmarker"));

	camVideos = new FlxCamera();
	camVideos.bgColor = FlxColor.TRANSPARENT;
	camVideos.visible = false;
	FlxG.cameras.add(camVideos, false);


	videoLayer = new FlxTypedGroup();
	insert(0, videoLayer);

	greenScreen = new CustomShader("greens");
	greenScreen.threshold = 0.8;
	greenScreen.softness = 0.2;

	mlgVideo = new FlxVideoSprite(0, 0);
	mlgVideo.scrollFactor.set();
	mlgVideo.cameras = [camVideos];
	mlgVideo.shader = greenScreen;
	mlgVideo.visible = false;
	mlgVideo.load(Paths.video("sanic/MLG"), [":input-repeat=65535", ":no-audio"]);
	mlgVideo.bitmap.onFormatSetup.add(() -> mlgVideo.play());
	videoLayer.add(mlgVideo);

	glasses = new FlxVideoSprite(0, 0);
	glasses.scrollFactor.set();
	glasses.cameras = [camVideos];
	glasses.shader = greenScreen;
	glasses.visible = false;
	glasses.load(Paths.video("sanic/glasses"), [":no-audio"]);
	glasses.bitmap.onFormatSetup.add(() -> glasses.play());
	glasses.bitmap.onEndReached.add(() -> {
		glasses.visible = false;
		camVideos.visible = false;
	});
	videoLayer.add(glasses);
}

function onPlayerHit(e) {
	if (mlgOn) {
		e.note.splash = "hitmarker";

		if (e.showSplash == true && !e.note.isSustainNote)
			FlxG.sound.play(Paths.sound("hitmarker"), 0.9);
	}
}

function stepHit(curStep:Int) {
	switch(curStep) {
		case 5, 9, 12, 64, 69, 73, 77, 383, 389, 393, 397, 408, 410, 412, 448, 452, 456, 460, 472, 474, 476, 512, 516, 520, 524, 536, 538, 540, 576, 580, 584, 588, 600, 602, 604, 634, 639, 642, 646, 650, 654, 664, 682, 698, 710, 716, 729, 745, 760, 774, 780, 790, 808, 825, 838, 845, 857, 872, 888, 895, 900, 905, 910, 1472, 1476, 1480, 1484:
			for (strums in [cpuStrums, playerStrums])
				for (strum in strums.members) {
					strum.angle = 0;
					FlxTween.tween(strum, {angle: 360}, 0.2, {ease: FlxEase.quintOut});
				}

		case 896:
			defaultCamZoom = 0.6;

		case 912:
			mlgOn = true;
			camVideos.visible = true;
			defaultCamZoom = 0.35;

			for (strums in [cpuStrums, playerStrums])
				for (strum in strums.members)
					strum.noteAngle = 0;

			FlxTween.cancelTweensOf(mlgVideo);
			mlgVideo.visible = true;
			mlgVideo.bitmap.time = 0;
			mlgVideo.play();
			mlgVideo.resume();

		case 976:
			camVideos.visible = false;

			FlxTween.cancelTweensOf(mlgVideo);
			mlgVideo.visible = false;
			mlgVideo.stop();
			videoLayer.remove(mlgVideo, true);
			mlgVideo.destroy();
			mlgVideo = null;

		case 1168:
			mlgOn = false;
			camGame.angle = 0;
			camVideos.visible = false;
			camGame.fade(0xFF000000, 1, false, null, true);
			FlxTween.tween(camHUD, {alpha: 0}, 1, {ease: FlxEase.quadOut});

			for (strums in [cpuStrums, playerStrums])
				for (strum in strums.members) {
					strum.angle = 0;
					strum.noteAngle = 0;
				}

			for (item in [newBar, healthBar, healthBarBG, iconP1, iconP2, scoreTxt, missesTxt, accuracyTxt])
				item.angle = 0;

		case 1192:
			camGame.fade(0xFF000000, 0.7, true, null, true);

		case 1216:
			FlxTween.tween(camHUD, {alpha: 1}, 0.7, {ease: FlxEase.quadOut});

		case 1424:
			bf.cameraOffset.x = -200;

		case 1544:
			if (glasses != null) {
				camVideos.visible = true;

				FlxTween.cancelTweensOf(glasses);
				glasses.visible = true;
				glasses.bitmap.time = 0;
				glasses.play();
			}
	}
}

function beatHit(curBeat:Int) {
	if (!mlgOn || curBeat % 4 != 0) return;

	camGame.zoom += 0.06;
	camHUD.zoom += 0.08;

	for (strums in [cpuStrums, playerStrums])
		for (strum in strums.members) {
			strum.angle = 0;
			strum.noteAngle = 0;
			FlxTween.tween(strum, {angle: 360}, 1.2, {ease: FlxEase.quadInOut});
		}
}

function postUpdate(elapsed:Float) {
	for (strums in [cpuStrums, playerStrums])
		for (strum in strums.members)
			strum.noteAngle = 0;
}

function onSubstateOpen() {
	if (mlgVideo != null && mlgVideo.visible)
		mlgVideo.pause();

	if (glasses != null && glasses.visible)
		glasses.pause();
}

function onSubstateClose() {
	if (mlgVideo != null && mlgVideo.visible)
		mlgVideo.resume();

	if (glasses != null && glasses.visible)
		glasses.resume();
}

function destroy() {
	if (mlgVideo != null) {
		FlxTween.cancelTweensOf(mlgVideo);
		mlgVideo.stop();
		videoLayer.remove(mlgVideo, true);
		mlgVideo.destroy();
	}

	if (glasses != null) {
		FlxTween.cancelTweensOf(glasses);
		glasses.stop();
		videoLayer.remove(glasses, true);
		glasses.destroy();
	}

	FlxG.cameras.remove(camVideos, true);
}
