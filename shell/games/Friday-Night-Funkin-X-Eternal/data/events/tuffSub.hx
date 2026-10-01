
import flixel.text.FlxTextBorderStyle;

var wordsArr:Array<FunkinText> = [];
public var camSubs:FlxCamera;
var waterFX:CustomShader;

function postCreate() {
    camSubs = new FlxCamera();
    camSubs.bgColor = 0;
    FlxG.cameras.add(camSubs, false);

    if (FlxG.save.data.modShaders) create_shader();
}

function create_shader() {
    waterFX = new CustomShader("water");
    waterFX.intensityMod = 0.0; waterFX.iTime = 0;
    waterFX.intensityModX = 0.0; waterFX.intensityModY = 0.0;
    camSubs.addShader(waterFX);
}

function update() {
    if (waterFX != null) waterFX.iTime = Conductor.songPosition / 1000;
}

public function lowerWaterFx() {
    if (waterFX == null) return;

    waterFX.intensityMod = 0;
    waterFX.intensityModX = 0;
    waterFX.intensityModY = 0;
}
var inc:Int = 0;
function updateTxt(txt:String,?clear:Bool):String {
    if (inc == 0){
        //reset
        if (waterFX != null){
            waterFX.intensityMod = 0.0;
            waterFX.intensityModX = 0.0;
            waterFX.intensityModY = 0.0;

            FlxTween.num(waterFX.intensityMod, 8.0, t_steps(12), {ease: FlxEase.expoOut}, (v:Float) -> {
                waterFX.intensityMod = v;
            });

            FlxTween.num(waterFX.intensityModX, 4.0, t_steps(12), {ease: FlxEase.expoOut}, (v:Float) -> {
                waterFX.intensityModX = v;
            });

            FlxTween.num(waterFX.intensityModY, 2.0, t_steps(12), {ease: FlxEase.expoOut}, (v:Float) -> {
                waterFX.intensityModY = v;
            });
        }
        //tween t_steps(12)
    }
    
    if (txt != ""){
        var eWords:FunkinText = new FunkinText(0,0,FlxG.width,txt,64 + (inc * 10));
        eWords.setFormat(Paths.font('menuFont.ttf'), eWords.size, (inc == 4 ? FlxColor.RED : FlxColor.WHITE), 'center', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        eWords.camera = camSubs;
        eWords.autoSize = true;
        eWords.screenCenter();
        eWords.x = -500 + (inc * 200);
        eWords.y += FlxG.random.float(-100,100);
        if (inc == 4) eWords.screenCenter();
        add(eWords);
        eWords.alpha = 0;
        // eWords.scale.set(1.2 * inc,1.2 * inc);
        // FlxTween.tween(eWords,{"scale.x": 1,"scale.y": 1}, t_steps(2 + (inc * 0.5)), {ease: FlxEase.expoOut});
        FlxTween.tween(eWords,{alpha: 1}, t_steps(2 + (inc * 0.5)), {ease: FlxEase.expoOut});

        wordsArr.push(eWords);
    }
    
    inc++;
    if (clear){
        inc = 0;
        for (i in wordsArr){
            remove(i,true);
            i.destroy();
        }
    }
    
    return txt;
}

function onEvent(_) {
    if (_.event.name == 'tuffSub') {
        updateTxt(_.event.params[0],_.event.params[1]);
    }
}
