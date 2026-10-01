

import flixel.text.FlxTextBorderStyle;

var grpBehindTxt:FlxTypedGroup;

function postCreate() {
    grpBehindTxt = new FlxTypedGroup();
    insert(members.indexOf(dad),grpBehindTxt);
}

var addInc:Int = 0;
var appearTwn:FlxTween;
function onEvent(_) {
    if (_.event.name == 'zipperLike') {
        var curMsg = new FunkinText(0,0,null,_.event.params[0],64);
        curMsg.setFormat(Paths.font('menuFont.ttf'), curMsg.size, FlxColor.WHITE, 'center',FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        curMsg.autoSize = true;
        curMsg.borderSize = 4;
        curMsg.borderQuality = 2;
        curMsg.setPosition(dad.x + (dad.width / 2),(addInc * curMsg.height) + (dad.y + (dad.height / 2)));
        // trace(Reflect.fields(curMsg));
        grpBehindTxt.add(curMsg);

        var delay = _.event.params[3];

        if (_.event.params[2]){
            //lyrics will go underneeth
            FlxTween.tween(curMsg,{x: curMsg.x + 400},t_steps(8),{ease: FlxEase.expoOut, onComplete: () -> angleAndGone(curMsg,delay)});


            addInc++;

        } else {
            switch(_.event.params[1]){
                case 'n': FlxTween.tween(curMsg,{y: curMsg.y - 440},t_steps(8),{ease: FlxEase.expoOut, onComplete: () -> angleAndGone(curMsg,delay)});
                case 'e': FlxTween.tween(curMsg,{x: curMsg.x + 400},t_steps(8),{ease: FlxEase.expoOut, onComplete: () -> angleAndGone(curMsg,delay)});
                case 'w': FlxTween.tween(curMsg,{x: curMsg.x - 500},t_steps(8),{ease: FlxEase.expoOut, onComplete: () -> angleAndGone(curMsg,delay)});
                case 's': FlxTween.tween(curMsg,{y: curMsg.y + 400},t_steps(8),{ease: FlxEase.expoOut, onComplete: () -> angleAndGone(curMsg,delay)});
            }

            addInc = 0;
        }
        
    }
}

function angleAndGone(obj:FunkinText,?moreDelay:Int = 0) {
    FlxTween.tween(obj,{y: obj.y + 200,alpha: 0},t_steps(4),{startDelay: t_steps(2 + moreDelay),ease: FlxEase.expoIn});
    FlxTween.tween(obj,{angle: (FlxG.random.bool(50) ? 1 : -1) * 25},t_steps(6),{startDelay: t_steps(0 + moreDelay), ease: FlxEase.expoIn, onComplete: () -> {
        grpBehindTxt.remove(obj,true);
        obj.destroy();
        obj = null;
    }});
}