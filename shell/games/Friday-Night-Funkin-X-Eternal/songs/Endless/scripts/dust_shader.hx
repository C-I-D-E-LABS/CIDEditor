//
public var dust:CustomShader;
public var chromCurv:CustomShader;
public var rectMask:CustomShader;

function postCreate() {
    if (FlxG.save.data.modShaders) {
        createDust();
    } 
}

function createDust() {
    dust = new CustomShader("lab_dust");
    dust.cameraZoom = FlxG.camera.zoom; dust.flipY = true;
    dust.cameraPosition = [FlxG.camera.scroll.x, FlxG.camera.scroll.y];
    dust.time = 0; dust.res = [FlxG.width, FlxG.height];
    dust.LAYERS = 10; dust.DEPTH = 2;
    dust.WIDTH = .08; dust.SPEED = .5;
    dust.STARTING_LAYERS = 4;
    dust.pixely = false;
    dust.BRIGHT = 1;

    dust.dustFade = boyfriend.y + 100;
    dust.dustRange = boyfriend.y;

    camGame.addShader(dust);
    dust.BRIGHT = 1;
}



var tottalTimer:Float = 0;
function update(elapsed:Float) {
    if (dust == null) return;
    tottalTimer += elapsed;

    dust.time = tottalTimer*2;    

    dust.cameraZoom = FlxG.camera.zoom;
    dust.cameraPosition = [FlxG.camera.scroll.x, FlxG.camera.scroll.y];
}