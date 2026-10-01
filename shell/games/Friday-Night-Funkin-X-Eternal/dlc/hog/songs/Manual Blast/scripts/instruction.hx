// add as instance vars in your state
var illegalTimer:FlxTimer;
var maxAmt:Int = 5;
var activeIllegalTexts:Array<FlxText> = [];

function stepHit(curStep:Int) {
    switch(curStep){
        case 864:
            startIllegalInstructionFX();
        case 4160:
            maxAmt = 16;
    }
}

function startIllegalInstructionFX()
{
    illegalTimer = new FlxTimer();
    scheduleNextIllegalBunch();
}

function scheduleNextIllegalBunch()
{
    illegalTimer.start(FlxG.random.float(0.8, 2.2), (_) -> spawnIllegalBunch());
}

function spawnIllegalBunch()
{
    var count:Int = FlxG.random.int(1, maxAmt);
    for (i in 0...count)
    {
        spawnIllegalText();
    }
    scheduleNextIllegalBunch();
}

function spawnIllegalText()
{
    var addr:String = StringTools.hex(FlxG.random.int(0, 0xFFFFFF), 8);
    var txt:FlxText = new FlxText(0, 0, 500, 'ILLEGALINSTRUCTION' + addr, 36);
    txt.font = Paths.font("sonic1HUD.ttf");
    txt.color = FlxColor.WHITE;
    txt.alpha = 0;

    var maxAttempts:Int = 20;
    var placed:Bool = false;
    var px:Float = 0;
    var py:Float = 0;

    for (attempt in 0...maxAttempts)
    {
        px = FlxG.random.float(0, FlxG.width - txt.width);
        py = FlxG.random.float(0, FlxG.height - txt.height);

        var overlaps:Bool = false;
        for (other in activeIllegalTexts)
        {
            if (px < other.x + other.width &&
                px + txt.width > other.x &&
                py < other.y + other.height &&
                py + txt.height > other.y)
            {
                overlaps = true;
                break;
            }
        }

        if (!overlaps)
        {
            placed = true;
            break;
        }
    }

    // if we couldn't find a non-overlapping spot after maxAttempts, skip this spawn
    if (!placed)
    {
        txt.destroy();
        return;
    }

    txt.x = px;
    txt.y = py;

    add(txt);
    activeIllegalTexts.push(txt);

    FlxTween.tween(txt, {alpha: 1}, FlxG.random.float(0.15, 0.35), {
        onComplete: (_) -> {
            FlxTween.tween(txt, {alpha: 0}, FlxG.random.float(0.4, 0.9), {
                startDelay: FlxG.random.float(0.2, 0.6),
                onComplete: (_) -> {
                    remove(txt);
                    activeIllegalTexts.remove(txt);
                    txt.destroy();
                }
            });
        }
    });
}

function stopIllegalInstructionFX()
{
    if (illegalTimer != null)
        illegalTimer.cancel();
}