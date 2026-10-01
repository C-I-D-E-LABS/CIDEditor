//
import flixel.addons.display.FlxBackdrop;

var grpBGparts:FlxTypedGroup;
var grpPreyBG:FlxTypedGroup;
var wallBG:FlxTypedGroup;
var lightning:FlxSprite;
var leggs:FlxSprite;
var leggsPeelout:FlxSprite;
var floorStarDust:FlxBackdrop;
var lamp:FlxBackdrop;
var deco:FlxBackdrop;

function create() {
    FlxG.sound.cache(Paths.sound('lightning'));

    dad.y += 320;
    dad.cameraOffset.y -= 50;
    dad.scale.set(0.1, 0.1);
    dad.alpha = 0;
    dad.x += 100;

    defaultCamZoom = 3;
    boyfriend.y += 845;
    boyfriend.cameraOffset.y = dad.cameraOffset.y;

    grpBGparts = new FlxTypedGroup();
    insert(1, grpBGparts);

    grpPreyBG = new FlxTypedGroup();
    insert(1, grpPreyBG);
        
    wallBG = new FlxTypedGroup();
    insert(2, wallBG);

    lightning = new FlxBackdrop(null, FlxAxes.X);
    lightning.frames = Paths.getSparrowAtlas('menus/freeplay/zones/lightning');
    lightning.animation.addByPrefix('anim4', 'play', 11, false);
    lightning.scale.set(1.1, 1.1);
    lightning.y = 467;
    lightning.x = 400;
    lightning.velocity.x = -50;
    lightning.alpha = 0;
    lightning.antialiasing = false;
    insert(0, lightning);

    for (i in 0...28) {
        var layer = 28 - i;
        var pair = Math.min(layer, 29 - layer);

        backdropss = new FlxBackdrop(Paths.image('exe/starved/prey/' + layer), FlxAxes.X);
        backdropss.y += 140;
        backdropss.antialiasing = false;
        backdropss.scale.set(0.6, 0.6);
        backdropss.velocity.x = -(200 - (pair * 10));
        backdropss.ID = layer;
        grpPreyBG.add(backdropss);
    }

    for (i in 0...4) {
        var layer = 4 - i;
        var speeds = [0, -90, -80, -80, -90];
        var yOffsets = [0, -10, 60, 158, 215];

        walls = new FlxBackdrop(Paths.image('exe/starved/walls/' + layer), FlxAxes.X);
        walls.y += 340;
        walls.antialiasing = false;
        walls.scale.set(1.1, 1.1);
        walls.velocity.x = speeds[layer];
        walls.y += yOffsets[layer];
        walls.ID = layer;
        wallBG.add(walls);
    }
	wallBG.visible = false;

    deco = new FlxBackdrop(Paths.image('exe/starved/furnaceAssets/deco'), FlxAxes.X, 0, 0);
    deco.y += 189;
    deco.scale.set(1, 1);
    deco.velocity.x = -400;
    grpBGparts.add(deco);

    leggs = new FlxSprite(boyfriend.x, boyfriend.y - 500);
    leggs.frames = Paths.getSparrowAtlas('characters/sonic/sonic-run');
    leggs.animation.addByPrefix('anim4', 'leggs', 16, true);
    leggs.animation.play('anim4');
    leggs.scale.set(1, 1);
    leggs.antialiasing = false;
    grpBGparts.add(leggs);

    leggsPeelout = new FlxSprite(boyfriend.x - 64, boyfriend.y - 519);
    leggsPeelout.frames = Paths.getSparrowAtlas('characters/sonic/SonicPeelout');
    leggsPeelout.animation.addByPrefix('anim4', 'run', 20, true);
    leggsPeelout.animation.play('anim4');
    leggsPeelout.scale.set(1, 1);
    leggsPeelout.antialiasing = false;
    grpBGparts.add(leggsPeelout);

    floorStarDust = new FlxBackdrop(null, FlxAxes.X, 0, 0);
	floorStarDust.frames = Paths.getSparrowAtlas('exe/starved/furnaceAssets/floorStarDust');
	floorStarDust.animation.addByPrefix('i', 'bgAnim', 12, true);
	floorStarDust.animation.play('i');
    floorStarDust.y += 189;
    floorStarDust.scale.set(1, 1);
    floorStarDust.velocity.x = -500;
    add(floorStarDust);
    
    lamp = new FlxBackdrop(null, FlxAxes.X, 500, 0);
	lamp.frames = Paths.getSparrowAtlas('exe/starved/furnaceAssets/Lamp');
	lamp.animation.addByPrefix('i', 'idle', 12, true);
	lamp.animation.play('i');
    lamp.y += 240;
    lamp.scale.set(1, 1);
    lamp.velocity.x = -800;
    lamp.scrollFactor.set(1.3, 0);
    add(lamp);

    leggs.visible = true;
    leggsPeelout.visible = false;
}

var flashTimer:Float = 6;
var elapsedTime:Float = 0;
var isFlashing:Bool = false;
var crtShader:CustomShader;

function postCreate() {
    if (!FlxG.save.data.modShaders) return;

    crtShader = new CustomShader("vcrDistort");
    for (cam in [camGame, camHUD])
        cam.addShader(crtShader);
    crtShader.noiseOn = false;
    crtShader.scanlinesOn = true;
    crtShader.distortionOn = false;
    crtShader.scandistortOn = false;
}

function update(elapsed:Float) {
    if (FlxG.save.data.camFlashing) {
        lightningFlash(elapsed);
    } else {
        lightning.alpha = 0;
    }
}

function lightningFlash(elapsed:Float) {
    elapsedTime += elapsed;

    if (!isFlashing && elapsedTime >= flashTimer) {
        isFlashing = true;
        elapsedTime = 0;
        flashTimer = FlxG.random.float(4, 10); // randomize next interval

        lightning.alpha = 1;
        lightning.animation.play('anim4');
        FlxG.sound.play(Paths.sound('lightning'), 7);
    }

    if (isFlashing && lightning.animation.finished) {
        lightning.alpha = 0;
        isFlashing = false;
    }
}
