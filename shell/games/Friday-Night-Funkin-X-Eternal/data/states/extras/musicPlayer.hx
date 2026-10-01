/*
	=======================================================
	 Lil' Music Player  -  Codename Engine custom GameState
	=======================================================
	Scans this mod's root-level "ost" folder and turns it into a tiny
	CD-player style jukebox. Every file in ost/ is a single, complete
	track (no more separate Inst/Voices split) - it's loaded and played
	as-is. Console body + all 8 buttons use your art from menus/music/,
	the backdrop is a pulsing menus/music/bg tile, and the mouse gets
	its own two-frame cursor (menus/music/cursor1 idle, cursor2 while
	a button is held down) instead of the system one.

	WHERE TO PUT THIS FILE:
		mods/<YourModFolder>/data/states/MusicPlayerState.hx

	WHERE YOUR TRACKS GO:
		mods/<YourModFolder>/ost/<AnyName>.ogg  (mp3/wav also picked up)

	HOW TO OPEN IT (from a menu button, a debug key, wherever):
		FlxG.switchState(new GameState("MusicPlayerState"));

	CONTROLS:
		EJECT        -> back to the main menu
		PLAY / PAUSE / STOP -> transport controls
		AUTO SEARCH  -> jump to the previous / next track (and play it)
		SEARCH       -> rewind / fast-forward 5s inside the current track
		Mouse click on any button, or:
		SPACE = play/pause, LEFT/RIGHT = prev/next track, ESC = eject
*/

import flixel.addons.display.FlxBackdrop;
import flixel.tweens.FlxTweenType;


var CONSOLE_SCALE = 3.0;     // matches the scale you already had on playerConsole
var BUTTON_SCALE = 3.0;      // scale applied to play/pause/stop/autosel/serch/eject icons
var SCREEN_INSET_X = 34.0;   // black screen's left/right inset from the console edges
var SCREEN_INSET_Y = 70.0;   // black screen's top inset from the console top
var SCREEN_HEIGHT = 220.0;   // black screen height
var BUTTON_ROW_GAP = 26.0;   // gap between bottom of the screen and the button row
var CURSOR_SCALE = 2.0;      // matches the pixel-art scale used on everything else in this menu
var CURSOR_OFFSET_X = 0.0;   // nudge so the art's "tip" lines up with the real pointer position
var CURSOR_OFFSET_Y = 0.0;

// ---- parallax background (menus/music/bg/1.png .. 7.png) ----
// One row per layer, drawn in this order (first = furthest back). Tweak
// freely per layer:
//   file   -> menus/music/bg/<file>.png
//   x, y   -> starting position (nudge these to line the layers up)
//   velX   -> px/sec sideways auto-scroll (negative = drifts left). Back
//             layers should drift slower than front ones for the depth
//             illusion - that's the only reason these differ by default.
//   tileY  -> true = also repeats vertically (use for a fill layer like the
//             solid-blue one), false = repeats sideways only, stays put
//             vertically at y (use for a skyline/horizon strip).
var PARALLAX_LAYERS = [
	{file: "1", x: 0.0, y: 10.0,   velX: -3.0,  tileY: false},
	{file: "2", x: 0.0, y: 200.0,  velX: -5.0,  tileY: false},
	{file: "3", x: 0.0, y: 256.0,  velX: -8.0,  tileY: false},
	{file: "4", x: 0.0, y: 280.0,  velX: -12.0, tileY: false},
	{file: "5", x: 0.0, y: 220.0,  velX: -18.0, tileY: false},
	{file: "6", x: 0.0, y: 330.0, velX: -25.0, tileY: false},
  	{file: "7", x: 0.0, y: 400.0, velX: 0.0,   tileY: false},
   	{file: "6", x: 0.0, y: 330.0, velX: -25.0, tileY: false},



];
var PARALLAX_SCALE = 2.0; // scales every backdrop layer up 2x

// ---- state ----
var songNames = []; // raw filenames (WITH extension) found in this mod's ost/ folder
var curIndex = 0;
var trackLoaded = false;
var gridCap = 20; // how many track numbers the screen shows, like the reference photo

// ---- ui refs ----
var gridTexts = [];
var trackText = null;
var timeText = null;
var statusText = null;
var footerText = null;
var barBG = null;
var barFill = null;
var buttons = [];

// ---- custom cursor ----
var cursorSprite = null;
var cursorPressed = false;

// ---- layout (filled in by buildCase/buildScreen from the actual console size) ----
var caseX = 0.0;
var caseY = 0.0;
var caseW = 0.0;
var caseH = 0.0;
var screenX = 0.0;
var screenY = 0.0;
var screenW = 0.0;
var screenH = 0.0;

function create() {
	// don't let whatever menu music was already playing bleed into this screen
	if (FlxG.sound.music != null) FlxG.sound.music.stop();

	songNames = getOstTrackNames();

	//buildParallaxBg(); // has to be added before everything else so it sits behind it all
	var bg = new FlxBackdrop(Paths.image("menus/music/bg"), FlxAxes.XY);
	bg.antialiasing = false;
    bg.screenCenter();
    bg.scale.set(3,3);
	add(bg);
  	FlxTween.tween(bg, {alpha: 0.5}, 1.3, {ease: FlxEase.sineInOut, type: FlxTweenType.PINGPONG});

	buildCase();
	buildScreen();
	buildButtons();
	buildCursor(); // last, so it always draws on top of everything else

	refreshTrackDisplay();
}

// Scans this mod's root-level "ost" folder (mods/<YourMod>/ost/) for audio
// files and returns their raw filenames (extension included), sorted the
// way Paths hands them back. Every file here is a complete track on its
// own - there's no separate Inst/Voices pair to stitch together.
function getOstTrackNames() {
	var files = Paths.getFolderContent("ost", false, 1); // 1 = MODS only, same convention as before
	var names = [];
	for (f in files) {
		var ext = extOf(f);
		if (ext == "ogg" || ext == "mp3" || ext == "wav") names.push(f);
	}
	return names;
}

function extOf(fileName) {
	var dot = fileName.lastIndexOf(".");
	return dot > -1 ? fileName.substring(dot + 1).toLowerCase() : "";
}

function stripExt(fileName) {
	var dot = fileName.lastIndexOf(".");
	return dot > -1 ? fileName.substring(0, dot) : fileName;
}

// Adds every menus/music/bg/*.png layer as an infinitely-tiling FlxBackdrop,
// each drifting sideways at its own speed for a parallax feel.
function buildParallaxBg() {
	// plain black safety net, in case any layer has transparent gaps
	var fallback = new FlxSprite(0, 0);
	fallback.makeGraphic(FlxG.width, FlxG.height, 0xFF0400FF);
	add(fallback);

	for (i in 0...PARALLAX_LAYERS.length) {
		var cfg = PARALLAX_LAYERS[i];
		var axes = FlxAxes.X;
		var layer = new FlxBackdrop(Paths.image("menus/music/bg/" + cfg.file), axes);
		layer.scale.set(PARALLAX_SCALE, PARALLAX_SCALE);
		layer.x = cfg.x;
		layer.y = cfg.y;
		layer.velocity.x = cfg.velX;
		add(layer);
	}
}

function buildCase() {
	var shellOuter = new FlxSprite(0, 0);
	shellOuter.loadGraphic(Paths.image("menus/music/playerConsole"));
	shellOuter.scale.set(CONSOLE_SCALE, CONSOLE_SCALE);
	shellOuter.updateHitbox();
	shellOuter.screenCenter();
	add(shellOuter);

	// derive the whole layout from the real (scaled) size of the console art
	caseX = shellOuter.x;
	caseY = shellOuter.y;
	caseW = shellOuter.width;
	caseH = shellOuter.height;

	var title = new FlxText(caseX, caseY - 30, caseW, "MOD MUSIC PLAYER", 20);
	title.alignment = "center";
	title.color = 0xFFffe6e6;
	add(title);
}

function buildScreen() {
	screenX = caseX + SCREEN_INSET_X;
	screenY = caseY + SCREEN_INSET_Y;
	screenW = caseW - (SCREEN_INSET_X * 2);
	screenH = SCREEN_HEIGHT;

	var screen = new FlxSprite(screenX, screenY);
	screen.makeGraphic(Std.int(screenW - 20), Std.int(screenH), 0xFF000000);
	//add(screen);

	// ---- track number grid ----
	var shown = songNames.length < gridCap ? songNames.length : gridCap;
	if (shown == 0) shown = gridCap; // still draw a placeholder grid if no songs were found

	var cellW = (screenW - 20) / 10;

	for (i in 0...shown) {
		var row = Std.int(i / 10);
		var col = i - (row * 10);
		var t = new FlxText(screenX + 10 + col * cellW, screenY + 10 + row * 22, cellW, Std.string(i + 1), 16);
		t.alignment = "center";
		t.color = 0xFF555566;
		add(t);
		gridTexts.push(t);
	}

	barBG = new FlxSprite(screenX + 10, screenY + 58);
	barBG.makeGraphic(Std.int(screenW - 20), 6, 0xFF2a2a35);
	add(barBG);

	barFill = new FlxSprite(screenX + 10, screenY + 58);
	barFill.makeGraphic(2, 6, 0xff3be23b);
	add(barFill);

	trackText = new FlxText(screenX + 10, screenY + 92, screenW * 0.5, "TRACK --", 22);
	trackText.color = 0xff3be23b;
	add(trackText);

	timeText = new FlxText(screenX + screenW * 0.45, screenY + 80, screenW * 0.5 - 10, "ELAPSED\nTIME  00:00", 18);
	timeText.alignment = "right";
	timeText.color = 0xff3be23b;
	add(timeText);

	statusText = new FlxText(screenX + 10, screenY + 134, screenW - 20, "STOPPED", 15);
	statusText.color = 0xFF888899;
	add(statusText);

	footerText = new FlxText(screenX + 10, screenY + screenH - 26, screenW - 20, "", 13);
	footerText.color = 0xFF555566;
	footerText.text = songNames.length + " track(s) found in this mod's ost folder";
	add(footerText);
}

function buildButtons() {
	var rowCenterY = screenY + screenH + BUTTON_ROW_GAP + 23;
	var x = caseX + 30;

	var ejectBtn = makeImageButton(x - 6, rowCenterY + 177, "menus/music/eject", eject);
	x += ejectBtn.width + 14;

	var playBtn = makeImageButton(x + 4, rowCenterY + 177, "menus/music/play", playTrack);
	x += playBtn.width + 14;

	var pauseBtn = makeImageButton(x - 12, rowCenterY + 177, "menus/music/pause", pauseTrack);
	x += pauseBtn.width + 14;

	var stopBtn = makeImageButton(x, rowCenterY + 177, "menus/music/stop", stopTrack);
	x += stopBtn.width + 36;

	var autoL = makeImageButton(x - 10, rowCenterY + 177, "menus/music/autoselL", function() skipTrack(-1));
	x += autoL.width + 10;
	var autoR = makeImageButton(x - 20, rowCenterY + 177, "menus/music/autoselR", function() skipTrack(1));
	x += autoR.width + 36;

	var serL = makeImageButton(x - 34, rowCenterY + 177, "menus/music/serchL", function() seek(-5000));
	x += serL.width + 10;
	var serR = makeImageButton(x - 43, rowCenterY + 177, "menus/music/serchR", function() seek(5000));
}

// Button backed by real art (menus/music/<key>.png). Centered vertically on centerY.
function makeImageButton(x, centerY, imageKey, action) {
	var face = new FlxSprite(x, 0);
	face.loadGraphic(Paths.image(imageKey));
	face.scale.set(BUTTON_SCALE, BUTTON_SCALE);
	face.updateHitbox();
	face.y = centerY - (face.height / 2);
	add(face);

	buttons.push({face: face, action: action});
	return face;
}

// Fallback button drawn with makeGraphic + FlxText, for buttons with no art yet.
function makeRectButton(x, centerY, w, h, label, baseColor, action) {
	var y = centerY - (h / 2);

	var border = new FlxSprite(x - 3, y - 3);
	border.makeGraphic(Std.int(w + 6), Std.int(h + 6), 0xFF3a0a0a);
	add(border);

	var face = new FlxSprite(x, y);
	face.makeGraphic(Std.int(w), Std.int(h), baseColor);
	add(face);

	var lbl = new FlxText(x, y + h / 2 - 8, w, label, 13);
	lbl.alignment = "center";
	lbl.color = 0xFF2a0505;
	add(lbl);

	buttons.push({face: face, action: action});
	return face;
}

// Builds the custom mouse cursor and hides the system one. cursor1 is the
// idle frame, cursor2 shows while the mouse button is held down - updateCursor()
// swaps between them and keeps it glued to FlxG.mouse each frame.
function buildCursor() {
	FlxG.mouse.visible = false;

	cursorSprite = new FlxSprite();
	cursorSprite.loadGraphic(Paths.image("menus/music/cursor1"));
	cursorSprite.scale.set(CURSOR_SCALE, CURSOR_SCALE);
	cursorSprite.updateHitbox();
	cursorSprite.antialiasing = false;
	cursorSprite.scrollFactor.set(0, 0);
	add(cursorSprite);
}

function updateCursor() {
	if (cursorSprite == null) return;

	cursorSprite.x = FlxG.mouse.x + CURSOR_OFFSET_X;
	cursorSprite.y = FlxG.mouse.y + CURSOR_OFFSET_Y;

	if (FlxG.mouse.pressed != cursorPressed) {
		cursorPressed = FlxG.mouse.pressed;
		cursorSprite.loadGraphic(Paths.image(cursorPressed ? "menus/music/cursor2" : "menus/music/cursor1"));
		cursorSprite.scale.set(CURSOR_SCALE, CURSOR_SCALE);
		cursorSprite.updateHitbox();
	}
}

function update(elapsed) {
	updateButtons();
	updateCursor();

	if (FlxG.keys.justPressed.ESCAPE) eject();
	if (FlxG.keys.justPressed.LEFT) skipTrack(-1);
	if (FlxG.keys.justPressed.RIGHT) skipTrack(1);
	if (FlxG.keys.justPressed.SPACE) {
		if (FlxG.sound.music != null && FlxG.sound.music.playing) pauseTrack();
		else playTrack();
	}

	refreshTrackDisplay();
}

function updateButtons() {
	for (i in 0...buttons.length) {
		var b = buttons[i];
		var hovering = FlxG.mouse.overlaps(b.face);
		// simple tint-based hover feedback - works on both image buttons and makeGraphic rects
		b.face.color = hovering ? 0xff868896 : 0xFFFFFFFF;
		if (hovering && FlxG.mouse.justPressed) b.action();
	}
}

function refreshTrackDisplay() {
	for (i in 0...gridTexts.length) {
		gridTexts[i].color = (i == curIndex) ? 0xff3be23b : 0xFF555566;
	}

	var totalMs = 0.0;
	var curMs = 0.0;
	var playing = false;
	if (FlxG.sound.music != null && trackLoaded) {
		totalMs = FlxG.sound.music.length;
		curMs = FlxG.sound.music.time;
		playing = FlxG.sound.music.playing;
	}

	if (barFill != null) {
		var frac = totalMs > 0 ? (curMs / totalMs) : 0;
		if (frac < 0) frac = 0;
		if (frac > 1) frac = 1;
		var fillW = 2 + (screenW - 22) * frac;
		barFill.makeGraphic(Std.int(fillW), 6, 0xff3be23b);
	}

	if (trackText != null)
		trackText.text = songNames.length > 0 ? ("TRACK " + (curIndex + 1)) : "TRACK --";

	if (timeText != null)
		timeText.text = "ELAPSED\nTIME  " + formatTime(curMs);

	if (statusText != null) {
		var name = songNames.length > 0 ? stripExt(songNames[curIndex]) : "no tracks in this mod's ost folder";
		var state = !trackLoaded ? "STOPPED" : (playing ? "PLAYING" : "PAUSED");
		statusText.text = state + "  -  " + name;
	}
}

function formatTime(ms) {
	var totalSec = Std.int(ms / 1000);
	var m = Std.int(totalSec / 60);
	var s = totalSec % 60;
	var sStr = s < 10 ? ("0" + s) : Std.string(s);
	return m + ":" + sStr;
}

function loadTrack(i) {
	if (songNames.length == 0) return;
	curIndex = i;
	CoolUtil.playMusic(Paths.file("ost/" + songNames[curIndex]), false, 1, false);
	trackLoaded = true;
}

function playTrack() {
	if (songNames.length == 0) return;
	if (!trackLoaded) { loadTrack(curIndex); return; }
	if (FlxG.sound.music != null && !FlxG.sound.music.playing) FlxG.sound.music.resume();
}

function pauseTrack() {
	if (FlxG.sound.music != null && FlxG.sound.music.playing) FlxG.sound.music.pause();
}

function stopTrack() {
	if (FlxG.sound.music != null) {
		FlxG.sound.music.pause();
		FlxG.sound.music.time = 0;
	}
}

function skipTrack(dir) {
	if (songNames.length == 0) return;
	var next = curIndex + dir;
	if (next < 0) next = songNames.length - 1;
	if (next >= songNames.length) next = 0;
	loadTrack(next);
}

function seek(deltaMs) {
	if (FlxG.sound.music == null || !trackLoaded) return;
	var t = FlxG.sound.music.time + deltaMs;
	if (t < 0) t = 0;
	if (t > FlxG.sound.music.length) t = FlxG.sound.music.length;
	FlxG.sound.music.time = t;
}

function eject() {
	if (FlxG.sound.music != null) FlxG.sound.music.stop();
	FlxG.mouse.visible = true; // hand the system cursor back before leaving
	FlxG.switchState(new GameState("XEternalExtras"));
}

function destroy() {
	if (FlxG.sound.music != null) FlxG.sound.music.stop();
	FlxG.mouse.visible = true; // don't leave the system cursor hidden for other states
}