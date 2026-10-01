// Window Bounce.hx
//
// Makes the ACTUAL game window (the OS window, not the in-game camera)
// tour around the whole monitor, DVD-logo-screensaver style - mostly
// aiming for the four corners (with an occasional random point thrown in
// so it doesn't feel too mechanical) instead of just reflecting back and
// forth along one shallow diagonal.
//
// Usage in the chart editor: add a "Window Bounce" event wherever you want
// the effect to start.
//   - Enable = true   -> starts touring from the window's current position.
//   - Enable = false  -> stops touring and smoothly glides the window back
//                        to the center of the screen, then stops.
// Add a second "Window Bounce" event later in the chart with Enable off
// to turn it off again.
//
// Desktop builds only (Windows/Mac/Linux native) - there's no real OS
// window to move on HTML5, so this is a no-op there.

import lime.system.System;

// mode: 0 = idle, 1 = touring corners, 2 = gliding back to center to stop
var mode:Int = 0;
var moveSpeed:Float = 300;
var winW:Int = 0;
var winH:Int = 0;
var minX:Float = 0;
var maxX:Float = 0;
var minY:Float = 0;
var maxY:Float = 0;
var targetX:Float = 0;
var targetY:Float = 0;
var lastCorner:Int = -1;

function onEvent(e) {
	if (e.event.name != "Window Bounce") return;

	var params:Array = e.event.params;
	var enable:Bool = params[0];
	var speed:Float = params[1];

	var window = FlxG.stage.window;
	if (window == null) return;

	moveSpeed = speed;
	winW = window.width;
	winH = window.height;

	// Figure out which monitor the window is currently sitting on so
	// travel stays on that screen instead of wandering onto another one.
	var display = System.getDisplay(0);
	var screenX:Int = Std.int(display.bounds.x);
	var screenY:Int = Std.int(display.bounds.y);
	var screenW:Int = Std.int(display.bounds.width);
	var screenH:Int = Std.int(display.bounds.height);

	minX = screenX;
	maxX = screenX + screenW - winW;
	minY = screenY;
	maxY = screenY + screenH - winH;
	if (maxX < minX) maxX = minX;
	if (maxY < minY) maxY = minY;

	if (!enable) {
		targetX = minX + (maxX - minX) / 2;
		targetY = minY + (maxY - minY) / 2;
		mode = 2;
		return;
	}

	lastCorner = -1;
	pickNewTarget();
	mode = 1;
}

// Picks where the window heads next: usually one of the four corners
// (never the same corner twice in a row, so it actually crosses the
// screen each time), occasionally a random point in between so the
// path stays varied instead of tracing the same box every time.
function pickNewTarget() {
	if (FlxG.random.float(0, 1) < 0.75) {
		var corner:Int = FlxG.random.int(0, 3);
		while (corner == lastCorner) corner = FlxG.random.int(0, 3);
		lastCorner = corner;
		switch (corner) {
			case 0: targetX = minX; targetY = minY;
			case 1: targetX = maxX; targetY = minY;
			case 2: targetX = minX; targetY = maxY;
			default: targetX = maxX; targetY = maxY;
		}
	} else {
		lastCorner = -1;
		targetX = FlxG.random.float(minX, maxX);
		targetY = FlxG.random.float(minY, maxY);
	}
}

function update(elapsed:Float) {
	if (mode == 0) return;

	var window = FlxG.stage.window;
	if (window == null) return;

	var dx:Float = targetX - window.x;
	var dy:Float = targetY - window.y;
	var dist:Float = Math.sqrt(dx * dx + dy * dy);

	if (dist < 4) {
		window.x = Std.int(targetX);
		window.y = Std.int(targetY);
		if (mode == 1) pickNewTarget();
		else mode = 0; // reached center, stop
		return;
	}

	var step:Float = moveSpeed * elapsed;
	if (step >= dist) {
		window.x = Std.int(targetX);
		window.y = Std.int(targetY);
		if (mode == 1) pickNewTarget();
		else mode = 0;
	} else {
		window.x = Std.int(window.x + (dx / dist) * step);
		window.y = Std.int(window.y + (dy / dist) * step);
	}
}

function destroy() {
	mode = 0;
}
