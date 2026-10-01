import funkin.backend.scripting.events.DrawEvent;
//THE MAIN PixelUI FOR THE BUILD EVERYTHING IN HERE IS OPTIMISED TO BE USED IN ALL PIXEL SONGS!!!
import flixel.text.FlxTextFormat;
import flixel.text.FlxTextAlign;
import flixel.text.FlxTextBorderStyle;

var songName:String = PlayState.SONG.meta.name;

var windowTitle:String = "Friday Night Funkin': X-Eternal - ";
var smoothHealth:Float = 1;

function create() {
    introLength = 0; // Removes the 3, 2, 1, GO! sound that was annoying asf
    for (asset in ['sick', 'good', 'bad', 'shit', 'num0', 'num1', 'num2', 'num3', 'num4', 'num5', 'num6', 'num7', 'num8', 'num9'])
        graphicCache.cache(Paths.image('game/pixelUI/' + asset));
}

function postCreate() {
    
    window.title = windowTitle + PlayState.SONG.meta.name; // Song name displayed in the app window

    newBar = new FlxSprite(0,551);
    newBar.loadGraphic(Paths.image("exeternalHealthBar"));
    newBar.camera = camHUD;
    newBar.scale.set(1,1);
    newBar.updateHitbox();
    newBar.antialiasing = false;
    newBar.screenCenter(FlxAxes.X);
    insert(members.indexOf(iconP1),newBar);
    
    newBar.y += 60; 
    healthBarBG.alpha = 0;
    healthBar.scale.set(1.1, 1.1);
    healthBar.numDivisions = 1000;
    smoothHealth = health;
    for (item in [newBar, iconP1, iconP2, healthBar, healthBarBG]) item.x += 220;
    for (item in [iconP1,iconP2,healthBar,healthBarBG]){item.y -= 17;}

    iconP2.antialiasing = false;
    iconP1.antialiasing = false;


    scoreTxt.setFormat(Paths.font("sonic1HUD.ttf"), 48, FlxColor.WHITE, "left", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    accuracyTxt.setFormat(Paths.font("sonic1HUD.ttf"), 48, FlxColor.WHITE, "left", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    missesTxt.setFormat(Paths.font("sonic1HUD.ttf"), 48, FlxColor.WHITE, "left", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

    for(i in [scoreTxt, accuracyTxt, missesTxt]){
        i.x -= 380; 
       
    }
   
    scoreTxt.y -= 650; 
    missesTxt.y -= 600; 
    accuracyTxt.y -= 550; 

    if(songName == "Prey"){
        scoreTxt.x += 180; 
        missesTxt.x += 180; 
        accuracyTxt.x += 180; 
        healthBar.x -= 180;
        newBar.x -= 180;
    }
    
}

function postUpdate(elapsed:Float) {

    if (scoreTxt.text.indexOf("Score: ") == -1) scoreTxt.text = StringTools.replace(scoreTxt.text, "Score:", "SCORE: ");
    if (missesTxt.text.indexOf("Combo Breaks: ") == -1) missesTxt.text = StringTools.replace(missesTxt.text, "Combo Breaks:", "MISSES: ");
    if (missesTxt.text.indexOf("Misses: ") == -1) missesTxt.text = StringTools.replace(missesTxt.text, "Misses:", "Misses: ");
    if (accuracyTxt.text.indexOf("Accuracy: ") == -1) accuracyTxt.text = StringTools.replace(accuracyTxt.text, "Accuracy:", "ACCURACY: ");

    accuracyTxt.removeFormat(accFormat);
    var rankStart = accuracyTxt.text.lastIndexOf(" - ");
    if (rankStart >= 0) accuracyTxt.addFormat(accFormat, rankStart + 3, accuracyTxt.text.length);


    smoothHealth = FlxMath.lerp(smoothHealth, health, Math.min(1, elapsed * 12));
    if (Math.abs(smoothHealth - health) < 0.001) smoothHealth = health;
    healthBar.value = smoothHealth;
    updateIconPositions();

    PlayState.instance.comboGroup.cameras = [camHUD];
    insert(3,PlayState.instance.comboGroup);
    comboGroup.x = 1080;
    comboGroup.y = 580;
    
    var yellowLabel = new FlxTextFormat(FlxColor.YELLOW);

    scoreTxt.clearFormats();
    scoreTxt.addFormat(yellowLabel, 0, scoreTxt.text.indexOf(":") + 1);
    
    missesTxt.clearFormats();
    missesTxt.addFormat(yellowLabel, 0, missesTxt.text.indexOf(":") + 1);
    
    accuracyTxt.clearFormats();
    accuracyTxt.addFormat(yellowLabel, 0, accuracyTxt.text.indexOf(":") + 1);
}

function onPlayerHit(event) {
    event.ratingPrefix = "game/pixelUI/";
    event.ratingScale = 4.2;
    event.ratingAntialiasing = false;
    event.numScale = 4.2;
    event.numAntialiasing = false;
}
