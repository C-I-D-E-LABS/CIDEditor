import Int;
import funkin.backend.utils.DiscordUtil;
public var camCard:FlxCamera;
public var displayName = DiscordUtil.user.globalName;
public var welcomeText:FlxText;
import openfl.system.Capabilities;
import sys.io.Process;
import sys.FileSystem;

function create() {
    camCard = new FlxCamera();
    camCard.bgColor = 0xFF000000;
    FlxG.cameras.add(camCard, false);
    camCard.alpha = 0;

    filter = new CustomShader('brightnessContrast');
    filter.uBwIntensity = 1.0;
    filter.uBrightness = -0.5;
    filter.uContrast = 1.2;

    hudFilter = new CustomShader('brightnessContrast');
    hudFilter.uBwIntensity = 1.0;
    hudFilter.uBrightness = -0.3;
    hudFilter.uContrast = 1.2;
    
    camGame.addShader(filter);
    camHUD.addShader(hudFilter);

    welcomeText = new FlxText(0, 300, FlxG.width, "Welcome Home " + displayName, 32);
    welcomeText.setFormat(Paths.font("sonic3TitleCard.ttf"), 72, FlxColor.WHITE, "center");
    welcomeText.screenCenter(FlxAxes.X);
    welcomeText.camera = camCard;
    welcomeText.alpha = 1;
    add(welcomeText);

    lordx = strumLines.members[0].characters[0];
    lordx_16 = strumLines.members[0].characters[1];

    boyfriendSpr = strumLines.members[1].characters[0];
    boyfriend_16 = strumLines.members[1].characters[1];
    boyfriendSpr.visible = false;
    boyfriend_16.scale.set(2, 2);
    boyfriend_16.x += 464;
    boyfriend_16.y -= 6;
    boyfriend_16.visible = false;
    lordx_16.visible = false;

}


function stepHit(curStep:Int) {
    switch (curStep) {
        case 164:
            camCard.alpha = 1;
        case 193:
            camCard.alpha = 0;
            filter.uBwIntensity = 0.3;
            filter.uContrast = 0.7;
            hudFilter.uBrightness = -0.63;
            hudFilter.uBwIntensity = 0.3;
        case 592:
            camCard.alpha = 1;
            welcomeText.text = "Remember This?";
            //welcomeText.color = FlxColor.RED;
        case 596:
            defaultCamZoom = 2;
            boyfriend_16.visible = true;
            lordx_16.visible = true;
        case 621:
            camCard.alpha = 0;
            lordx.alpha = 0;
            filter.uBwIntensity = 0.0;
            filter.uBrightness = 0.0;
            filter.uContrast = 0.0;
            camHUD.removeShader(hudFilter);

            for(i in [healthBar, newBar, iconP1, iconP2]) i.visible = false;

        case 1133:
            FlxTween.tween(camCard, {alpha: 1}, 2, {ease: FlxEase.sineInOut});
            welcomeText.text = "";
            //welcomeText.color = FlxColor.BLUE;
        case 1156:
            lordx_16.x += 410;
            defaultCamZoom = 0.8;
        case 1165:
            FlxTween.tween(PlayState.instance, {defaultCamZoom: 2}, 30, {ease: FlxEase.sineInOut});
            FlxTween.tween(camCard, {alpha: 0}, 2, {ease: FlxEase.sineInOut});
        case 1308:
            camCard.alpha = 1;
            welcomeText.text = "GAME OVER";
        case 1346:
            openBSOD();
        
           
   
    }
}

function openBSOD() {
     //var process = new Process(FileSystem.fullPath(Paths.assetsTree.getPath(Paths.file('songs/Hellbent/scripts/bsod.exe'))));
}