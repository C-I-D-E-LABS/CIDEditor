import funkin.backend.utils.WindowUtils;
import funkin.game.PlayState;
import funkin.options.Options;
// ------------------------------
// Vars
// ------------------------------
public var songName:String = PlayState.SONG.meta.name;
public var weeks:Array<String> = ["Too Slow", "You Cant Run", "Triple Trouble"];

public var jumpCam:FlxCamera;
public var titleCam:FlxCamera;

var blackFuck:FlxSprite;
var daJumpscare:FlxSprite;
var simplejumpSpr:FlxSprite;
var daStatic:FlxSprite;
var startCircle:FlxSprite;
var mytween:FlxTween;

var staticBusy:Bool = false;
var simpleJumpBusy:Bool = false;

var soundtestGatedSongs:Array<String> = [
    "Endless", "Soulless", "Cycles", "Fate", "Hellbent", "Prey", "Chaos",
    "Milk", "Personel", "Too Fest", "Sunshine"
];

// ------------------------------
// Lifecycle
// ------------------------------
function create() {
    introLength = 0;
    FlxG.mouse.visible = false;

    cacheAssets();

    camExt = new FlxCamera();
	camExt.bgColor = 0x00000000;
	FlxG.cameras.add(camExt, false);

    jumpCam = new FlxCamera();
    jumpCam.bgColor = new FlxColor(0x00000000);
    FlxG.cameras.add(jumpCam, false);
    
    titleCam = new FlxCamera();
    titleCam.bgColor = new FlxColor(0x00000000);
    FlxG.cameras.add(titleCam, false);

    blackFuck = new FlxSprite().makeGraphic(1280, 720, FlxColor.BLACK);
    blackFuck.alpha = 0;
    blackFuck.scrollFactor.set();
    blackFuck.cameras = [titleCam];

    // --- Pre-build all reusable effect sprites once ---
    daJumpscare = new FlxSprite();
    daJumpscare.frames = Paths.getSparrowAtlas('effects/jumps/jumpscare');
    daJumpscare.animation.addByPrefix('jump', "sonicSPOOK", 24, false);
    daJumpscare.scale.set(1.1, 1.1);
    daJumpscare.updateHitbox();
    daJumpscare.screenCenter();
    daJumpscare.y += 470;
    daJumpscare.cameras = [jumpCam];
    daJumpscare.visible = false;
    daJumpscare.alpha = 0;
    add(daJumpscare);

    simplejumpSpr = new FlxSprite(0, 0);
    simplejumpSpr.loadGraphic(Paths.image("effects/jumps/simplejump"));
    //simplejumpSpr.scale.set(, FlxG.height);
    simplejumpSpr.updateHitbox();
    simplejumpSpr.screenCenter();
    simplejumpSpr.cameras = [jumpCam];
    simplejumpSpr.visible = false;
    simplejumpSpr.alpha = 0;
    add(simplejumpSpr);

    daStatic = new FlxSprite(0, 0);
    daStatic.frames = Paths.getSparrowAtlas('effects/static/default-static');
    daStatic.animation.addByPrefix('static', 'staticFLASH', 24, false);
    daStatic.setGraphicSize(FlxG.width, FlxG.height);
    daStatic.updateHitbox();
    daStatic.screenCenter();
    daStatic.cameras = [jumpCam];
    daStatic.visible = false;
    daStatic.alpha = 0;
    add(daStatic);

    PauseSubState.script = 'data/scripts/pause';

    if (FlxG.save.data.debugOvly)importScript("data/scripts/UI/debug_tools");

    importSongScripts();
    
    for (asset in ["three", "two", "one", "gofun"])
    graphicCache.cache(Paths.image("effects/countDown/" + asset));
}


// ------------------------------
// Setup helpers
// ------------------------------
function cacheAssets() {
    for (asset in [
        "effects/jumps/jumpscare",
        "effects/jumps/simplejump",
        "effects/jumps/simplejumpM",
        "effects/static/default-static"
    ])
        graphicCache.cache(Paths.image(asset));

    for (sound in ["sppok", "staticBUZZ", "jumpscare", "datOneSound", "pause", "unpause", "menu/scroll"])
        if (Assets.exists(Paths.sound(sound)))
            FlxG.sound.cache(Paths.sound(sound));
}

function importSongScripts() {
    switch (songName) {
        case 'Sl4sh3r', 'Prey', "Hunted":
            importScript("data/scripts/UI/PixelUI");
            importScript("data/scripts/removeHoldLoop");

        case 'Chaos':
            importScript("data/scripts/removeHoldLoop");
            importScript("data/scripts/UI/NormalUI");
            importScript("data/scripts/UI/fleetwayui");

        case 'Too Fest':
            importScript("data/scripts/UI/NormalUI");
            importScript("data/scripts/UI/sanicui");
            importScript("data/scripts/removeHoldLoop");
            importScript("data/scripts/Cams/camFollowNote");

        case "Too Slow", "You Cant Run", "Triple Trouble", "Endless", "Endless JP",
             "Endless US", "Endeavors", "Sunshine", "Milk", "ILLEGAL INSTRUCTION",
             "Hellbent", "Relentless", "Manual Blast", "Triple Trouble test":
            importScript("data/scripts/UI/NormalUI");
            importScript("data/scripts/removeHoldLoop");

        case "Cycles", "Fate", "Ethelfall", "Eclipsera", "Personel":
            importScript("data/scripts/removeHoldLoop");
            importScript("data/scripts/UI/NormalUI");
    }
}



function onStrumCreation(event) {
    switch(songName) {
        case "Personel", "Too Fest":
            event.sprite = "game/notes/meme";
    }
}

function onNoteCreation(event) {
    switch(songName) {
        case "Personel", "Too Fest":
            event.noteSprite = "game/notes/meme";
    }
}


// ------------------------------
// Song end / progress
// ------------------------------
function onSongEnd() {
    trace("JUST FINISHED " + songName);

    unlockSoundtestSong();
    updateStoryProgress();

    if (songName == "ILLEGAL INSTRUCTION" && FlxG.save.data.diedInCycles == true) {
        var unlocked:Array<Dynamic> = FlxG.save.data.unlockedSongs;
        if (unlocked == null) unlocked = [];

        if (!unlocked.contains("ILLEGAL INSTRUCTION")) {
            unlocked.push("ILLEGAL INSTRUCTION");
            FlxG.save.data.unlockedSongs = unlocked;
            FlxG.save.flush();
        }
    }
}

function unlockSoundtestSong() {
    if (!soundtestGatedSongs.contains(songName)) return;

    var unlocked:Array<Dynamic> = FlxG.save.data.unlockedSongs;
    if (unlocked == null) unlocked = [];

    if (!unlocked.contains(songName)) {
        unlocked.push(songName);
        FlxG.save.data.unlockedSongs = unlocked;
        FlxG.save.flush();
        trace("Soundtest song unlocked for freeplay: " + songName);
    }
}

function updateStoryProgress() {
    var storyProgress:Int = FlxG.save.data.songsBeaten == null ? 0 : FlxG.save.data.songsBeaten;

    switch (songName) {
        case "Too Slow":
            if (storyProgress < 1) storyProgress = 1;
        case "You Cant Run":
            if (storyProgress < 2) storyProgress = 2;
        case "Triple Trouble":
            if (storyProgress < 4) storyProgress = 4;
        case "Eclipsera":
            if (storyProgress < 3) storyProgress = 3;
    }

    if (weeks.contains(songName) || songName == "Eclipsera") {
        FlxG.save.data.songsBeaten = storyProgress;
        FlxG.save.flush();
        trace("Story Progress Updated: " + storyProgress);
    }
}

// ------------------------------
// Game over
// ------------------------------
function onGameOver(e){
    switch(songName){
        case "Cycles", "Fate", "Hellbent":
            e.cancel(); 
            FlxG.switchState(new GameState("gameovers/LordXGameOver"));
        case "Too Slow", "You Cant Run", "Triple Trouble":
            e.cancel(); 
            FlxG.switchState(new GameState("gameovers/SonicexeGameover"));
        case "Endless JP", "Endless", "Endless US":
            e.cancel(); 
            FlxG.switchState(new GameState("gameovers/MajinGameover"));
        case "Milk":
            e.cancel(); 
            FlxG.switchState(new GameState("gameovers/MilkGameover"));
        case "Too Fest":
            e.cancel();
            FlxG.switchState(new GameState("gameovers/SanicGameover"));
        default:
            // e.cancel(); 
            // FlxG.switchState(new PlayState());
    }
   
}

// ------------------------------
// Song start / title card
// ------------------------------
function onSongStart() {
    switch (songName) {
        case "Triple Trouble", "Cycles", "Chaos":
            titleCam.visible = false;
        default:
            titleCard();
    }
}

function titleCard() {
    startCircle = new FlxSprite();

    switch (songName) {
        case "Endless", "Endless US", "Endless JP", "Endeavors":
            startCircle.loadGraphic(Paths.image('effects/jumps/simplejumpM'));
            startCircle.scale.set(0.8, 0.8);
        default:
            startCircle.loadGraphic(Paths.image('effects/jumps/simplejump'));
            startCircle.scale.set(1, 1);
    }

    startCircle.screenCenter();
    blackFuck.alpha = 1;
    blackFuck.cameras = [titleCam];
    add(blackFuck);
    add(startCircle);
    startCircle.cameras = [titleCam];

    new FlxTimer().start(1.9, function(tmr:FlxTimer) {
        FlxTween.tween(blackFuck, {alpha: 0}, 1, {
            onComplete: function(twn:FlxTween) {
                remove(blackFuck);
                blackFuck.destroy();
            }
        });
        FlxTween.tween(startCircle, {alpha: 0}, 1, {
            onComplete: function(twn:FlxTween) {
                remove(startCircle);
                startCircle.destroy();
            }
        });
    });
}

// ------------------------------
// Camera / window utility events
// ------------------------------
function zoomControl(zoomAmt:Int) {
    defaultCamZoom = zoomAmt;
}

function zoomTween(zoomAmt:Int, time:Int, easeType:String = "") {
    mytween = FlxTween.tween(PlayState.instance, {defaultCamZoom: zoomAmt}, time, {ease: FlxEase = easeType});
}

function windowName(windowName = '') {
    WindowUtils.winTitle = windowName;
}

// ------------------------------
// Jumpscare / static effects (logic only — sprites reused from create())
// ------------------------------
function simpleJump() {
    if (!FlxG.save.data.jumpscares|| simpleJumpBusy) return;
    simpleJumpBusy = true;

    trace('SIMPLE JUMPSCARE');

    simplejumpSpr.visible = true;
    simplejumpSpr.alpha = 1;

    FlxG.camera.shake(0.0025, 0.50);
    FlxG.sound.play(Paths.sound('sppok'), 1);

    new FlxTimer().start(0.2, function(tmr:FlxTimer) {
        trace('ended simple jump');
        simplejumpSpr.visible = false;
        simplejumpSpr.alpha = 0;
    });

    daStatic.visible = true;
    daStatic.alpha = FlxG.random.float(0.1, 0.5);
    FlxG.sound.play(Paths.sound('staticBUZZ'));
    daStatic.animation.play('static', true);

    daStatic.animation.finishCallback = function(pog:String) {
        trace('ended static (from simpleJump)');
        if (daStatic != null) {
            daStatic.visible = false;
            daStatic.alpha = 0;
        }
        simpleJumpBusy = false;
    }
}

function staticFlash(lestatic:Int = 0, leopa:Bool = true) {
    if (!FlxG.save.data.camFlashing || staticBusy) return;
    staticBusy = true;

    daStatic.visible = true;
    daStatic.alpha = 1;
    FlxG.sound.play(Paths.sound('staticBUZZ'));
    daStatic.animation.play('static', true);

    daStatic.animation.finishCallback = function(pog:String) {
        trace('ended static');
        if (daStatic != null) {
            daStatic.visible = false;
            daStatic.alpha = 0;
        }
        staticBusy = false;
    }
}

function static(lestatic:Int = 0, leopa:Bool = true) {
    staticFlash(lestatic, leopa);
}

function thatOneJump() {
    if (!FlxG.save.data.jumpscares) return;

    FlxG.sound.play(Paths.sound('jumpscare'), 1);
    if (Assets.exists(Paths.sound('datOneSound')))
        FlxG.sound.play(Paths.sound('datOneSound'), 1);

    daJumpscare.visible = true;
    daJumpscare.alpha = 1;
    daJumpscare.animation.play('jump', true);

    daJumpscare.animation.finishCallback = function(pog:String) {
        trace('ended jump');
        if (daJumpscare != null)
            daJumpscare.visible = false;
    }
}


function count(display:Int = 0) {
	var asset = ["three", "two", "one", "gofun"][display];
	if (asset == null) return;

	FlxG.cameras.remove(camExt, false);
	FlxG.cameras.add(camExt, false);
	camExt.visible = true;
	camExt.alpha = 1;
	camExt.zoom = 1;
	camExt.scroll.set();
	camExt.bgColor = 0x00000000;

	var sprite = new FlxSprite().loadGraphic(Paths.image("effects/countDown/" + asset));
	sprite.scrollFactor.set();
	sprite.cameras = [camExt];
	sprite.updateHitbox();
	sprite.alpha = 1;
	sprite.screenCenter();
	sprite.y -= 100;
	add(sprite);

	FlxTween.tween(sprite, {y: sprite.y + 100, alpha: 0}, Conductor.crochet / 1000, {
		ease: FlxEase.cubeInOut,
		onComplete: function(_) {
			remove(sprite);
			sprite.destroy();
		}
	});
}

// ------------------------------
// Note Movement
// ------------------------------
