var fleetway:Dynamic;
var fleetwayAnim:Dynamic;


function create() {
    comicFilter = new CustomShader('comic');
    FlxG.camera.addShader(comicFilter);

    beam.animation.play("idle");
    emerald.animation.play("idle");
    bf.cameraOffset.x = -150;
	bf.cameraOffset.y = -150;

    fleetwayAnim = strumLines.members[0].characters[1];
    fleetway = strumLines.members[0].characters[0];
    fleetway.visible = true;
    fleetwayAnim.visible = false;

    FlxG.camera.bgColor = 0x412D3F;
}


function playLine(lineName:String = "")
{
    fleetway.visible = false;
    fleetwayAnim.visible = true;
    fleetwayAnim.animation.finishCallback = function(anim:String) {
        fleetwayAnim.visible = false;
        fleetway.visible = true;
    };
    fleetwayAnim.playAnim(lineName, true);
}
 
function destroy() {
    FlxG.game.removeShader(comicFilter);
}