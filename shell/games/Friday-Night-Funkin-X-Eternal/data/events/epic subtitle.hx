
import flixel.text.FlxTextBorderStyle;

var textGrp:FlxTypedGroup;
var wordsArr:Array<FunkinText> = [];

function postCreate() {
    textGrp = new FlxTypedGroup();
    insert(members.indexOf(stage.getSprite('floor')),textGrp);
}

var addInc:Int = 0;
var appearTwn:FlxTween;
function onEvent(_) {
    if (_.event.name == 'epic subtitle') {
        
        var prevObj = textGrp.members[textGrp.members.length-1];
        
        
        
        //Up and trans
        if (_.event.params[2]){
            for (obj in textGrp.members){
                FlxTween.tween(obj, {alpha: 0, y: obj.y - 600}, t_steps(_.event.params[1]), {ease: FlxEase.smootherStepInOut, onComplete: () -> {
                    textGrp.remove(obj,true);
                    obj.destroy();
                }});
            }
        }

        //left and trans
        if (_.event.params[3]){
            FlxTween.tween(prevObj, {x: prevObj.x - FlxG.width*2}, t_steps(_.event.params[1]), {ease: FlxEase.smootherStepInOut, onComplete: () -> {
                textGrp.remove(prevObj,true);
                prevObj.destroy();
            }}); 
        }

        
        var epic:FunkinText = new FunkinText(0,0,null,_.event.params[0],512);
        epic.setFormat(Paths.font('menuFont.ttf'), epic.size, FlxColor.BLACK, 'center');
        epic.scrollFactor.set();
        epic.autoSize = true;
        epic.screenCenter();
        epic.alpha = 0;
        textGrp.add(epic);

        //pre move it to the right
        if (_.event.params[3]){
            epic.alpha = 1;

            epic.y -= 300;

            epic.x += epic.width;

            FlxTween.tween(epic, {x: epic.x - (epic.width * 2)}, t_steps(_.event.params[1] * 1.3), {ease: FlxEase.smootherStepInOut});

            return;
        }

        //add to existing
        if (_.event.params[4]){
            epic.size = epic.size / 2;

            if (addInc == 0)
                epic.screenCenter().x -= epic.width;

            if (addInc == 1){

                var preprevObj = textGrp.members[textGrp.members.length-2];

                epic.x = preprevObj.x + preprevObj.width;
                
                addInc = 0;
            }

            addInc++;
        }
        
        //appear
        appearTwn = FlxTween.tween(epic, {alpha: 1, y: epic.y - 300}, t_steps(_.event.params[1]), {ease: FlxEase.smootherStepInOut}); 

        
    }
}
