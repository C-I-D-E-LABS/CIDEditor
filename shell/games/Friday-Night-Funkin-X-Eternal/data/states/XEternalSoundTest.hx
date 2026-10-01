import flixel.addons.display.FlxBackdrop;
import flixel.text.FlxTextBorderStyle;
import flixel.math.FlxMath;
import funkin.game.cutscenes.VideoCutscene;
import Loader;
import funkin.backend.week.Week;

var itemList:Array<String> = ['FM N0.', 'PCM N0.', 'DA N0.'];
var curSelected:Int = 0;
var isSelected:Bool = false;
var fmValue:Int = 0;
var pcmValue:Int = 0;
var daValue:Int = 0;

static var curSoundtestCameo:String = "";

var itemCodes:Array<String> = [
	"36 4 20", "6 6 6", "46 12 25", "5 11 15",
	"86 13 69", "7 7 7", "6 23 91", "8 21 96"
];

var itemActions:Array<Void->Void> = [
	() -> defaultSwitchToSong('Too Fest'),
	() -> defaultSwitchToWeek('tailsdoll'),
	() -> defaultSwitchToSong('Endless'),
	() -> defaultSwitchToSong('Milk'),
	() -> defaultSwitchToSong('Personel'),
	() -> defaultSwitchToWeek("lordx"),
	() -> defaultSwitchToSong('Prey'),
	() -> defaultSwitchToSong('Chaos'),
];
function defaultSwitchToSong(song:String) {
	if (!Assets.exists(Paths.json('../songs/'+song+'/meta'))) {
		FlxG.stage.window.alert('where the fuck $song ????????????', 'SERIOUS ERROR AS SERIOUS AS #serious-chat');
		return;
	}

	isSelected = true;
	Loader.loadSongWithReturn(song, "hard", "XEternalSoundTest");
	FlxG.sound.music?.fadeOut(0.95, 0, twn -> FlxG.sound.music?.stop());
	FlxG.switchState(new PlayState());
}

function defaultSwitchToWeek(weekName:String) {
	var week = Week.loadWeek(weekName, true);
	if (week == null) {
		FlxG.stage.window.alert('where the fuck week $weekName ????????????', 'SERIOUS ERROR AS SERIOUS AS #serious-chat');
		return;
	}

	isSelected = true;
	Loader.loadWeekWithReturn(week, "hard", "XEternalSoundTest");
	FlxG.sound.music?.fadeOut(0.95, 0, twn -> FlxG.sound.music?.stop());
	FlxG.switchState(new PlayState());
}

function defaultCameo(bro:String) {
	isSelected = true;

	curSoundtestCameo = bro;
	FlxG.sound.music?.fadeOut(0.7, 0, twn -> FlxG.sound.music?.stop());

	windowUtil.resizeGameAndWindow(1280, 720, 0.75, () -> {
		persistentDraw = false;

		FlxG.camera._fxFlashDuration = 0.75;
		FlxG.camera._fxFlashAlpha = 1;
		openSubState(new GameSubState('custom/soundtest/cameo'));
	});
}

function defaultVideo(video:String) {
	isSelected = true;

	FlxG.sound.music?.fadeOut(0.95, 0, twn -> FlxG.sound.music?.pause());
	windowUtil.resizeGameAndWindow(1280, 720, 1, () -> {
		persistentDraw = false;
		openSubState(new VideoCutscene(Paths.video(video), () -> {
			FlxG.sound.music?.resume();
			FlxG.sound.music?.fadeIn(1, 1);
			windowUtil.resizeGameAndWindow(1280, 960, 1, () -> {
				FlxG.camera._fxFlashAlpha = 0;
				persistentDraw = true;
				isSelected = false;
			});
		}));
	});
}

var rewatchBtn:FunkinText;

function create(){
	for (asset in ["menus/soundtest/bg", "menus/soundtest/name", "menus/soundtest/desc"])
		graphicCache.cache(Paths.image(asset));

	FlxG.sound.playMusic(Paths.music('menus/soundtest'), 1);
	FlxG.mouse.visible = true;

	bg = new FlxBackdrop().loadGraphic(Paths.image("menus/soundtest/bg")); 
	bg.screenCenter();
	bg.velocity.set(FlxG.random.float(-50, 50), FlxG.random.float(-50, 50));
	add(bg);

	soundtestTxt = new FlxSprite().loadGraphic(Paths.image("menus/soundtest/name")); 
	soundtestTxt.screenCenter();
	soundtestTxt.scale.set(4,4);
	soundtestTxt.y -= 145;
	add(soundtestTxt);

	itemTextGroup = new FlxGroup();
	for(i in 0...itemList.length){
		itemText = new FlxText(0, 425, 0, itemList[i], 29);
		itemText.antialiasing = false;
		itemText.letterSpacing = 6.5;
		itemTextGroup.add(itemText);
		itemText.ID = i;
	}
	add(itemTextGroup);

	for (i => xPos in [185, 485, 845])
		itemTextGroup.members[i].x = xPos;

	rewatchBtn = new FunkinText(20, FlxG.height - 60, 0, "UNLOCKED CODES CLICK ME!!!", 18);
	rewatchBtn.setFormat(Paths.font("sonic-cd-menu-font.ttf"), 18, FlxColor.fromRGB(174, 179, 251), 'left');
	rewatchBtn.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.fromRGB(106, 110, 159), 3);
	rewatchBtn.scrollFactor.set(0, 0);
	rewatchBtn.visible = (FlxG.save.data.soundtestVideoWatched == true);
	add(rewatchBtn);

	changeSelection(0, true);

	if (FlxG.save.data.soundtestVideoWatched != true) {
		FlxG.save.data.soundtestVideoWatched = true;
		FlxG.save.flush();

		isSelected = true;

		new FlxTimer().start(0.1, (_) -> {
			openCodesDisplay(() -> {
				isSelected = false;
				rewatchBtn.visible = true;
			});
		});
	}
}

function openCodesDisplay(onComplete:Void->Void) {
	_codesOnComplete = onComplete;
	FlxG.switchState(new GameState("XEternalCodesDisplay"));
}

static var _codesOnComplete:Void->Void = null;
static function onCodesDisplayClosed() {
	if (_codesOnComplete != null) {
		_codesOnComplete();
		_codesOnComplete = null;
	}
}

function update(elapsed:Float) {
	FlxG.camera.scroll.x = FlxMath.lerp(FlxG.camera.scroll.x, (FlxG.mouse.screenX - FlxG.width / 2) * -0.02, FlxMath.bound(elapsed * 4, 0, 1));
	FlxG.camera.scroll.y = FlxMath.lerp(FlxG.camera.scroll.y, (FlxG.mouse.screenY - FlxG.height / 2) * -0.015, FlxMath.bound(elapsed * 4, 0, 1));

	if (!isSelected) {
		changeSelection((controls.LEFT_P ? -1 : 0) + (controls.RIGHT_P ? 1 : 0));
		changeNumber((controls.UP_P ? 1 : 0) + (controls.DOWN_P ? -1 : 0));

		for (item in itemTextGroup.members)
			if (FlxG.mouse.overlaps(item)) {
				if (item.ID != curSelected) changeSelection(item.ID - curSelected);
				else if (FlxG.mouse.justPressed) changeNumber(1);
			}

		if (FlxG.mouse.wheel != 0)
			changeNumber(FlxG.mouse.wheel);

		if(controls.ACCEPT) accept();
		if(controls.BACK) back();

		var rewatchTriggered:Bool = FlxG.keys.justPressed.R ||
			(FlxG.mouse.justPressed && rewatchBtn.visible && FlxG.mouse.overlaps(rewatchBtn));
		if (FlxG.save.data.soundtestVideoWatched == true && rewatchTriggered) {
			isSelected = true;
			openCodesDisplay(() -> {
				isSelected = false;
			});
		}
	}
}

function accept() {

	var code = fmValue + " " + pcmValue + " " + daValue;
	var idx = itemCodes.indexOf(code);
	if (idx != -1) itemActions[idx]();
}

function back() {
	isSelected = true;
	FlxG.switchState(new MainMenuState());
}

function changeSelection(change:Int, ?force:Bool) {
	if (change == 0 && !force) return;

	curSelected += change;
	if (curSelected < 0) curSelected = itemList.length - 1;
	else if (curSelected >= itemList.length) curSelected = 0;

	itemTextGroup.forEach(item -> {
		if(item.ID == curSelected) {
			item.setFormat(Paths.font("sonic-cd-menu-font.ttf"), 27, FlxColor.fromRGB(254, 174, 0));
			item.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.fromRGB(253, 36, 3), 4);
		} else {
			item.setFormat(Paths.font("sonic-cd-menu-font.ttf"), 27, FlxColor.fromRGB(174, 179, 251));
			item.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.fromRGB(106, 110, 159), 4);
		}
	});

	changeNumber(0, force);
}

function changeNumber(selection:Int, ?force:Bool) {
	if (selection == 0 && !force) return;

	switch(curSelected) {
		case 0:
			fmValue += selection;
			if (fmValue < 0) fmValue = 99;
			if (fmValue > 99) fmValue = 0;
		case 1:
			pcmValue += selection;
			if (pcmValue < 0) pcmValue = 99;
			if (pcmValue > 99) pcmValue = 0;
		case 2:
			daValue += selection;
			if (daValue < 0) daValue = 99;
			if (daValue > 99) daValue = 0;
	}
	for (i => value in [fmValue, pcmValue, daValue])
		itemTextGroup.members[i].text = itemList[i] + (value < 10 ? '0' + value : value);
}
