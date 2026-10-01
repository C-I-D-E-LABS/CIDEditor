import flixel.text.FlxTextBorderStyle;
import flixel.addons.display.shapes.FlxShapeDonut;
import flixel.addons.display.shapes.FlxShapeCircle;

var grpClouds:FlxTypedGroup;
var lordP2:Dynamic;
var lordP1:Dynamic;
var lordMsg:String = "…Little warrior… your voice… it reached me.\nI wore this vessel… this shell of flesh and fury… \n for so long I forgot what silence felt like.\nBut you… your rhythm, your will… you reminded me.\nYou fought me without hatred. You stood firm without fear.\n\nAnd for the first time in eons… I am not alone.\nThis vessel is gone… and I must return to the deep beyond…\nBut hear me, singer of blue hair…\nYour song… set me free.\n\nThank you… Boyfriend.\n\nThis is the End\n";
var camEvents:FlxCamera;

function create() {
    camEvents = new FlxCamera();
    camEvents.bgColor = new FlxColor(0x00000000);
    FlxG.cameras.add(camEvents, false);

    lordP1 = strumLines.members[0].characters[0];
    lordP2 = strumLines.members[0].characters[1];
    lordP2.visible = false;

    create_msg();
}

function create_msg() {
    solidWhite = new FunkinSprite().makeSolid(FlxG.width*2,FlxG.height*2,0xFFFEFEFE);
    solidWhite.scrollFactor.set();
    solidWhite.screenCenter();
    add(solidWhite).alpha = 0;

    talk = new FunkinText(0,0,null,lordMsg,16);
    talk.camera = camEvents;
    talk.setFormat(null, talk.size, FlxColor.BLACK, 'center', FlxTextBorderStyle.OUTLINE, FlxColor.WHITE);
    talk.screenCenter();
    add(talk).alpha = 0;
}

var grpCoolTxt:FlxTypedGroup;
var bgTwn:FlxTween;

var eyeArr = [];
function stepHit(curStep:Int) {
    switch(curStep){
        case 704:
            dad.cameraOffset.x -= 200;
        case 1344:
            FlxTween.tween(solidWhite, {alpha: 1}, t_steps(6));
            // solidWhite.visible = false; 

        case 1508:
            solidWhite.color = FlxColor.BLACK;
            camHUD.alpha = 0;

        case 1532:
            bgTwn = FlxTween.color(solidWhite, t_steps(8), 0xFF000000, 0xFFFFFFFF);
        case 1540:
            if (bgTwn != null) bgTwn.cancel();

            FlxG.cameras.flash(FlxColor.WHITE, t_steps(4));
            solidWhite.alpha = 0;
            // camHUD.alpha = 1;
            lordP1.visible = false;
            lordP2.visible = true;
            checkCharacter(0);

        case 1600:
            FlxTween.tween(camHUD, {alpha: 1}, t_steps(4));

            for (itm in [iconP1,iconP2,scoreTxt,accuracyTxt,missesTxt,healthBar,healthBarBG]) itm.visible = false;

        case 1668:
            dad.cameraOffset.x += 200;

            lordP2.xml.set("camx",150);
            lordP2.xml.set("camy",150);

        case 1916:
            FlxTween.tween(solidWhite, {alpha: 1}, t_steps(6));
            FlxTween.tween(camHUD, {alpha: 0}, t_steps(6));
            // solidWhite.alpha = 0;
        case 1956:
            FlxTween.tween(talk, {alpha: 1}, t_steps(6), {ease: FlxEase.sineInOut});
        case 2148:
            FlxTween.tween(talk, {alpha: 0}, t_steps(8), {ease: FlxEase.sineInOut});

        case 1668: //new lyrics

        case 1788: //cam 360 expoOut
            FlxTween.tween(camGame,{angle: 180}, t_steps(8),{ease: FlxEase.expoIn, onComplete: () -> {camGame.angle = 0;}});

        case 1796: //blackout
            camHUD.alpha = 0;
            solidWhite.visible = true;
            solidWhite.alpha = 1;
            solidWhite.color = 0xFFFFFFFF;
            bgTwn = FlxTween.color(solidWhite, t_steps(8),0xFFFFFFFF,  0xFF000000);

        case 1800: //black lyrics that angle change
            grpCoolTxt = new FlxTypedGroup();
            grpCoolTxt.camera = camSubs;
            add(grpCoolTxt);
            lowerWaterFx();

            var lyxP1 = new FunkinText(0,0,FlxG.width,"I",512);
            lyxP1.setFormat(Paths.font('menuFont.ttf'), lyxP1.size, FlxColor.WHITE, 'center', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            lyxP1.screenCenter();
            grpCoolTxt.add(lyxP1);

            FlxTween.tween(lyxP1,{angle: -90,x: lyxP1.x + 100}, t_steps(1),{startDelay: t_steps(1),ease: FlxEase.expoInOut});
            FlxTween.tween(camSubs,{zoom: 3}, t_steps(1),{startDelay: t_steps(1),ease: FlxEase.expoInOut});

            // camSubs.scroll.x

        case 1802: //tore
            var lyx = new FunkinText(0,0,FlxG.width,"TORE",32);
            lyx.setFormat(Paths.font('menuFont.ttf'), lyx.size, FlxColor.WHITE, 'center', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            lyx.setPosition(-50,300);
            grpCoolTxt.add(lyx);

        case 1804: // of 
            var lyx = new FunkinText(0,0,FlxG.width,"OFF",32);
            lyx.setFormat(Paths.font('menuFont.ttf'), lyx.size, FlxColor.WHITE, 'center', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            lyx.setPosition(30,300);
            grpCoolTxt.add(lyx);

        case 1806: //my
            var lyx = new FunkinText(0,0,FlxG.width,"MY",32);
            lyx.setFormat(Paths.font('menuFont.ttf'), lyx.size, FlxColor.WHITE, 'center', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            lyx.setPosition(100,300);
            grpCoolTxt.add(lyx);

        case 1808: //face red
            var lyx = new FunkinText(0,0,FlxG.width,"FACE",100);
            lyx.setFormat(Paths.font('menuFont.ttf'), lyx.size, FlxColor.RED, 'center', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            lyx.setPosition(50,410);
            grpCoolTxt.add(lyx);

        case 1814: //clear
            clearResetFinale();

        case 1816:
            var lyx = new FunkinText(0,0,null,"BACK",2048);
            lyx.setFormat(Paths.font('menuFont.ttf'), lyx.size, FlxColor.RED, 'center', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            lyx.autoSize = true;
            lyx.screenCenter();
            grpCoolTxt.add(lyx);
            lyx.scale.set(4,4);
            lyx.x -= 1700;
            lyx.y += 400;
            // FlxTween.tween(lyx,{x: lyx.x + 1700 /*, y: lyx.y - 100 , "scale.x": 0.2,"scale.y": 0.2*/}, t_steps(2),{startDelay: t_steps(8),ease: FlxEase.expoOut});
            FlxTween.tween(camSubs,{zoom: 0.06}, t_steps(1),{startDelay: t_steps(8),ease: FlxEase.expoOut});
            // camSubs.zoom = 2;

            var lyx2 = new FunkinText(0,0,null,"I",512);
            lyx2.setFormat(Paths.font('menuFont.ttf'), lyx2.size, FlxColor.WHITE, 'center', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            lyx2.autoSize = true;
            lyx2.screenCenter();
            grpCoolTxt.add(lyx2);

        case 1818:
            var lyx = new FunkinText(grpCoolTxt.members[1].x + 200,grpCoolTxt.members[1].y,null,"DONT",512);
            lyx.setFormat(Paths.font('menuFont.ttf'), lyx.size, FlxColor.WHITE, 'center', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            lyx.autoSize = true;
            grpCoolTxt.add(lyx);

            FlxTween.tween(grpCoolTxt.members[1],{x: grpCoolTxt.members[1].x - 600}, t_steps(1),{ease: FlxEase.expoOut});
            FlxTween.tween(grpCoolTxt.members[2],{x: grpCoolTxt.members[2].x - 600}, t_steps(1),{ease: FlxEase.expoOut});
            
        case 1820:

            var lyx = new FunkinText(grpCoolTxt.members[1].x + 60,grpCoolTxt.members[1].y + 400,null,"WANT",512);
            lyx.setFormat(Paths.font('menuFont.ttf'), lyx.size, FlxColor.WHITE, 'center', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            lyx.autoSize = true;
            grpCoolTxt.add(lyx);

            for (i in 1...4) FlxTween.tween(grpCoolTxt.members[i],{y: grpCoolTxt.members[i].y - 300}, t_steps(1),{ease: FlxEase.expoOut});

        case 1822:
            var lyx = new FunkinText(grpCoolTxt.members[3].x + 370,grpCoolTxt.members[3].y + 400,null,"IT",512);
            lyx.setFormat(Paths.font('menuFont.ttf'), lyx.size, FlxColor.WHITE, 'center', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            lyx.autoSize = true;
            grpCoolTxt.add(lyx);

            for (i in 1...5) FlxTween.tween(grpCoolTxt.members[i],{y: grpCoolTxt.members[i].y - 300}, t_steps(1),{ease: FlxEase.expoOut});

        case 1830:
            clearResetFinale();

        case 1832: //make lord X eye

            var eyeBG:FlxShapeCircle = new FlxShapeCircle(0,0,200,{thickness: 0.25, color: 0, pixelHinting: true},FlxColor.WHITE);
            add(eyeBG);
            eyeArr.push(eyeBG);
            
            var eyeBase:FlxShapeDonut = new FlxShapeDonut(0,0,200,150,{thickness: 0.25, color: 0, pixelHinting: true},FlxColor.RED);
            add(eyeBase);
            eyeArr.push(eyeBase);

            var eyeX:FunkinSprite = new FunkinSprite(0,0).makeSolid(50,FlxG.height * 0.75,FlxColor.BLACK);
            add(eyeX).angle = 45;
            eyeArr.push(eyeX);

            var eyeX2:FunkinSprite = new FunkinSprite(0,0).makeSolid(50,FlxG.height * 0.75,FlxColor.BLACK);
            add(eyeX2).angle = -45;
            eyeArr.push(eyeX2);

            var eyeFG:FlxShapeCircle = new FlxShapeCircle(0,0,210,{thickness: 0.25, color: 0, pixelHinting: true},FlxColor.BLACK);
            add(eyeFG);

            eyeArr.push(eyeFG);

            for (all in eyeArr){
                all.camera = camSubs;
                all.screenCenter();
                // all.visible = false;
            }

            //text

            var lyx = new FunkinText(0,0,null,"DO",256);
            lyx.setFormat(Paths.font('menuFont.ttf'), lyx.size, FlxColor.WHITE, 'center', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            lyx.autoSize = true;
            grpCoolTxt.add(lyx);

        case 1834: //not
            var lyx = new FunkinText(0,0,null,"NOT",256);
            lyx.setFormat(Paths.font('menuFont.ttf'), lyx.size, FlxColor.WHITE, 'center', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            lyx.autoSize = true;
            lyx.x = FlxG.width - lyx.width;
            grpCoolTxt.add(lyx);

        case 1836: //let
            var lyx = new FunkinText(0,0,null,"LET",256);
            lyx.setFormat(Paths.font('menuFont.ttf'), lyx.size, FlxColor.WHITE, 'center', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            lyx.autoSize = true;
            lyx.y = FlxG.height - lyx.height;
            grpCoolTxt.add(lyx);

        case 1838: // me
            var lyx = new FunkinText(0,0,null,"ME",256);
            lyx.setFormat(Paths.font('menuFont.ttf'), lyx.size, FlxColor.WHITE, 'center', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            lyx.autoSize = true;
            lyx.y = FlxG.height - lyx.height;
            lyx.x = FlxG.width - lyx.width;
            grpCoolTxt.add(lyx);

        case 1840: //see it are under the eye lid
            FlxTween.tween(eyeArr[4],{y: eyeArr[4].y - 400}, t_steps(4), {ease: FlxEase.expoIn});

            var lyx = new FunkinText(0,0,null,"SEE         IT ",32);
            lyx.setFormat(Paths.font('menuFont.ttf'), lyx.size, FlxColor.BLACK, 'center', FlxTextBorderStyle.OUTLINE, FlxColor.WHITE);
            lyx.autoSize = true;
            lyx.camera = camSubs;
            lyx.screenCenter();
            add(lyx);

            FlxTween.tween(lyx,{alpha: 0}, t_steps(2), {startDelay: t_steps(4),ease: FlxEase.expoIn, onComplete: () -> {
                remove(lyx,false);
                lyx.destroy();
            }});
        
        case 1844://clear

            fakeCover = new FunkinSprite().makeSolid(FlxG.width,FlxG.height,FlxColor.BLACK);
            fakeCover.camera = camSubs;
            add(fakeCover).alpha = 0;

            FlxTween.tween(fakeCover,{alpha: 1}, t_steps(2), {ease: FlxEase.expoIn});

            for (item in eyeArr){
                remove(item,false);
                item.destroy();
            }

            clearResetFinale();

        case 1846:
            fakeCover.visible = false;

        case 1848: //IT
            var lyx = new FunkinText(0,0,null,"IT",256);
            lyx.setFormat(Paths.font('menuFont.ttf'), lyx.size, FlxColor.WHITE, 'center', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            lyx.autoSize = true;
            grpCoolTxt.add(lyx);

            FlxTween.tween(lyx,{alpha: 0},t_steps(4),{ease: FlxEase.expoIn});

        case 1850: //WILL
            var lyx = new FunkinText(0,grpCoolTxt.members[0].y + grpCoolTxt.members[0].height,null,"WILL",128);
            lyx.setFormat(Paths.font('menuFont.ttf'), lyx.size, FlxColor.WHITE, 'center', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            lyx.autoSize = true;
            grpCoolTxt.add(lyx);
            FlxTween.tween(lyx,{alpha: 0},t_steps(4),{ease: FlxEase.expoIn});

        case 1852: //fade
            var lyx = new FunkinText(0,grpCoolTxt.members[1].y + grpCoolTxt.members[1].height,null,"FADE",128);
            lyx.setFormat(Paths.font('menuFont.ttf'), lyx.size, FlxColor.WHITE, 'center', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            lyx.autoSize = true;
            grpCoolTxt.add(lyx);
            FlxTween.tween(lyx,{alpha: 0},t_steps(4),{ease: FlxEase.expoIn});

        case 1854: //to
            var lyx = new FunkinText(0,grpCoolTxt.members[2].y + grpCoolTxt.members[2].height,null,"TO",128);
            lyx.setFormat(Paths.font('menuFont.ttf'), lyx.size, FlxColor.WHITE, 'center', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            lyx.autoSize = true;
            grpCoolTxt.add(lyx);
            FlxTween.tween(lyx,{alpha: 0},t_steps(4),{ease: FlxEase.expoIn});

        case 1856: //black
            var lyx = new FunkinText(0,grpCoolTxt.members[3].y + grpCoolTxt.members[3].height,null,"BLACK",256);
            lyx.setFormat(Paths.font('menuFont.ttf'), lyx.size, FlxColor.BLACK, 'center', FlxTextBorderStyle.OUTLINE, FlxColor.RED);
            lyx.autoSize = true;
            grpCoolTxt.add(lyx);

            FlxTween.tween(lyx,{alpha: 0},t_steps(16),{startDelay: t_steps(16),ease: FlxEase.expoIn});
            FlxTween.tween(lyx,{x: lyx.x + 200,"scale.x": 4,"scale.y": 4},t_steps(32),{startDelay: t_steps(16),ease: FlxEase.expoIn});

            FlxTween.tween(camHUD,{alpha: 1}, t_steps(4),{ease: FlxEase.expoOut});
        // case 1855: //bf solo
            
    }   
}

function clearResetFinale() {
    for (itm in grpCoolTxt.members){
        grpCoolTxt.remove(itm,false);
        try {
            itm.destroy();
            itm = null;
        } catch(e:Dynamic) trace("err " + e);
        
    }

    camSubs.zoom = 1;
}

function onDadHit(e) {
    if(lordP2.visible){
        FlxG.camera.shake(0.005, 0.05, true, true);
    }
}

function onCountdown(e) {
    e.cancel();
}