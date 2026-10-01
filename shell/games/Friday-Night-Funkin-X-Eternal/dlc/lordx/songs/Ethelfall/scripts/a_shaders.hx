

import openfl.display.BlendMode;

var shader:CustomShader;
var fog:CustomShader;
var lensDistortion:CustomShader;

function create() {

    if (Options.gameplayShaders){
        shader = new CustomShader("demon_blur");
        fog = new CustomShader("fog");
        fog.intensity = 0.9;
        lensDistortion = new CustomShader("barrel");
    }

    fogOverlay = new FunkinSprite().makeSolid(FlxG.width*4, FlxG.height*4, 0xFF294D3E); // transparent texture
    fogOverlay.scrollFactor.set(1, 1);
    fogOverlay.blend = BlendMode.SUBTRACT;
    add(fogOverlay);

    if (shader != null){
        shader.data.u_alpha.value = [0.15];
        shader.data.u_size.value = [1];
        camGame.addShader(shader);
    }
    
    if (fog != null) fogOverlay.shader = fog;

	if (lensDistortion != null){
        // Here, dis1 and dis2 control the distortion effect. Adjust these values for the desired effect.
        lensDistortion.data.dis1.value = [-0.2];
        lensDistortion.data.dis2.value = [-0.2];
        camGame.addShader(lensDistortion);
    }
}

var localTime:Float = 0;
function update(elapsed:Float) {
    localTime += elapsed;
    if (fog != null) fog.iTime = localTime;
}

function beatHit(curBeat:Int) {
    if (curBeat > 385)
        if (curBeat % 16 == 0){
            if (fog != null){
                fog.intensity = 0.75;

                FlxTween.num(fog.intensity, 0.45, t_steps(4), {ease: FlxEase.sineInOut}, (v:Float) -> {
                    fog.intensity = v;
                });
            }
        }
}
function stepHit(curStep:Int) {
    switch(curStep){
        case 1540:
            fogOverlay.alpha = 1.5;
            // fog.intensity = 0.9;
            // FlxTween.num(fog.intensity, 0.45, t_steps(8), {ease: FlxEase.sineInOut}, (v:Float) -> {
            //     fog.intensity = v;
            // });
            if (shader != null){
                shader.data.u_alpha.value = [0.75];
                shader.data.u_size.value = [1];
            }
    }
}
