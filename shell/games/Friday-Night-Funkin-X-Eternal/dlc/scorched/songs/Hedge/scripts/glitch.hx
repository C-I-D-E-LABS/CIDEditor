import openfl.filters.ShaderFilter;
import openfl.display.ShaderInput;
import flixel.tweens.FlxTween;
import funkin.backend.shaders.CustomShader;
import flixel.util.FlxColor;
import lime.system.System;

var staticAlpha:Float = 1;

var scoreRandom:Bool = false;

var score_arr:Array<Array<String>> = [
    ["sC0r3: ", "mIsees: ", "Ra11utNg: ", "342hj1: ", "agehjk3: ", "4276uihj: "],
    ["m11ses: ", "raITNtg: ", "scIrh4: ", "5436yu: ", "4uihja: ", "a7d5h: "],
    ["R4t3ng: ", "socRec: ","Moosiies: ","876rygu: ","8ubnmb1: ", "z7dyguhj: "]
];

var camGlitchShader:CustomShader;
var camFuckShader:CustomShader;

var staticlmao:CustomShader;
var glitchThingy:CustomShader;
var staticOverlay:CustomShader;
var glitchOverlay:CustomShader;

var canDodge:Bool = false;
var dodging:Bool = false;

var glitchShaders:Array<GlitchShaderA> = [];

function postCreate()
{
    // glitchShader = new CustomShader('glitchScorched');
    // glitchShader.iTime = 0.;
    // glitchShader.time = 0;

    staticlol = new CustomShader('hog/StaticShader');
    camGame.addShader(staticlol);
    staticlol.iTime = 0;
    staticlol.iResolution = [FlxG.width, FlxG.height];
    staticlol.alpha = staticAlpha;
    staticlol.enabled = false;
    staticlol.iTime = 0.;
    staticlol.time = 0;

    camGlitchShader = new CustomShader('hog/GlitchShaderB');
    camGlitchShader.iResolution = [FlxG.width, FlxG.height];

    staticlmao = new CustomShader('hog/StaticShader');
    staticlmao.iTime = 0;
    staticlmao.time = 0;

    glitchThingy = new CustomShader('hog/DistortGlitchShader');
    glitchThingy.iTime = 0;
    glitchThingy.time = 0;

    camFuckShader = new CustomShader('hog/fuck');
    camGame.addShader(camFuckShader);
    camFuckShader.iTime = 0;
    camFuckShader.amt = 0;
    camFuckShader.speed = 0;
    camFuckShader.enabled = false;
}

var elapsedTime:Float = 0;

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
        	});
        }}
    }
}

function postUpdate(elapsed:Float)  //aint no party like a diddy party          //John you diddy blud
{
    if(scoreRandom){
        var randInt:Int = FlxG.random.int(0, score_arr[0].length);

        if (scoreTxt != null) scoreTxt.text = score_arr[0][randInt] + songScore;
        
        if (missesTxt != null) missesTxt.text = score_arr[1][randInt] + misses;

        if (accuracyTxt != null) accuracyTxt.text = score_arr[2][randInt] + (accuracy < 0 ? "-%" : CoolUtil.quantize(accuracy * 100, 100)) + " - " + curRating.rating; 
    }

    elapsedTime += elapsed;
    var res = [dad.width, dad.height];

    // glitchShader.iTime += elapsed;
    // glitchShader.iResolution = res;
    // glitchShader.prob = 1;
    // glitchShader.glitchSpeed = 0.2;
    // glitchShader.glitchScale = 0.5;
    // glitchShader.time = 20;

    if(staticlol != null){
			staticlol.iTime = Conductor.songPosition / 1000;
			staticlol.alpha = staticAlpha;
		}
    if(staticlmao != null){
        staticlmao.iTime = Conductor.songPosition / 1000;
        staticlmao.alpha = staticAlpha;
		}
		
    if(glitchThingy!=null){
        glitchThingy.iTime = Conductor.songPosition / 1000;
    }

		if(camFuckShader.enabled)
            camFuckShader.amt = 0.15;
            camFuckShader.speed = 1;
            camFuckShader.iTime = Conductor.songPosition / 1000;
		
		// if(camGlitchShader!=null){
		// 	camGlitchShader.iResolution = [FlxG.width, FlxG.height];
		// 	camGlitchShader.iTime = Conductor.songPosition / 1000;
		// 	if(camGlitchShader.amount>=1)camGlitchShader.amount=1;
		// 	//if(dad.curCharacter.startsWith("scorchedglitch"))
		// 		//camGlitchShader.amount = FlxMath.lerp(0.1, camGlitchShader.amount, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
		// 	//else
		// 		//camGlitchShader.amount = FlxMath.lerp(0, camGlitchShader.amount, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
		// }
		for(shader in glitchShaders){
			shader.iTime += elapsed;
		}
}

function glitchKill(spr:FlxSprite,dontKill:Bool=false){
	var shader = new CustomShader('hog/GlitchShaderA');
	shader.iResolution.value = [spr.width, spr.height];
	piss.push(FlxTween.tween(shader, {GlitchAmount: 1.25}, 2, {
		ease: FlxEase.cubeInOut,
		onComplete: function(tw: FlxTween){
			glitchShaders.remove(shader);
			spr.visible=false;
			if(!dontKill){
				remove(spr);
				spr.destroy();
			}
		}
	}));
	glitchShaders.push(shader);
	spr.shader = shader;
}

function glitchFreeze() {
    switch(FlxG.random.int(1, 2)) 
    {
        case 1:
            staticlol.enabled = true;
            scoreRandom = true;
            defaultCamZoom = 1.2;
            new FlxTimer().start(0.65, function(byebye:FlxTimer) {
                staticlol.enabled = false;
                scoreRandom = false;
                defaultCamZoom = 0.67;
                trace("silly");
            });
        case 2:
            camFuckShader.amt = 0.15;
            scoreRandom = true;
            defaultCamZoom = 1.2;
            new FlxTimer().start(0.65, function(byebye:FlxTimer) {
                camFuckShader.amt = 0;
                scoreRandom = false;
                defaultCamZoom = 0.67;
                trace("lol");
            });
    }
}

function stepHit() {
    switch (curStep) {
        case 1264:
            var warning:FlxSprite = new FlxSprite(boyfriend.x - 60, boyfriend.y + 369);
            warning.frames = Paths.getSparrowAtlas("stages/hog/TargetLock");
            warning.animation.addByPrefix("warn", 'TargetLock', 24, false);
            warning.animation.play("warn", true);
            warning.alpha = 0;
            add(warning);
            new FlxTimer().start(0.8, function(lol:FlxTimer)
                {
                    FlxTween.tween(warning, {alpha: 1}, 0.5, {ease: FlxEase.quadInOut});
                    warning.animation.play("warn", true);
                    warning.shader = glitchShader;
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
        case 1283:
            disableGhosts = true;
        case 1284:
            glitchFreeze();
            dad.shader = glitchShader;
        case 1290:
            dad.shader = null;
        case 1305:
            glitchFreeze();
            dad.shader = glitchShader;
        case 1311:
            dad.shader = null;
        case 1330:
            glitchFreeze();
            dad.shader = glitchShader;
        case 1338:
            dad.shader = null;
        case 1426:
            glitchFreeze();
            dad.shader = glitchShader;
        case 1440:
            dad.shader = null;
            disableGhosts = false;
        case 1820:
            if (PlayState.character != null) PlayState.character.stunned = true;
                
            persistentUpdate = persistentDraw = false;
            FlxG.paused = true;
            paused = true;
            FlxG.autoPause = false;

            if (vocals != null) vocals.stop();

            for (strumLine in strumLines){
                if (strumLine.vocals != null) strumLine.vocals.stop();
            }

            if (FlxG.sound.music != null) FlxG.sound.music.stop();

            FlxG.save.data.forceSong2 = true;
            FlxG.save.flush();
            trace("force song 2");
            
            var illegins:FlxText = new FlxText(0, FlxG.height / 2 + 200, FlxG.width, "ILLEGAL   INSTRUCTION$00015925");
            illegins.setFormat(null, 32, FlxColor.WHITE, "right");
            add(illegins);
            illegins.camera = camHUD;

            var redCom:FlxSprite = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 4, FlxColor.RED);
            insert(members.indexOf(boyfriend), redCom);
            redCom.screenCenter();

            boyfriend.color = 0xFF000000;
            dad.color = 0xFF000000;

            new FlxTimer().start(2, function(_) {
                System.exit(0);
            });

            FlxG.sound.play(Paths.sound("hoggage"), 1, true);
    }
}

function destroy() {
    FlxG.game.removeShader(camFuckShader);
    FlxG.game.removeShader(staticlol);
}