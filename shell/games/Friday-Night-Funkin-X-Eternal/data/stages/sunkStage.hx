import hxvlc.flixel.FlxVideoSprite;
import flixel.addons.display.FlxBackdrop;

var mlgVideo:FlxVideoSprite;
var videoLayer;
var camVideos;
var greenScreen;
var sunkyJump:FlxSprite;
var leakMode = false;


function create() {

      camVideos = new FlxCamera();
      camVideos.bgColor = FlxColor.TRANSPARENT;
      camVideos.visible = true;
      FlxG.cameras.add(camVideos, false);

      greenScreen = new CustomShader("greens");
      greenScreen.threshold = 0.8;
      greenScreen.softness = 0.2;

      sunkTrans = new FlxVideoSprite(-500, -250);
      sunkTrans.cameras = [camVideos];
      sunkTrans.shader = greenScreen;
      sunkTrans.visible = false;
      sunkTrans.scale.set(0.8, 0.8);
      sunkTrans.antialiasing = true;
      sunkTrans.load(Paths.video("Sunky_Transition"), [":no-audio"]);
      sunkTrans.bitmap.onEndReached.add(() -> {
          sunkTrans.destroy();
      });
      add(sunkTrans);

      grpBGparts = new FlxTypedGroup();
      insert(0, grpBGparts);

      a = new FlxBackdrop(Paths.image('exe/sunky/a'));
      a.velocity.set(-100, -100);
      a.x -= 2000;
      a.scrollFactor.set(0, 0);
      grpBGparts.add(a);

      b = new FlxBackdrop(Paths.image('exe/sunky/b'));
      b.velocity.set(-100, -100);
      b.x -= 2000;
      b.scrollFactor.set(0, 0);
      grpBGparts.add(b);

      srko = new FlxSprite(220, 523).loadGraphic(Paths.image('exe/sunky/srko'));
      srko.updateHitbox();
      srko.antialiasing = true;
      srko.scrollFactor.set(1, 1);
      grpBGparts.add(srko);

      ceral = new FlxSprite(565.7, 51.3).loadGraphic(Paths.image('exe/sunky/ceral'));
      ceral.updateHitbox();
      ceral.antialiasing = true;
      ceral.scrollFactor.set(0.3, 0.3);
      grpBGparts.add(ceral);

      milk = new FlxSprite(474.85, 47.45).loadGraphic(Paths.image('exe/sunky/milk'));
      milk.updateHitbox();
      milk.antialiasing = true;
      milk.scrollFactor.set(0.3, 0.3);
      grpBGparts.add(milk);


      for(i in [floor, disco, speakers, bg])i.visible = true;
      for(i in [milk, ceral, srko])i.visible = false;
}


//Soulless DX YCE Coding LOL - N1ckolas
function beatHit(curBeat:Int) {
     if (leakMode){
        for(i in [floor, disco, speakers, bg])i.visible = false;
        for(i in [milk, ceral, srko])i.visible = true;
        if (curBeat % 4 == 0){

          milk.y = 47.45;
          ceral.y -= 10000;
          a.alpha = 1;
          b.alpha = 0;

        }
        if (curBeat % 4 == 2){
              milk.y -= 10000;
              ceral.y = 51.3;
              a.alpha = 0;
              b.alpha = 1;
        }
        if (curBeat % 2 == 0){
              milk.angle = 30;
              ceral.angle = -30;
        }
        if (curBeat % 2 == 1){
              milk.angle = 0;
              ceral.angle = 0;
        }
  }

    if (curBeat == 221){
	      sunkTrans.visible = true;     
        sunkTrans.play();
    }

    if (curBeat == 226){
      leakMode = true;
    }

    if (curBeat == 364){
        leakMode = false;
        for(i in [floor, disco, speakers, bg])i.visible = true;
        for(i in [milk, ceral, srko])i.visible = false;

    }
}
