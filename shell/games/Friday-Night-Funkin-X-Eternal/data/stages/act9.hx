var shader = null;
var bend = null;
var fireLight = null;
function create() {
    sky.color = 0x81740000;
    bf.y +=10;

    for (fire in [fireback, firefront]) {
        fire.frames = Paths.getSparrowAtlas('exe/sally/Fire');
        fire.animation.addByPrefix('burn', 'firebg instancia 1', 24, true);
        fire.alpha = 0;
    }
    

    if (FlxG.save.data.modShaders) {
        shader = new CustomShader("lineBoil");
        shader.data.distortTexture.input = Assets.getBitmapData(Paths.image('effects/heatwave'));
        shader.INTENSITY = 0.008;

        fireLight = new CustomShader("firelight");
        fireLight.amount = 0;

        bend = new CustomShader("barrel");
        bend.data.dis1.value = [-0.1];
        bend.data.dis2.value = [-0.1];

        water.shader = shader;
        
    }
}
function stepHit(curStep:Int) {
    switch(curStep) {
        case 1488:
            for (fire in [fireback, firefront]) {
                fire.visible = true;
                fire.alpha = 0;
                fire.animation.play('burn', true);
                FlxTween.cancelTweensOf(fire);
                FlxTween.tween(fire, {y: fire.y - 600, alpha: 1}, 7, {ease: FlxEase.sineInOut});
            }

            if (FlxG.save.data.modShaders && fireLight != null) {
                fireLight.amount = 0;
                camGame.addShader(fireLight);
                FlxTween.num(0, 1, 7, {ease: FlxEase.sineInOut}, (v:Float) -> {
                    if (fireLight != null) fireLight.amount = v;
                });
            }
    }
}

var localTime:Float = 0;
function update(elapsed:Float) {
    localTime += elapsed;
 
    if (shader != null) shader.iTime = localTime;
    if (fireLight != null) fireLight.iTime = localTime;
}
