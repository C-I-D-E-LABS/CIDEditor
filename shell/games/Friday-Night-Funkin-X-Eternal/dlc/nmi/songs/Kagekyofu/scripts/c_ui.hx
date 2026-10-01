//THE MAIN UI FOR THE BUILD EVERYTHING IN HERE IS OPTIMISED TO BE USED IN ALL SONGS!!!
import flixel.text.FlxTextBorderStyle;
var windowTitle:String = "Friday Night Funkin': X-Eternal - ";
public var newBar:FlxSprite;
public var songName:String = PlayState.SONG.meta.name;

function create() {
    introLength = 0; // Removes the 3, 2, 1, GO! sound that was annoying asf
}

function postCreate() {
    
    window.title = windowTitle + PlayState.SONG.meta.name; // Song name displayed in the app window

    playerName = new FlxText(150,650);
    playerName.text = "Yoru"; 
    add(playerName);
    playerName.camera = camHUD;
    playerName.setFormat(Paths.font("onryou.ttf"), 30, FlxColor.WHITE, FlxTextBorderStyle.OUTLINE, 15, FlxColor.BLACK);

    scoreTxt.x -= 360; 
    missesTxt.x -= 360; 
    accuracyTxt.x -= 360;
    accuracyTxt.y -= 540;
    missesTxt.y -= 580;
    scoreTxt.y -= 620;
   

    scoreTxt.setFormat(Paths.font("onryou.ttf"), 30, FlxColor.WHITE, FlxTextBorderStyle.OUTLINE, 15, FlxColor.BLACK);
    accuracyTxt.setFormat(Paths.font("onryou.ttf"), 30, FlxColor.WHITE, FlxTextBorderStyle.OUTLINE, 15, FlxColor.BLACK);
    missesTxt.setFormat(Paths.font("onryou.ttf"), 30, FlxColor.WHITE, FlxTextBorderStyle.OUTLINE, 15, FlxColor.BLACK);


    updateRatingStuff = () -> {

        scoreTxt.text = "スコア: " + songScore;
        missesTxt.text = "ミス: " + misses;

        if (curRating == null)
            curRating = new ComboRating(0, "[N/A]", 0xFF888888);

        @:privateAccess {
            accFormat.format.color = curRating.color;
            accuracyTxt.text = "精度: " + (accuracy < 0 ? "-%" : CoolUtil.quantize(accuracy * 100, 100) + "%") + " " + curRating.rating;

            for (i => frmtRange in accuracyTxt._formatRanges) if (frmtRange.format == accFormat) {
                accuracyTxt._formatRanges[i].range.start = accuracyTxt.text.length - curRating.rating.length;
                accuracyTxt._formatRanges[i].range.end = accuracyTxt.text.length;
                break;
            }
        }
    };
}

function postUpdate(elapsed:Float) {
    doIconBop = false;
    PlayState.instance.comboGroup.cameras = [camHUD];
    insert(3,PlayState.instance.comboGroup);
    comboGroup.x = 480;
    comboGroup.y = 80;
    
    healthBar.visible = false;
    healthBarBG.visible = false;
    iconP2.visible = false;

    iconP1.x = 0;
    iconP1.y = 550;
    iconP1.flipX= false;

}

function onPlayerHit(event:NoteHitEvent) {
	event.ratingScale = 0;
	event.numScale = 0;
}

