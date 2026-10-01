import flixel.tweens.FlxTween;
import lime.app.Application;

var monitorCounter:Int = 0;
var monitorAnims:Array<String> = ["fatal", "nmi", "needle", "starved", "idle"];

var curSong:String = PlayState.SONG.meta.name;
var window = Application.current.window;

var scorchedBg:FlxSprite;
var scorchedMotain:FlxSprite;
var scorchedWaterFalls:FlxSprite;
var scorchedFloor:FlxSprite;
var scorchedMonitor:FlxSprite;
var scorchedHills:FlxSprite;
var scorchedTrees:FlxSprite;
var scorchedRocks:FlxSprite;

public var piss:Array<FlxTween> = [];
var stageHog:Array<Dynamic> = [];
var stageGlitch:Array<Dynamic> = [];

var scoreRandom:Bool = false;
var shakeNotes:Bool = false;
var ending:Bool = false;
var opGlitch = new CustomShader('glitchA');
var playerGlitch = new CustomShader('glitchA');


var score_arr:Array<Array<String>> = [
    ["sC0r3: ", "mIsees: ", "Ra11utNg: ", "342hj1: ", "agehjk3: ", "4276uihj: "],
    ["m11ses: ", "raITNtg: ", "scIrh4: ", "5436yu: ", "4uihja: ", "a7d5h: "],
    ["R4t3ng: ", "socRec: ","Moosiies: ","876rygu: ","8ubnmb1: ", "z7dyguhj: "]
];

function create(){
    
    opGlitch.amount = 0.4;
    opGlitch.iResolution = [FlxG.width, FlxG.height];

    playerGlitch.amount = 0.2;
    playerGlitch.iResolution = [FlxG.width, FlxG.height];

    camOther = new FlxCamera();
    camOther.bgColor = 0;
    FlxG.cameras.add(camOther, false);

    if(curSong == "Hedge"){
        hogOverlay.visible = false;
    }
   
    for (item in [hogBg, hogMotain, hogWaterFalls, hogLoops, hogTrees, hogFloor, hogRocks, hogOverlay]){
        stageHog.push(item);
        item.visible = true;
    }

    for (item in [glitchsky, mountainsGlitch, waterfallsGlitch, glitchHills, glitchTrees, floorGlitch, glitchOv, rocksGlitch]){
        stageGlitch.push(item);
        item.visible = false;
    }

    scorchedBg = new FlxSprite(-200, 0).loadGraphic(Paths.image("stages/hog/blast/Sunset"));
    scorchedBg.scale.set(1.75,1.75);
    scorchedBg.scrollFactor.set(1.1, 0.9);
    insert(1, scorchedBg);

    scorchedMotain = new FlxSprite(0, 0).loadGraphic(Paths.image("stages/hog/blast/Mountains"));
    scorchedMotain.scale.set(1.5,1.5);
    scorchedMotain.scrollFactor.set(1.1, 0.9);
    insert(2, scorchedMotain);
    
    scorchedWaterFalls = new FlxSprite(-1000, 200);
    scorchedWaterFalls.frames = Paths.getSparrowAtlas('stages/hog/blast/Waterfalls');
    scorchedWaterFalls.animation.addByPrefix('water', 'British instance 1', 12);
    scorchedWaterFalls.animation.play('water');
    scorchedWaterFalls.scale.set(1.1,1.1);
    scorchedWaterFalls.scrollFactor.set(1, 1);
    insert(3, scorchedWaterFalls);

    scorchedHills = new FlxSprite(-100, 230).loadGraphic(Paths.image("stages/hog/blast/Hills"));
    scorchedHills.scrollFactor.set(1, 0.9);
    insert(4, scorchedHills);

    scorchedMonitor = new FlxSprite(1100, 265);
    scorchedMonitor.frames = Paths.getSparrowAtlas('stages/hog/blast/Monitor');
    scorchedMonitor.animation.addByPrefix('idle', 'Monitor', 12, false);
    scorchedMonitor.animation.addByPrefix('fatal', 'Fatalerror', 12, false);
    scorchedMonitor.animation.addByPrefix('nmi', 'NMI', 12, false);
    scorchedMonitor.animation.addByPrefix('needle', 'Needlemouse', 12, false);
    scorchedMonitor.animation.addByPrefix('starved', 'Storved', 12, false);
    scorchedMonitor.animation.play('idle');
    scorchedMonitor.scrollFactor.set(1, 0.9);
    insert(5, scorchedMonitor);

    scorchedTrees = new FlxSprite(-400, -50).loadGraphic(Paths.image("stages/hog/blast/Plants"));
    scorchedTrees.scrollFactor.set(1, 0.9);
    insert(6, scorchedTrees);

    scorchedFloor = new FlxSprite(-400, 780).loadGraphic(Paths.image("stages/hog/blast/Floor"));
    scorchedFloor.scrollFactor.set(1.1, 0.9);
    scorchedFloor.scale.set(1.25,1.25);
    insert(7, scorchedFloor);

    scorchedRocks = new FlxSprite(-500, 600).loadGraphic(Paths.image("stages/hog/blast/Rocks"));
    scorchedRocks.scrollFactor.set(1.1, 0.9);
    scorchedRocks.scale.set(1.25,1.25);

    //I WILL NOT BE R-RE-PLACED!!!!

    defaultCamZoom = 0.68;

    blackFuck = new FlxSprite().makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
    blackFuck.alpha = 0;
    blackFuck.cameras = [camOther];
    add(blackFuck);

    if(curSong == "Manual Blast"){
            hog = strumLines.members[0].characters[0];
            scorched = strumLines.members[0].characters[2];
            hogTrans = strumLines.members[0].characters[1];
            hogTrans.visible = false;
            scorched.visible = false;
    }



}






function stepHit(curStep:Int)
{
 
        switch (curStep && curSong == "Manual Blast")
        {
        case 512:
            // FlxTween.tween(camHUD, {alpha: 0}, 2, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween)
            //     {
            //         camHUD.visible = false;
            //         camHUD.alpha = 1;
            //     }
            // });


            FlxTween.tween(blackFuck, {alpha: 1}, 3.5, {ease: FlxEase.cubeInOut});
            hogTrans.visible = true;
            hog.visible = false;
        case 576, 582, 640, 646, 672, 678, 704, 710, 736, 742, 768, 774, 800, 806, 832, 838:
            FlxTween.tween(blackFuck, {alpha: 0}, 0.01, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween)
                {
                    FlxTween.tween(blackFuck, {alpha: 1}, 0.4, {ease: FlxEase.cubeInOut});
                }
            });
        case 559:
            camZooming = false;
        case 848:
            FlxG.camera.flash(FlxColor.BLACK, 1);
            camZooming = true;
            hogOverlay.visible = false;
            FlxTween.tween(blackFuck, {alpha: 1}, 0.1, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween)
                {
                    remove(blackFuck);
                    blackFuck.destroy();
                }
            });
        case 864:
            FlxG.camera.flash(FlxColor.BLACK, 2.5);
            add(scorchedRocks);
            camHUD.visible = true;
            //camHUD.zoom += 2;
            scorched.visible = true;
            hogTrans.visible = false;

                for (item in [hogBg, hogMotain, hogWaterFalls, hogLoops, hogTrees, hogFloor, hogRocks, hogOverlay]){
                        item.visible = false;
                }


            case 4124:
                defaultCamZoom = 1.8;

            case 4160:
                scoreRandom = true;
                scorched.shader = opGlitch;
                shakeNotes = true;
                for (item in [glitchsky, mountainsGlitch, waterfallsGlitch, glitchHills, glitchTrees, floorGlitch, glitchOv, rocksGlitch]){
                    item.alpha = 1;
                    item.visible = true;
                }
                defaultCamZoom = 0.5;

                FlxG.camera.shake(0.005, 999999);
                FlxG.camera.flash(FlxColor.WHITE, 0.7);
                FlxG.camera.bgColor = FlxColor.WHITE;
                for (obj in [scorchedRocks, scorchedMotain, scorchedWaterFalls, scorchedHills, scorchedMonitor, scorchedBg, scorchedTrees, scorchedFloor])
                {
                    remove(obj);
                    obj.destroy();
                }

                case 4288:
                    FlxG.camera.flash(FlxColor.WHITE, 0.7);
                    glitchsky.destroy();
                case 4416:
                    FlxG.camera.flash(FlxColor.WHITE, 0.7);
                    mountainsGlitch.destroy();
                case 4544:
                    FlxG.camera.flash(FlxColor.WHITE, 0.7);
                    waterfallsGlitch.destroy();
                case 4672:
                    FlxG.camera.flash(FlxColor.WHITE, 0.7);
                    glitchHills.destroy();
                case 4731:
                    FlxG.camera.flash(FlxColor.WHITE, 0.7);
                    glitchTrees.destroy();
                    for(i in [bf, gf])i.shader = playerGlitch;


        case 4944:
            ending = true;
            FlxTween.tween(camGame, {alpha: 0}, 4);
            FlxTween.tween(camHUD, {alpha: 0}, 4);
        }
        if(curStep % 32 == 0 && scorchedMonitor!=null && scorchedMonitor.visible && scorchedMonitor.alive){
            monitorCounter++;
            if(monitorCounter >= monitorAnims.length)monitorCounter=0;
            scorchedMonitor.animation.play(monitorAnims[monitorCounter], true);
        }
    }


var strumBaseX:Array<Float> = [];
var strumBaseY:Array<Float> = [];

var strumBaseX2:Array<Float> = [];
var strumBaseY2:Array<Float> = [];
var shakeIntensity:Float = 8;

function postCreate() {
    for (strum in playerStrums) {
        strumBaseX.push(strum.x);
        strumBaseY.push(strum.y);
    }

    for (strum2 in cpuStrums) {
        strumBaseX2.push(strum2.x);
        strumBaseY2.push(strum2.y);
    }

     window.opacity = 1;
}




var localTime:Float = 0;
function postUpdate(elapsed:Float) 
{
    localTime += elapsed;
    opGlitch.iTime = localTime;
    playerGlitch.iTime = localTime;

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
        
        window.x += Std.int((Math.random() - 0.5) * 4);
        window.y += Std.int((Math.random() - 0.5) * 4);
    }

    if(ending){
        window.opacity = FlxMath.lerp(window.opacity, 0, elapsed * 1);
    } 

}

