public var camEvt:FlxCamera;

function create() {
        var b = true;
        importScript('data/scripts/resizing');
        ratioThing(960,  720, false);

        camEvt = new FlxCamera();
        camEvt.bgColor = new FlxColor(0x00000000);
        FlxG.cameras.add(camEvt, false);

        sunkage = new FlxSprite(0, 0).loadGraphic(Paths.image('exe/sunky/sunkage'));
        add(sunkage);
        sunkage.cameras = [camEvt];

        camEvt.alpha = 0;
}

function destroy() ratioThing(1280, 720, true);

function onNoteHit(e) {
        e.note.splash = "milkSplash";
}


function stepHit(curStep:Int) {
        switch(curStep){
                case 1440:
                          FlxTween.tween(camEvt, {alpha: 1}, 1);
                case 1460:
                          camEvt.alpha = 0;
        }
}