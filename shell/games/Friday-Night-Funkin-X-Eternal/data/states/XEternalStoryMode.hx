import flixel.effects.FlxFlicker;
import flixel.text.FlxTextAlign;
import flixel.text.FlxTextBorderStyle;
import flixel.math.FlxMath;
import openfl.text.TextFormatAlign;
import flixel.addons.display.FlxBackdrop;
import flixel.tweens.FlxTweenType;

var songsBeaten:Int = 0;
var curMnger:Int = 0;
var weeks:Array<String> = [
    "Too Slow",
    "You Cant Run",
    "Triple Trouble"
];


var grpWeeks:FlxTypedGroup<FlxSprite>;
var buzz = null;
var lockShaderTime:Float = 0;
var portraitChoice:Int = -1;
var charArrows:Array<FlxSprite> = [];

function create() {
    FlxG.mouse.visible = true;
    songsBeaten = FlxG.save.data.songsBeaten == null ? 0 : FlxG.save.data.songsBeaten;
    if (songsBeaten < 0) songsBeaten = 0;
    if (songsBeaten > weeks.length) songsBeaten = weeks.length;

    for (sound in ['menu/scroll', 'menu/confirm', 'menu/denied'])
        FlxG.sound.cache(Paths.sound(sound));
    for (asset in [
        'menus/storymode/bgclouds',
        'menus/storymode/yellowbox', 'menus/storymode/SMMStatic',
        'menus/storymode/bf', 'menus/storymode/gf', 'menus/storymode/redbox',
        'menus/storymode/difficulties', 'menus/storymode/lock',
        'menus/freeplay/fpstuff/Eclipsera'
    ])
        graphicCache.cache(Paths.image(asset));

    FlxG.camera.zoom = 0.9;
    window.title = windowTitle + " - StoryMode";
    FlxG.sound.playMusic(Paths.music('menus/story'), 0);
    FlxG.sound.music.fadeIn(5, 0, 0.5);

    wall = new FlxBackdrop(Paths.image('menus/storymode/bgclouds'), FlxAxes.X);
    wall.scale.y = 0.5;
    wall.scale.x = 0.5;
    add(wall);
    wall.alpha = 1;
    wall.velocity.x -= 30;
    wall.y -= 500;

    yellowbox = new FlxSprite().loadGraphic(Paths.image('menus/storymode/yellowbox'));
    yellowbox.scale.set(4, 3.2);
    yellowbox.screenCenter();
    yellowbox.y -= 20; 
    add(yellowbox);


    grpWeeks = new FlxTypedGroup();
    add(grpWeeks);

    for (i in 0...weeks.length){

        testGrp = new FlxSprite(0,-180);
        testGrp.loadGraphic(Paths.image('menus/freeplay/fpstuff/' + weeks[i]));
        testGrp.antialiasing = false;

        if (i == 1){testGrp.updateHitbox();}
        
        testGrp.ID = i;
        testGrp.screenCenter(FlxAxes.X);
        grpWeeks.add(testGrp);
        testGrp.scale.set(0.26,0.26);
        testGrp.x -= 10;
        testGrp.y -= 16;

    }

    tvStatic = new FlxSprite();
    tvStatic.frames = Paths.getSparrowAtlas('menus/storymode/SMMStatic');
    tvStatic.animation.addByPrefix('idle', 'damfstatic', 24, true);
    tvStatic.animation.play('idle');
    tvStatic.scale.set(0.26, 0.26);
    add(tvStatic);
    tvStatic.y -= 196; 
    tvStatic.x -= 10; 

    bf = new FlxSprite().loadGraphic(Paths.image('menus/storymode/bf'));
    bf.scale.set(3.5, 3.5);
    bf.screenCenter();
    bf.y += 80;
    add(bf);

    gf = new FlxSprite().loadGraphic(Paths.image('menus/storymode/gf'));
    gf.scale.set(3.5, 3.5);
    gf.x = bf.x;
    gf.y = bf.y - 17;
    gf.visible = false;
    add(gf);

    redbox = new FlxSprite().loadGraphic(Paths.image('menus/storymode/redbox'));
    redbox.scale.set(3.8, 3.2);
    redbox.screenCenter();
    redbox.y =  yellowbox.y - 10; 
    redbox.x =  yellowbox.x; 
    add(redbox);
    FlxFlicker.flicker(redbox, 0, 0.1, true, true);

    leftArrow = new FlxSprite(0, 0);
    leftArrow.screenCenter();
    leftArrow.frames = Paths.getSparrowAtlas('menus/storymode/difficulties');
    leftArrow.animation.addByPrefix('idle', "arrow left");
    leftArrow.animation.addByPrefix('press', "arrow push left", 24, false);
    leftArrow.animation.play('idle');
    leftArrow.x -= 208;
    leftArrow.y -= 25;
    add(leftArrow);

    rightArrow = new FlxSprite(leftArrow.x + 355, leftArrow.y);
    rightArrow.frames = Paths.getSparrowAtlas('menus/storymode/difficulties');
    rightArrow.animation.addByPrefix('idle', 'arrow right');
    rightArrow.animation.addByPrefix('presss', "arrow push right", 24, false);
    rightArrow.animation.play('idle');
    add(rightArrow);

    for (i in 0...2) {
        charArrow = new FlxSprite();
        charArrow.frames = Paths.getSparrowAtlas('menus/storymode/difficulties');
        charArrow.animation.addByPrefix('idle', i == 0 ? "arrow left" : "arrow right");
        charArrow.animation.addByPrefix('press', i == 0 ? "arrow push left" : "arrow push right", 24, false);
        charArrow.animation.play('idle');
        charArrow.scale.set(0.85, 0.85);
        charArrow.updateHitbox();
        charArrow.angle = 90;
        charArrow.x = bf.x + (bf.width - charArrow.width) * 0.5;
        charArrow.y = i == 0 ? bf.y - 120 : bf.y + bf.height + 40;
        charArrow.visible = false;
        charArrow.antialiasing = false;
        charArrows.push(charArrow);
        add(charArrow);
    }

    lockSprite = new FlxSprite().loadGraphic(Paths.image('menus/storymode/lock'));
    lockSprite.scale.set(3, 3);
    lockSprite.screenCenter();
    lockSprite.y =  bf.y + 30; 
    lockSprite.x =  bf.x; 
    add(lockSprite);

    dataTxt = new FlxSprite().loadGraphic(Paths.image('menus/storymode/dataSelect'));
    dataTxt.scale.set(3, 3);
    dataTxt.screenCenter();
    dataTxt.y =  bf.y + 240; 
    dataTxt.x -= 8; 
    add(dataTxt);
   
    for(i in [redbox, lockSprite, dataTxt, bf, gf, wall]){i.antialiasing = false;}

    if (songsBeaten < weeks.length - 1) {
        buzz = new CustomShader("advancedStatic");
        buzz.iTime = 0;
        buzz.color = [1, 1, 1, 1];
        buzz.size = [3, 3];
        buzz.frameRate = 30;
        buzz.mixColors = true;
    }
}

function update(elapsed:Float) {
    var lockedSong:Bool = curMnger > songsBeaten;
    var charSelect:Bool = curMnger == 2 && songsBeaten >= 2;
    var altSong:Bool = charSelect && specialInt == 1;
    var mouseAccept:Bool = false;

    FlxG.camera.scroll.x = FlxMath.lerp(FlxG.camera.scroll.x, (FlxG.mouse.screenX - FlxG.width / 2) * -0.02, FlxMath.bound(elapsed * 4, 0, 1));
    FlxG.camera.scroll.y = FlxMath.lerp(FlxG.camera.scroll.y, (FlxG.mouse.screenY - FlxG.height / 2) * -0.015, FlxMath.bound(elapsed * 4, 0, 1));

    lockSprite.visible = lockedSong;
    bf.visible = !altSong;
    gf.visible = altSong;
    for (arrow in charArrows)
        arrow.visible = charSelect;
    if (buzz != null && lockedSong) {
        lockShaderTime += elapsed;
        buzz.iTime = lockShaderTime;
    }
    tvStatic.alpha = FlxMath.lerp(tvStatic.alpha, 0.5, FlxMath.bound(elapsed * 4, 0, 1));

    if(FlxG.keys.pressed.ONE && Options.devMode)songsBeaten = weeks.length;
    if(FlxG.keys.pressed.TWO && Options.devMode)songsBeaten = 0;

    if (FlxG.keys.pressed.ESCAPE)
    {FlxG.switchState(new MainMenuState());}

    var shiftMult:Int = 1;
    if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

    var menuMove:Int = (controls.LEFT_P ? -shiftMult : 0) + (controls.RIGHT_P ? shiftMult : 0);
    var charMove:Int = (controls.UP_P ? -1 : 0) + (controls.DOWN_P ? 1 : 0);

    if (menuMove != 0) {
        changeSelection(menuMove);
        tvStatic.alpha = 1;
    } else if (charSelect && charMove != 0) {
        changeWeekSongSel(charMove);
        tvStatic.alpha = 1;
    }

    var overLeft:Bool = FlxG.mouse.overlaps(leftArrow);
    var overRight:Bool = FlxG.mouse.overlaps(rightArrow);

    if (FlxG.mouse.justPressed) {
        var clickedMove:Int = overLeft ? -1 : (overRight ? 1 : 0);
        var clickedCharArrow:Bool = false;

        if (clickedMove != 0) {
            changeSelection(clickedMove);
            tvStatic.alpha = 1;
        } else if (charSelect) {
            for (i in 0...charArrows.length)
                if (FlxG.mouse.overlaps(charArrows[i])) {
                    clickedCharArrow = true;
                    changeWeekSongSel(i == 0 ? -1 : 1);
                    tvStatic.alpha = 1;
                }
        }

        if (clickedMove == 0 && !clickedCharArrow
            && (FlxG.mouse.overlaps(yellowbox) || FlxG.mouse.overlaps(redbox) || FlxG.mouse.overlaps(bf) || FlxG.mouse.overlaps(gf)))
            mouseAccept = true;
    }

    if (controls.RIGHT || overRight){rightArrow.animation.play('presss');}
    else{rightArrow.animation.play('idle');}
    
    if (controls.LEFT || overLeft){leftArrow.animation.play('press');}
    else{leftArrow.animation.play('idle');}

    for (i in 0...charArrows.length)
        charArrows[i].animation.play(((i == 0 ? controls.UP : controls.DOWN) || (charSelect && FlxG.mouse.overlaps(charArrows[i]))) ? 'press' : 'idle');

    if(FlxG.mouse.wheel != 0)
    {changeSelection(-shiftMult * FlxG.mouse.wheel, false);}

    
    if (controls.ACCEPT || mouseAccept) {
        if (curMnger <= songsBeaten) {
            var storySongs = [];
            if (altSong)
                storySongs.push({name: "Eclipsera", hide: false});
            else
                for (i in curMnger...weeks.length)
                    storySongs.push({name: weeks[i], hide: false});

            PlayState.loadWeek({
                name: "Main Week",
                id: "main",
                sprite: null,
                chars: [null, null, null],
                songs: storySongs,
                difficulties: ["hard"]
            }, "hard");

            FlxG.sound.play(Paths.sound('menu/confirm'),0.6);
            FlxTween.tween(FlxG.camera, {zoom: 3}, 1.1,{ease: FlxEase.sineInOut, onComplete: function () {
                
                 FlxG.switchState(new PlayState());
            }});
             FlxTween.tween(FlxG.camera, {alpha: 0}, 1,{ease: FlxEase.sineInOut});
           
        }
        else {
            FlxG.sound.play(Paths.sound('menu/denied'),0.6);
            FlxG.camera.shake(0.01, 0.15);
        }
    }
    
    if (grpWeeks != null)
    for (item in grpWeeks.members){
        var portrait:Int = altSong ? 1 : 0;
        if (item.ID == 2 && curMnger == 2 && portraitChoice != portrait) {
            item.loadGraphic(Paths.image('menus/freeplay/fpstuff/' + (altSong ? "Eclipsera" : "Triple Trouble")));
            portraitChoice = portrait;
        }

        item.alpha = (item.ID == curMnger) ? 1 : 0;
        if (buzz != null) {
            var staticArt:Bool = item.ID == curMnger && lockedSong;
            item.color = staticArt ? 0xFF000000 : 0xFFFFFFFF;
            item.shader = staticArt ? buzz : null;
        }
    }

}

function changeSelection(change:Int = 0, playSound:Bool = true){
    if (playSound == true){FlxG.sound.play(Paths.sound('menu/scroll'),0.6);}
    
    curMnger += change;
    specialInt = 0;
    portraitChoice = -1;

	if (curMnger < 0)
		curMnger = weeks.length - 1;
	if (curMnger >= weeks.length)
		curMnger = 0;
    changeWeekSongSel(0, false);
}

var specialInt:Int = 0;
function changeWeekSongSel(change:Int = 0, playSound:Bool = true){
    if (playSound == true){FlxG.sound.play(Paths.sound('menu/scroll'),0.6);}
    specialInt += change;

	if (specialInt < 0)
		specialInt = 1;

	if (specialInt > 1)
		specialInt = 0;
}

function destroy() {
    buzz = null;
}
