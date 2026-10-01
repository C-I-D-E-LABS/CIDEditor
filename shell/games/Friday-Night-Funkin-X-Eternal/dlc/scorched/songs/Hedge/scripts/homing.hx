var canDodge:Bool = false;
var dodging:Bool = false;

function create(){
}

function stepHit(){
    switch(curStep){
        case 1264:
        var warning:FlxSprite = new FlxSprite(boyfriend.x - 60, boyfriend.y + 369);
        warning.frames = Paths.getSparrowAtlas("stages/hog/TargetLock");
        warning.animation.addByPrefix("warn", 'TargetLock', 24, false);
        warning.animation.play("warn", true);
        warning.alpha = 0;
        add(warning);
        //warning.setGraphicSize(Std.int(warning.width * 2.5));
            new FlxTimer().start(0.8, function(lol:FlxTimer)
                {
                    FlxTween.tween(warning, {alpha: 1}, 0.5, {ease: FlxEase.quadInOut});
                    warning.animation.play("warn", true);
                });

            canDodge = true;
            new FlxTimer().start(1.57, function(lol:FlxTimer)
            {
                if (!dodging) {
                    health = 0;
                }
                remove(warning);
                canDodge = false;
            });
    }
}

function update(elapsed:Float)
{
	if (canDodge && FlxG.keys.justPressed.SPACE)
	{
		dodging = true;
		boyfriend.playAnim('dodge', true);

		boyfriend.animation.finishCallback = function(a:String)
		{
			if(a == 'dodge'){
        	new FlxTimer().start(0.5, function(a:FlxTimer)
        	{
        		dodging = false;
        		canDodge = false;
        		boyfriend.specialAnim = false;
        		trace('didnt die?');
        		// im using bandage method for this shit cus it keeps breaking for some unholy reason
        		// fleetway you make me want to kill myself i swear to god
        	});
        }}
    }
}