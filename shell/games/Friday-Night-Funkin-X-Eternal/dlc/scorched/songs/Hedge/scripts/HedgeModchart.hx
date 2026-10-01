function postCreate() {
     FlxG.cameras.add(camOpp = new HudCamera(), false).bgColor = camHUD.bgColor;
     strumLines.members[0].camera = camOpp;
}

function stepHit()
{
	switch (curStep)
	{
		case 1284:
		FlxTween.tween(cpuStrums.members[0], {x: 432}, 0.1);
		FlxTween.tween(cpuStrums.members[1], {x: 320}, 0.1);
		FlxTween.tween(cpuStrums.members[2], {x: 208}, 0.1);
		FlxTween.tween(cpuStrums.members[3], {x: 96}, 0.1);
		camOpp.downscroll = ! Options.downscroll;
		case 1290:
		FlxTween.tween(cpuStrums.members[0], {x: 96}, 0.1);
		FlxTween.tween(cpuStrums.members[1], {x: 208}, 0.1);
		FlxTween.tween(cpuStrums.members[2], {x: 320}, 0.1);
		FlxTween.tween(cpuStrums.members[3], {x: 432}, 0.1);
		camOpp.downscroll = Options.downscroll;
		case 1305:
		cpuStrums.members[0].x = 1072;
		cpuStrums.members[1].x = 960;
		cpuStrums.members[2].x = 848;
		cpuStrums.members[3].x = 736;
		playerStrums.members[0].x = 432;
		playerStrums.members[1].x = 320;
		playerStrums.members[2].x = 208;
		playerStrums.members[3].x = 96;
		case 1310:
		cpuStrums.members[0].x = 96;
		cpuStrums.members[1].x = 208;
		cpuStrums.members[2].x = 320;
		cpuStrums.members[3].x = 432;
		playerStrums.members[0].x = 736;
		playerStrums.members[1].x = 848;
		playerStrums.members[2].x = 960;
		playerStrums.members[3].x = 1072;
		case 1330:
		FlxTween.tween(cpuStrums.members[0], {x: 208}, 0.1);
		FlxTween.tween(cpuStrums.members[1], {x: 96}, 0.1);
		FlxTween.tween(cpuStrums.members[2], {x: 432}, 0.1);
		FlxTween.tween(cpuStrums.members[3], {x: 320}, 0.1);
		case 1338:
		FlxTween.tween(cpuStrums.members[0], {x: 96}, 0.1);
		FlxTween.tween(cpuStrums.members[1], {x: 208}, 0.1);
		FlxTween.tween(cpuStrums.members[2], {x: 320}, 0.1);
		FlxTween.tween(cpuStrums.members[3], {x: 432}, 0.1);
		case 1424:
		FlxTween.tween(FlxG.camera, {angle: 15}, 1.5);
		FlxTween.tween(cpuStrums.members[0], {angle: 45, x: -440, y: 100}, 1.5);
		FlxTween.tween(cpuStrums.members[1], {angle: -15, x: 8, y: 0}, 1.5);
		FlxTween.tween(cpuStrums.members[2], {angle: 15, x: 456, y: 100}, 1.5);
		FlxTween.tween(cpuStrums.members[3], {angle: -45, x: 904, y: 0}, 1.5);
		case 1440:
		FlxTween.tween(FlxG.camera, {angle: 0}, 0.1);
		FlxTween.tween(cpuStrums.members[0], {angle: 0, x: 96, y: 50}, 0.1);
		FlxTween.tween(cpuStrums.members[1], {angle: 0, x: 208, y: 50}, 0.1);
		FlxTween.tween(cpuStrums.members[2], {angle: 0, x: 320, y: 50}, 0.1);
		FlxTween.tween(cpuStrums.members[3], {angle: 0, x: 432, y: 50}, 0.1);
	}
}