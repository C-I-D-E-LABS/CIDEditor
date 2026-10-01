
import flixel.text.FlxTextBorderStyle;

var lordWords:FunkinText;
var txtBG:FunkinSprite;

function postCreate() {
    lordWords = new FunkinText(0,70,FlxG.width,"",28);
    lordWords.setFormat(Paths.font('sonic-cd-menu-font.ttf'), lordWords.size, FlxColor.WHITE, 'center', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    lordWords.camera = camHUD;
    lordWords.screenCenter(FlxAxes.X).x -= FlxG.width * 0.25;
    insert(0,lordWords);

    txtBG = new FunkinSprite((FlxG.width * 0.25) - (lordWords.width/2)).makeSolid((40 * lordWords.text.length),lordWords.height,FlxColor.BLACK);
    txtBG.camera = camHUD;
    txtBG.screenCenter(FlxAxes.X).x -= FlxG.width * 0.25;
    txtBG.y = lordWords.y - 5;
    insert(members.indexOf(lordWords),txtBG).alpha = 0.4;
}

function updateTxt(txt:String,?clear:Bool):String {
    
    if (clear) lordWords.text = "";
    
    lordWords.text += txt;
    txtBG.scale.x = (32 * lordWords.text.length);
    return txt;
}

function onEvent(_) {
    if (_.event.name == 'normalSub') {
        updateTxt(_.event.params[0],_.event.params[1]);
    }
}
