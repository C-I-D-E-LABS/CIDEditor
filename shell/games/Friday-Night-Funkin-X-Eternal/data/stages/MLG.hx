import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxAxes;

var cumBackdrop:FlxBackdrop;
var weedVision:Dynamic;
var sanicTime:Float = 4;
var sanics = [];
var sanicPool = [];

function create() {
    graphicCache.cache(Paths.image("exe/sanic/Lesanic"));
    graphicCache.cache(Paths.image("exe/sanic/cumon"));

    if (FlxG.save.data.modShaders) {
        weedVision = new CustomShader("weedvision");
        weedVision.daHue = 0;
    }
}

function postCreate() {
    cumBackdrop = new FlxBackdrop(Paths.image("exe/sanic/cumon"), FlxAxes.XY);
    cumBackdrop.camera = camGame;
    cumBackdrop.scrollFactor.set(0, 0);
    cumBackdrop.visible = false;
    cumBackdrop.active = false;
    insert(members.indexOf(bg) + 1, cumBackdrop);

    for (i in 0...6) {
        var sanic = new FlxSprite().loadGraphic(Paths.image("exe/sanic/Lesanic"));
        sanic.cameras = [camGame];
        sanic.visible = false;
        sanic.active = false;
        insert(members.indexOf(bg) + 1, sanic);
        sanicPool.push(sanic);
    }
}

function update(elapsed:Float) {
    if (FlxG.save.data.modShaders && curStep >= 912 && curStep < 1168)
        weedVision.daHue = Conductor.songPosition / 500;

    if (curStep >= 654 && curStep < 1168) {
        while (sanics.length > 0) {
            var sanic = sanics.pop();
            sanic.visible = false;
            sanic.active = false;
            sanic.velocity.x = 0;
            sanicPool.push(sanic);
        }

        sanicTime = FlxG.random.float(6, 12);
        return;
    }

    sanicTime -= elapsed;

    if (sanicTime <= 0 && sanics.length < 6) {
        sanicTime = FlxG.random.float(9, 16);

        var dir = FlxG.random.bool() ? 1 : -1;
        var count = 1;

        if (FlxG.random.bool(45))
            count = 2;

        for (lane in [0, FlxG.random.bool() ? -170 : 170]) {
            if (lane != 0 && !FlxG.random.bool(40)) continue;

            for (i in 0...count) {
                if (sanics.length >= 6) break;
                if (sanicPool.length <= 0) break;

                var sanic = sanicPool.pop();
                sanic.x = (dir == 1 ? bg.x - sanic.width - 260 : bg.x + bg.width + 260) - (i * 220 * dir);
                sanic.y = bg.y + 1150 + lane;
                sanic.velocity.x = dir * FlxG.random.float(900, 1400);
                sanic.flipX = dir < 0;
                sanic.visible = true;
                sanic.active = true;
                sanics.push(sanic);
            }
        }
    }

    var i = sanics.length - 1;
    while (i >= 0) {
        var sanic = sanics[i];

        if (sanic.x < bg.x - sanic.width - 800 || sanic.x > bg.x + bg.width + 800) {
            sanics.splice(i, 1);
            sanic.visible = false;
            sanic.active = false;
            sanic.velocity.x = 0;
            sanicPool.push(sanic);
        }

        i--;
    }
}

function stepHit(curStep:Int) {
    switch(curStep) {
        case 654:
            cumBackdrop.visible = true;
            cumBackdrop.active = true;
            cumBackdrop.velocity.set(450, 320);

        case 912:
            cumBackdrop.visible = false;
            cumBackdrop.active = false;
            cumBackdrop.velocity.set(0, 0);

            if (FlxG.save.data.modShaders) {
                camGame.addShader(weedVision);
                camHUD.addShader(weedVision);
            }

            bg.alpha = 0;
            mlgbg.alpha = 1;

        case 1168:
            if (FlxG.save.data.modShaders) {
                camGame.removeShader(weedVision);
                camHUD.removeShader(weedVision);
            }

            mlgbg.destroy();
            bg.alpha = 1;
    }
}
