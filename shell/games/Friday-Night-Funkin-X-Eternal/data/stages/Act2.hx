
import flixel.addons.display.FlxBackdrop;

var pixelBGParts:FlxTypedGroup;
var TreesFront:Dynamic;
var xenop2:Dynamic;
var xenop2pixel:Dynamic;
var xenop2angry:Dynamic;
var bfNormal:Dynamic;
var bfPixel:Dynamic;
var gfNormal:Dynamic;
var gfPixel:Dynamic;

function create() {
    xenop2 = strumLines.members[0].characters[0];
    xenop2pixel = strumLines.members[0].characters[1];
    xenop2angry = strumLines.members[0].characters[2];
    bfNormal = strumLines.members[1].characters[0];
    bfPixel = strumLines.members[1].characters[1];
    gfNormal = strumLines.members[2].characters[0];
    gfPixel = strumLines.members[2].characters[1];

    for (char in [xenop2pixel, xenop2angry, bfPixel, gfPixel])
        if (char != null) char.visible = false;

    bfPixel.y -= 50;
    gfPixel.y -= 125;
    xenop2pixel.y -= 50;
    xenop2pixel.x += 75;

    pixelBGParts = new FlxTypedGroup();
    insert(1, pixelBGParts);

    skyPiece = new FlxBackdrop(Paths.image('exe/sonicp2/skyPiece'), FlxAxes.XY);
    pixelBGParts.add(skyPiece);

    CloudsTop = new FlxBackdrop(Paths.image('exe/sonicp2/CloudsTop'), FlxAxes.X);
    pixelBGParts.add(CloudsTop);
    CloudsTop.velocity.x -= 10;


    CloudsMid = new FlxBackdrop(Paths.image('exe/sonicp2/CloudsMid'), FlxAxes.X);
    pixelBGParts.add(CloudsMid);
    CloudsMid.velocity.x -= 30;
    CloudsMid.y = CloudsTop.y + 150;

    CloudsBottom = new FlxBackdrop(Paths.image('exe/sonicp2/CloudsBottom'), FlxAxes.X);
    pixelBGParts.add(CloudsBottom);
    CloudsBottom.velocity.x -= 50;
    CloudsBottom.y = CloudsTop.y + 250;

    GenesisBG = new FlxBackdrop(null, FlxAxes.X, 0, 0);
    GenesisBG.frames = Paths.getSparrowAtlas('exe/sonicp2/HillsPix');
    GenesisBG.animation.addByPrefix('anim4', 'idle', 24, true);
    GenesisBG.animation.play('anim4');
    GenesisBG.x = 400;
    GenesisBG.y = 600;
    GenesisBG.antialiasing = false;
    pixelBGParts.add(GenesisBG);

    floorPix = new FlxSprite(400, 200).loadGraphic(Paths.image("exe/sonicp2/floorPix"));
    pixelBGParts.add(floorPix);

    for (i in pixelBGParts) {    
        i.scale.set(5.5, 5.5);
        i.alpha = 0;
    }
}

function stepHit(curStep:Int) {
    switch(curStep) {
        case 528:    
            for (char in [xenop2pixel, bfPixel, gfPixel])
                if (char != null) char.visible = true;    

            if (xenop2pixel != null) iconP2.setIcon(xenop2pixel.getIcon());
            if (bfPixel != null) iconP1.setIcon(bfPixel.getIcon());
       
            for (char in [xenop2, bfNormal, gfNormal])
                if (char != null) char.visible = false;

        case 784:
            for (char in [xenop2pixel, bfPixel, gfPixel])
                if (char != null) char.visible = false;    
            
            for (char in [xenop2angry, bfNormal, gfNormal])
                if (char != null) char.visible = true;  

            if (xenop2angry != null) iconP2.setIcon(xenop2angry.getIcon());
            if (bfNormal != null) iconP1.setIcon(bfNormal.getIcon());
    }
}
