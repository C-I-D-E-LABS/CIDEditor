import hxvlc.flixel.FlxVideoSprite;
import funkin.game.PlayState;

var video:FlxVideoSprite;
var leaving:Bool = false;

function create() {
	FlxG.camera.bgColor = FlxColor.BLACK;
	FlxG.sound.music?.stop();

	var clips = [
		"Atomic",
		"BfFuckingDies",
		"Car",
		"FastBear",
		"g00seb4rn6",
		"JoeManReference",
		"Kys"
	];

	video = new FlxVideoSprite(0, 0);
	video.load(Paths.video("sanic/SanicGameOvers/" + clips[FlxG.random.int(0, clips.length - 1)]));
	video.bitmap.onFormatSetup.add(() -> {
		if (video.bitmap != null && video.bitmap.bitmapData != null) {
			var scale = Math.max(FlxG.width / video.bitmap.bitmapData.width, FlxG.height / video.bitmap.bitmapData.height);
			video.setGraphicSize(video.bitmap.bitmapData.width * scale, video.bitmap.bitmapData.height * scale);
			video.updateHitbox();
			video.screenCenter();
		}
	});
	video.bitmap.onEndReached.add(() -> {
		if (!leaving) {
			leaving = true;
			PlayState.loadSong("Too Fest", PlayState.difficulty);
			FlxG.switchState(new PlayState());
		}
	});
	add(video);
	video.play();
}

function destroy() {
	if (video != null) {
		video.stop();
		video.destroy();
	}
}
