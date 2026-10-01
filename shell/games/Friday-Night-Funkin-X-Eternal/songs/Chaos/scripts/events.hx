var superBF:Dynamic;
var bfDefault:Dynamic;

function postCreate() {
    porker = stage.getSprite("porker");
     
    bfDefault = strumLines.members[1].characters[0];
    bf_pov = strumLines.members[1].characters[2];
    superBF = strumLines.members[1].characters[1];

    superSonic = strumLines.members[0].characters[0];
    suprSonicAnims  = strumLines.members[0].characters[1];
    suprSonicPov  = strumLines.members[0].characters[2];

    superBF.x = -580;
    superBF.y = -660;
    for (char in [superBF, superSonic, suprSonicPov, bf_pov])
        char.visible = false;


}

function stepHit(curStep:Int) {
    switch(curStep) {
        case 10:
            superSonic.visible = true;
        case 784:
            porker.visible = false;
            defaultCamZoom = 0.7;
            camHUD.flash(0xFFFFAE00, 0.5);
            bf_pov.visible = true;
            bfDefault.visible = false;

            suprSonicPov.visible = true;
            superSonic.visible = false;

        case 1008:
            camHUD.flash(0xFFFFAE00, 0.5);
            defaultCamZoom = 0.45;
            bf_pov.visible = false;
            suprSonicPov.visible = false;
            superSonic.visible = true;

            superBF.visible = true;
            bfDefault.visible = false;
            porker.visible = true;

    }
}
