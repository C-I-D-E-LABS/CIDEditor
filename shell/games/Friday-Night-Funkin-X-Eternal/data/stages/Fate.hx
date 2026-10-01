// Lord X Hill

import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxAxes;
import openfl.system.Capabilities;
import sys.io.Process;
import sys.FileSystem;

var cloudsX:FlxBackdrop;
var cloudsX2:FlxBackdrop;
var opGlitch = new CustomShader('glitchA');

var scoreRandom:Bool = false;
var shakeNotes:Bool = false;
var score_arr:Array<Array<String>> = [
    ["sC0r3: ", "mIsees: ", "Ra11utNg: ", "342hj1: ", "agehjk3: ", "4276uihj: "],
    ["m11ses: ", "raITNtg: ", "scIrh4: ", "5436yu: ", "4uihja: ", "a7d5h: "],
    ["R4t3ng: ", "socRec: ","Moosiies: ","876rygu: ","8ubnmb1: ", "z7dyguhj: "]
];

var strumBaseX:Array<Float> = [];
var strumBaseY:Array<Float> = [];

var strumBaseX2:Array<Float> = [];
var strumBaseY2:Array<Float> = [];
var shakeIntensity:Float = 8;

function create() {
	//defaultCamZoom = 1.2;

	opGlitch.amount = 0.4;
    opGlitch.iResolution = [FlxG.width, FlxG.height];

	camEvt = new FlxCamera();
	camEvt.bgColor = new FlxColor(0x00000000);
	FlxG.cameras.add(camEvt, false);
	camEvt.visible = false;

	goneTxt = new FlxSprite(360, 250).loadGraphic(Paths.image('exe/fate/goneTxt'));
	add(goneTxt);
	goneTxt.cameras = [camEvt];

	dad.x += 300;
	dad.y += 350;

	boyfriend.x += 700;
	boyfriend.y += 270;
	boyfriend.cameraOffset.x -= 50;

	cloudsX = new FlxBackdrop(Paths.image("exe/lordx/Clouds"), FlxAxes.X);
	cloudsX.setPosition(130, -450);
	cloudsX.scale.set(0.5, 0.5);
	cloudsX.scrollFactor.set(0.7, 0.7);
	cloudsX.velocity.x = -20;
	cloudsX.antialiasing = true;
	insert(members.indexOf(hillsX), cloudsX);

	cloudsX2 = new FlxBackdrop(Paths.image("exe/lordx/Clouds"), FlxAxes.X);
	cloudsX2.setPosition(130, -360);
	cloudsX2.scale.set(0.5, 0.5);
	cloudsX2.scrollFactor.set(0.75, 0.75);
	cloudsX2.velocity.x = -50;
	cloudsX2.alpha = 0.55;
	cloudsX2.antialiasing = true;
	insert(members.indexOf(groundX), cloudsX2);

	for(i in [fatePillars, fateFloor, fateSky, fateFG])i.visible = false;
}

function stepHit(curStep:Int) {
	switch(curStep){
		
		case 800:
			camHUD.visible = false;
			camGame.visible = false;
			bf.cameraOffset.y -= 30;
		case 892:
			for(i in [cloudsX2, cloudsX, hillsX, hillsX2, skyX, groundX, plantsX2]) i.visible = false;
			for(i in [fatePillars, fateFloor, fateSky, fateFG, camHUD, camGame])i.visible = true;

		case 2288:
			//camHUD.visible = false;
			camGame.visible = false;
		case 2316:
			camGame.visible = true;
		case 3224:
			scoreRandom = true;
			dad.shader = opGlitch;
			shakeNotes = true;
			camHUD.flash(FlxColor.WHITE, 0.7);
		case 3313:
			for(i in [fatePillars, dad])i.shader = opGlitch;
			opGlitch.amount = 0.6;
		case 3353:
			for(i in [fatePillars, fateFloor, dad])i.shader = opGlitch;
			opGlitch.amount = 0.8;
		case 3427:
			camHUD.visible = false;
			camGame.visible = false;
			camEvt.visible = true;

	}
}

function postCreate() {
	for (strum in playerStrums) {
        strumBaseX.push(strum.x);
        strumBaseY.push(strum.y);
    }

    for (strum2 in cpuStrums) {
        strumBaseX2.push(strum2.x);
        strumBaseY2.push(strum2.y);
    }
}
var localTime:Float = 0;
function postUpdate(elapsed:Float) 
{
    localTime += elapsed;
    opGlitch.iTime = localTime;

    if(scoreRandom){
        var randInt:Int = FlxG.random.int(0, score_arr[0].length);

        if (scoreTxt != null) scoreTxt.text = score_arr[0][randInt] + songScore;
        
        if (missesTxt != null) missesTxt.text = score_arr[1][randInt] + misses;

        if (accuracyTxt != null) accuracyTxt.text = score_arr[2][randInt] + (accuracy < 0 ? "-%" : CoolUtil.quantize(accuracy * 100, 100)) + " - " + curRating.rating; 
    }

    if(shakeNotes){
        for (i in 0...playerStrums.length) {
            var strum = playerStrums.members[i];
            strum.x = strumBaseX[i] + (Math.random() - 0.5) * shakeIntensity;
            strum.y = strumBaseY[i] + (Math.random() - 0.5) * shakeIntensity;
        }
        
        for (i in 0...cpuStrums.length) {
            var strum2 = cpuStrums.members[i];
            strum2.x = strumBaseX2[i] + (Math.random() - 0.5) * shakeIntensity;
            strum2.y = strumBaseY2[i] + (Math.random() - 0.5) * shakeIntensity;
        }
        
        // window.x += Std.int((Math.random() - 0.5) * 4);
        // window.y += Std.int((Math.random() - 0.5) * 4);
    }


}
