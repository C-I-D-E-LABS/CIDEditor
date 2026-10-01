var grpBGparts:FlxTypedGroup;
var noteSkinDad:String = "default";
var noteSkinBf:String = "default";

function create() {

    grpBGparts = new FlxTypedGroup();
    insert(0, grpBGparts);

    if (FlxG.save.data.modShaders) {
        var shader = new CustomShader("demon_blur");
        shader.data.u_alpha.value = [0.5];
        shader.data.u_size.value = [1];
        camGame.addShader(shader);
    }

    dad.y += 280;
    dad.x += 650;
    
    dad.scale.set(1.1, 1.1);
    boyfriend.scale.set(0.9, 0.9);

}
