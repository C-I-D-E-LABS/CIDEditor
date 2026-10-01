import flixel.text.FlxTextBorderStyle;

var codeEntries:Array<Dynamic> = [
    { code: "46  12  25",  color: 0xFF000893 },
    { code: "36  04  20",  color: 0xFF3B4DCD },
    { code: "05  11  15",  color: 0xFF2140FE },
    { code: "84  13  69",  color: 0xFFA34A9F},
    { code: "08  21  96",  color: 0xFFFFBB00 },
    { code: "06  06  06",  color: 0xFFF88A25 },
    { code: "06  23  91",  color: 0xFF0000 },    
    { code: "07  07  07",  color: 0xFF3D3D5A},
 ];

var LEFT_GROUP_SIZE:Int = 4;

var promptTxt:FlxText;
var grpCodes:FlxTypedGroup;
var crtShader = null;

function create() {
    crtShader = new CustomShader("vcrDistort");
    FlxG.camera.addShader(crtShader);
    crtShader.distortionOn = true;
    crtShader.scandistortOn = true;

    var overlay:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xDD000000);
    add(overlay);

    grpCodes = new FlxTypedGroup();
    add(grpCodes);

    var fontSize:Int = 26;
    var rowHeight:Float = 58;
    var colWidth:Float = FlxG.width / 2;

    var leftEntries  = codeEntries.slice(0, LEFT_GROUP_SIZE);
    var rightEntries = codeEntries.slice(LEFT_GROUP_SIZE);

    var rows:Int = Std.int(Math.max(leftEntries.length, rightEntries.length));
    var totalHeight:Float = rows * rowHeight;
    var startY:Float = (FlxG.height / 2) - (totalHeight / 2);

    for (i in 0...leftEntries.length) {
        var entry = leftEntries[i];
        var codeTxt:FlxText = new FlxText(0, startY + (i * rowHeight), colWidth, entry.code, fontSize);
        codeTxt.setFormat(Paths.font("sonic-cd-menu-font.ttf"), fontSize, entry.color, "center",
            FlxTextBorderStyle.SHADOW, FlxColor.BLACK);
        codeTxt.borderSize = 3;
        codeTxt.letterSpacing = 6;
        grpCodes.add(codeTxt);
    }

    for (i in 0...rightEntries.length) {
        var entry = rightEntries[i];
        var codeTxt:FlxText = new FlxText(colWidth, startY + (i * rowHeight), colWidth, entry.code, fontSize);
        codeTxt.setFormat(Paths.font("sonic-cd-menu-font.ttf"), fontSize, entry.color, "center",
            FlxTextBorderStyle.SHADOW, FlxColor.BLACK);
        codeTxt.borderSize = 3;
        codeTxt.letterSpacing = 6;
        grpCodes.add(codeTxt);
    }

    promptTxt = new FlxText(30, FlxG.height - 48, FlxG.width, "[PRESS ENTER TO CONTINUE]", 20);
    promptTxt.setFormat(Paths.font("sonic-cd-menu-font.ttf"), 20, 0xFFAAAAAA, "center",
        FlxTextBorderStyle.SHADOW, FlxColor.BLACK);
    promptTxt.borderSize = 3;
    promptTxt.scrollFactor.set(0, 0);
    add(promptTxt);

    statc = new FlxSprite(FlxG.width, FlxG.height);
	statc.frames = Paths.getFrames('effects/static/vcr');
	statc.animation.addByPrefix('idle', 'idle', 24);
	statc.setGraphicSize(FlxG.width, FlxG.height + 400);
    statc.screenCenter();
    statc.animation.play("idle");
    statc.alpha = 0.3;
    statc.y -= 122;
    add(statc);
}

var localTime:Float = 0;
function update(elapsed:Float) {
    localTime += elapsed;
    if (crtShader != null) crtShader.iTime = localTime;
    if (controls.ACCEPT || controls.BACK) {
        FlxG.switchState(new GameState("XEternalSoundTest"));
    }
}

function destroy() {
    if (crtShader != null) {
        FlxG.camera.removeShader(crtShader);
        crtShader = null;
    }
}
