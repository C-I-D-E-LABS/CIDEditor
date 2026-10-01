import flixel.text.FlxText;
import flixel.text.FlxTextBorderStyle;

var fleetCam:FlxCamera;
var boom:FlxSprite;
var boom2:FlxSprite;
var clock:FlxSprite;
var clockTxt:FlxText;
var boomTimer:Float = 0;
var boomFrame:Bool = false;
var daHealthsmooth:Float = 1;

function create() {
    for (asset in [
        "game/sonicUI/chaos/boom1",
        "game/sonicUI/chaos/boom2",
        "game/sonicUI/chaos/clock",
        "game/sonicUI/chaos/comic border"
    ])
        graphicCache.cache(Paths.image(asset));
}

function postCreate() {
    fleetCam = new FlxCamera();
    fleetCam.bgColor = FlxColor.TRANSPARENT;
    FlxG.cameras.add(fleetCam, false);

    boom = new FlxSprite(0, 0).loadGraphic(Paths.image("game/sonicUI/chaos/boom1"));
    boom2 = new FlxSprite(0, 0).loadGraphic(Paths.image("game/sonicUI/chaos/boom2"));
    clock = new FlxSprite(0, 0).loadGraphic(Paths.image("game/sonicUI/chaos/clock"));
    for (sprite in [boom, boom2, clock]) {
        sprite.camera = fleetCam;
        sprite.x = 105;
        sprite.scale.set(0.9, 0.9);
        sprite.scrollFactor.set(0, 0);
        sprite.antialiasing = false;
        add(sprite);
    }
    boom.visible = true;
    boom2.visible = false;

    clockTxt = new FlxText(1250, 625, 150, "00:00");
    clockTxt.camera = fleetCam;
    clockTxt.scrollFactor.set(0, 0);
    clockTxt.setFormat(Paths.font("PhantomMuff.ttf"), 60, FlxColor.YELLOW, "left", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    clockTxt.borderSize = 2;
    clockTxt.angle = -30;
    add(clockTxt);

    var border = new FlxSprite(0, 0).loadGraphic(Paths.image("game/sonicUI/chaos/comic border"));
    border.camera = fleetCam;
    border.scrollFactor.set(0, 0);
    border.antialiasing = false;
    add(border);

    for (txt in [scoreTxt, missesTxt, accuracyTxt]) {
        txt.camera = fleetCam;
        txt.setFormat(Paths.font("PhantomMuff.ttf"), 20, FlxColor.YELLOW, "left", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        txt.borderSize = 1;
        remove(txt, true);
        add(txt);
    }

    healthBar.numDivisions = 1000;
    daHealthsmooth = health;
}

function postUpdate(elapsed:Float) {
    fleetCam.alpha = camHUD.alpha;
    fleetCam.visible = camHUD.visible;
    var down = camHUD.downscroll;
    var hudHeight = FlxG.height;

    try {
        timeTxt.visible = false;
    } catch(e:Dynamic) {}

    boomTimer += elapsed;
    if (boomTimer >= 0.08) {
        boomTimer = 0;
        boomFrame = !boomFrame;
        boom.visible = !boomFrame;
        boom2.visible = boomFrame;
    }

    boom.flipY = down;
    boom.x = 130;
    boom2.x = 130;
    boom.y = down ? 50 : -50;
    boom2.flipY = down;
    boom2.y = down ? 50 : -50;

    clock.flipY = down;
    clock.y = down ? -50 : 50;
    clockTxt.angle = down ? 30 : -30;
    clockTxt.x = 1120;
    clockTxt.y = down ? 70 : 590;

    var txts = [scoreTxt, missesTxt, accuracyTxt];
    var txtY = down ? [615, 641, 667] : [18, 44, 70];
    for (i in 0...txts.length) {
        txts[i].x = 1000;
        txts[i].y = txtY[i];
    }

    var barY = down ? 48 : 612;
    newBar.x = 50;
    newBar.y = down ? hudHeight - barY - newBar.height : barY;
    for (item in [newBar, healthBar, healthBarBG, iconP1, iconP2])
        item.camera = camHUD;
    for (item in [healthBar, healthBarBG])
        item.setPosition(newBar.x + 88, down ? hudHeight - (barY + 23) - item.height : barY + 23);

    daHealthsmooth = FlxMath.lerp(daHealthsmooth, health, Math.min(1, elapsed * 12));
    if (Math.abs(daHealthsmooth - health) < 0.001) daHealthsmooth = health;
    healthBar.value = daHealthsmooth;

    iconP2.x = newBar.x - 15;
    iconP1.x = newBar.x + 590;
    var iconY = down ? barY - 40 : barY - 45;
    for (icon in [iconP2, iconP1])
        icon.y = down ? hudHeight - iconY - icon.height : iconY;
    iconP1.health = daHealthsmooth / maxHealth;
    iconP2.health = 1 - (daHealthsmooth / maxHealth);

    var songTime = inst == null ? 0 : Std.int(Math.max(0, (inst.length - inst.time) / 1000));
    var minutes = Std.int(songTime / 60);
    var seconds = songTime % 60;
    clockTxt.text = minutes + ":" + (seconds < 10 ? "0" + seconds : "" + seconds);
}
