import hxvlc.flixel.FlxVideoSprite;
import flixel.math.FlxMath;
import Sys;

var warn:FlxSprite;
var yesGlow:FlxSprite;
var noGlow:FlxSprite;
var gordonRamsay:FlxVideoSprite;
var curSelected:Int = 0;
var transitioning:Bool = false;

function create() {
	window.title = windowTitle + " - Warning";
	FlxG.mouse.visible = true;
	FlxG.camera.bgColor = FlxColor.BLACK;
	FlxG.camera.alpha = 1;
	FlxG.camera.zoom = 1;

	for (sound in ["menu/scroll", "menu/confirmFreeplay"])
		FlxG.sound.cache(Paths.sound(sound));
	for (asset in ["menus/warn/warn", "menus/warn/glowY", "menus/warn/glowR"])
		graphicCache.cache(Paths.image(asset));

	FlxG.sound.playMusic(Paths.music("menus/soundtest"), 0);
	FlxG.sound.music.fadeIn(3, 0, 0.7);

	add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK));

	yesGlow = new FlxSprite(460, 618).loadGraphic(Paths.image("menus/warn/glowY"));
	noGlow = new FlxSprite(720, 618).loadGraphic(Paths.image("menus/warn/glowR"));
	for (glow in [yesGlow, noGlow]) {
		glow.scale.set(0.333, 0.333);
		glow.updateHitbox();
		glow.antialiasing = false;
		add(glow);
	}

	warn = new FlxSprite().loadGraphic(Paths.image("menus/warn/warn"));
	warn.scale.set(0.333, 0.333);
	warn.updateHitbox();
	warn.screenCenter();
	warn.antialiasing = false;
	add(warn);

	updateSelection(false);
}

function update(elapsed:Float) {
	if (transitioning) return;

	FlxG.camera.scroll.x = FlxMath.lerp(FlxG.camera.scroll.x, (FlxG.mouse.screenX - FlxG.width / 2) * -0.01, FlxMath.bound(elapsed * 4, 0, 1));
	FlxG.camera.scroll.y = FlxMath.lerp(FlxG.camera.scroll.y, (FlxG.mouse.screenY - FlxG.height / 2) * -0.008, FlxMath.bound(elapsed * 4, 0, 1));

	if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A || FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D) {
		curSelected = 1 - curSelected;
		updateSelection(true);
	}

	for (i in 0...2) {
		var glow = i == 0 ? yesGlow : noGlow;
		var mouseOver:Bool =
			FlxG.mouse.x >= glow.x && FlxG.mouse.x <= glow.x + glow.width &&
			FlxG.mouse.y >= glow.y && FlxG.mouse.y <= glow.y + glow.height;

		if (mouseOver && curSelected != i) {
			curSelected = i;
			updateSelection(true);
		}

		if (mouseOver && FlxG.mouse.justPressed) {
			if (i == 0) acceptWarning();
			else denyWarning();
		}
	}

	if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE) {
		if (curSelected == 0) acceptWarning();
		else denyWarning();
	}
}

function updateSelection(playSound:Bool) {
	for (i => glow in [yesGlow, noGlow])
		glow.visible = curSelected == i;

	if (playSound)
		FlxG.sound.play(Paths.sound("menu/scroll"), 0.6);
}

function acceptWarning() {
	transitioning = true;

	FlxG.sound.play(Paths.sound("menu/confirmFreeplay"), 1);
	FlxG.camera.flash(FlxColor.RED, 1);
	FlxTween.tween(FlxG.camera, {zoom: 1.5, alpha: 0}, 1, {ease: FlxEase.sineInOut});
	FlxTween.tween(FlxG.sound.music, {volume: 0}, 0.3);

	new FlxTimer().start(2.5, (_) -> FlxG.switchState(new GameState("XEternalMessage")));
}

function denyWarning() {
	if (!FlxG.random.bool(1))
		Sys.exit(0);

	kill();
}

function kill() {
	transitioning = true;
	FlxG.sound.music?.stop();

	gordonRamsay = new FlxVideoSprite(0, 0);
	gordonRamsay.load(Paths.video("Hi"));
	gordonRamsay.bitmap.onFormatSetup.add(() -> {
		if (gordonRamsay.bitmap != null && gordonRamsay.bitmap.bitmapData != null) {
			var scale = Math.max(
				FlxG.width / gordonRamsay.bitmap.bitmapData.width,
				FlxG.height / gordonRamsay.bitmap.bitmapData.height
			);
			gordonRamsay.setGraphicSize(
				gordonRamsay.bitmap.bitmapData.width * scale,
				gordonRamsay.bitmap.bitmapData.height * scale
			);
			gordonRamsay.updateHitbox();
			gordonRamsay.screenCenter();
		}
	});
	gordonRamsay.bitmap.onEndReached.add(() -> Sys.exit(0));
	add(gordonRamsay);
	gordonRamsay.play();
}
