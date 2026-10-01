//THE MAIN UI FOR THE BUILD EVERYTHING IN HERE IS OPTIMISED TO BE USED IN ALL SONGS!!!
import flixel.text.FlxTextBorderStyle;
var windowTitle:String = "Friday Night Funkin': X-Eternal - ";
public var newBar:FlxSprite;
public var songName:String = PlayState.SONG.meta.name;
var smoothHealth:Float = 1;
var xenoHud:FlxSprite;

function create() {
    introLength = 0; // Removes the 3, 2, 1, GO! sound that was annoying asf

    if (songName == "Triple Trouble")
        graphicCache.cache(Paths.image("game/sonicUI/triple/xenoHud"));
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

    if (songName == "Triple Trouble") {
        xenoHud = new FlxSprite().loadGraphic(Paths.image("game/sonicUI/triple/xenoHud"));
        xenoHud.camera = camHUD;
        xenoHud.scrollFactor.set();
        xenoHud.alpha = 0.7;
        xenoHud.visible = false;
        insert(0, xenoHud);
    }

    switch(songName){
        
        // case"Endless US":
        //     healthBar.alpha = 0;
        //     newBar.alpha = 0;
        //     iconP1.alpha = 0;
        //     iconP2.alpha = 0;
        //     accuracyTxt.alpha = 0;
        //     missesTxt.alpha = 0;
        //     scoreTxt.alpha = 0;

        case"Milk", "Personel", "ILLEGAL INSTRUCTION":
            healthBar.alpha = 0;
            newBar.alpha = 0;
            iconP1.alpha = 0;
            iconP2.alpha = 0;

            scoreTxt.x -= 220; 
            missesTxt.x -= 220; 
            accuracyTxt.x -= 220;
            missesTxt.y -= 40;
            scoreTxt.y -= 80;
        case"Triple Trouble":
            for (item in [newBar, iconP1, iconP2, healthBar, healthBarBG])
                item.x += 220;

            scoreTxt.x -= 360; 
            missesTxt.x -= 360; 
            accuracyTxt.x -= 360;
            scoreTxt.y -= 40;
            missesTxt.y -= 20;
        default:
            scoreTxt.x -= 360; 
            missesTxt.x -= 360; 
            accuracyTxt.x -= 360;
            scoreTxt.y -= 40;
            missesTxt.y -= 20;
           
           
    }
    
    newBar.y += 60; 
    healthBarBG.alpha = 0;
    healthBar.scale.set(1.1, 1.1);
    healthBar.numDivisions = 1000;
    smoothHealth = health;

        for (i in [scoreTxt, accuracyTxt, missesTxt]) {
            i.setFormat(Paths.font("PhantomMuff.ttf"), 22, FlxColor.WHITE, "left", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            i.borderSize = 1;
            //i.x += 380; // undo the offset
        }

    
    for (item in [iconP1,iconP2,healthBar,healthBarBG]){item.y -= 17;}

     switch(songName){
        
        case"Endless", "Endless US", "Endless JP", "Endeavors":
            for (item in [iconP1,iconP2]){item.flipX = true;}
     }

}

function postUpdate(elapsed:Float) {
    smoothHealth = FlxMath.lerp(smoothHealth, health, Math.min(1, elapsed * 12));
    if (Math.abs(smoothHealth - health) < 0.001) smoothHealth = health;
    healthBar.value = smoothHealth;
    updateIconPositions();

    PlayState.instance.comboGroup.cameras = [camHUD];
    insert(3, PlayState.instance.comboGroup);
    comboGroup.x = 1080;
    comboGroup.y = 580;

    switch(songName) {
        case"Milk", "Personel", "ILLEGAL INSTRUCTION":
            comboGroup.x = 880;
            comboGroup.y = 580;
    }

    if (scoreTxt.text.indexOf("Score: ") == -1) scoreTxt.text = StringTools.replace(scoreTxt.text, "Score:", "Score: ");
    if (missesTxt.text.indexOf("Combo Breaks: ") == -1) missesTxt.text = StringTools.replace(missesTxt.text, "Combo Breaks:", "Combo Breaks: ");
    if (missesTxt.text.indexOf("Misses: ") == -1) missesTxt.text = StringTools.replace(missesTxt.text, "Misses:", "Misses: ");
    if (accuracyTxt.text.indexOf("Accuracy: ") == -1) accuracyTxt.text = StringTools.replace(accuracyTxt.text, "Accuracy:", "Accuracy: ");

    accuracyTxt.removeFormat(accFormat);
    var rankStart = accuracyTxt.text.lastIndexOf(" - ");
    if (rankStart >= 0) accuracyTxt.addFormat(accFormat, rankStart + 3, accuracyTxt.text.length);
}

function stepHit(curStep:Int) {
    if (songName == "Triple Trouble" && xenoHud != null)
        switch(curStep) {
            case 1040, 2320, 4112:
                xenoHud.visible = true;
            case 1296, 2832, 5168:
                xenoHud.visible = false;
        }
}

function onPlayerMiss(e) {
    switch(songName){
        
        case"Endless", "Endless US", "Endless JP", "Endeavors":
            e.healthGain = 0;
    }
}

function onPlayerHit(e) {
    switch(songName){
        
        case"Endless", "Endless US", "Endless JP", "Endeavors":
            e.healthGain = 0;
    }
}
