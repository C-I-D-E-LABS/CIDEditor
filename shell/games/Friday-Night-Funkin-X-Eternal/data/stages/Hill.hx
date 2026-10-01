// Lord X Hill

import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxAxes;

var cloudsX:FlxBackdrop;
var cloudsX2:FlxBackdrop;

function create() {
	//defaultCamZoom = 1.2;

	dad.x += 300;
	dad.y += 350;

	boyfriend.x += 700;
	boyfriend.y += 270;
	boyfriend.cameraOffset.x -= 50;

	cloudsX = new FlxBackdrop(Paths.image("exe/lordx/Clouds"), FlxAxes.X);
	cloudsX.setPosition(130, -450);
	cloudsX.scale.set(0.5, 0.5);
	cloudsX.scrollFactor.set(0.7, 0.7);
	cloudsX.velocity.x = -20;
	cloudsX.antialiasing = true;
	insert(members.indexOf(hillsX), cloudsX);

	cloudsX2 = new FlxBackdrop(Paths.image("exe/lordx/Clouds"), FlxAxes.X);
	cloudsX2.setPosition(130, -360);
	cloudsX2.scale.set(0.5, 0.5);
	cloudsX2.scrollFactor.set(0.75, 0.75);
	cloudsX2.velocity.x = -50;
	cloudsX2.alpha = 0.55;
	cloudsX2.antialiasing = true;
	insert(members.indexOf(groundX), cloudsX2);
}
