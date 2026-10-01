import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.FlxColor;
import flixel.effects.FlxFlicker;
import flixel.FlxTween;
import funkin.savedata.FunkinSave;
import Loader;
var curMix:Int = 1; //0 1 2
var canMove:Bool = false;
var mixSongs:Array<String> = ['Endless JP', 'Endless', 'Endless US'];
var mixSelectX:Array<Float> = [88, 290.5, 495.5];

override function create()
{
    FlxG.mouse.visible = true;

    for (sound in ['menu/scroll', 'menu/CDSelect', 'menu/cancel'])
        FlxG.sound.cache(Paths.sound(sound));
    for (asset in [
        'menus/mixes/pat', 'menus/mixes/bg', 'menus/mixes/divider',
        'menus/mixes/sound', 'menus/mixes/nametag', 'menus/mixes/backbutton',
        'menus/mixes/window', 'menus/mixes/eggman_dj', 'menus/mixes/note1',
        'menus/mixes/note2', 'menus/mixes/JPbutton', 'menus/mixes/OGbutton',
        'menus/mixes/USbutton', 'menus/mixes/selection'
    ])
        graphicCache.cache(Paths.image(asset));

    CoolUtil.playMusic(Paths.music('menus/mixes'), false, 0.7, true, 136);


    pat = new FlxBackdrop(Paths.image('menus/mixes/pat'), FlxAxes.XY);
    pat.antialiasing = false;
    pat.scale.set(2, 2);
    pat.velocity.set(100, 100);
    add(pat);

    bg = new FlxBackdrop(Paths.image('menus/mixes/bg'), FlxAxes.XY);
    bg.antialiasing = false;
    bg.scale.set(3, 3);
    bg.velocity.set(-100, -100);
    bg.alpha = 0.8;
    add(bg);

    bgovly = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000A9B);
    bgovly.antialiasing = false;
    bgovly.alpha = 0.5;
    add(bgovly);

    divider = new FlxSprite().loadGraphic(Paths.image('menus/mixes/divider'));
    divider.antialiasing = true;
    divider.scale.set(0.75, 0.75);
    divider.screenCenter();
    divider.y += 300;
    divider.x += 1;
    divider.flipY = true;
    add(divider);

    UI = new FlxSprite(100, 630).loadGraphic(Paths.image('menus/mixes/sound'));
    FlxTween.tween(UI, {x: UI.x + 20}, 0.5, {ease: FlxEase.sineInOut});
    UI.antialiasing = false;
    UI.scale.set(3, 3);
    add(UI);

    name = new FlxSprite(900, 40).loadGraphic(Paths.image('menus/mixes/nametag'));
    name.antialiasing = false;
    FlxTween.tween(name, {x: name.x - 12}, 0.5, {ease: FlxEase.sineInOut});
    name.scale.set(3.2, 3.2);
    add(name);

    back = new FlxSprite(1080, 625);
	back.frames = Paths.getFrames('menus/mixes/backbutton');
	back.animation.addByPrefix('idle', 'backbutton static');
    back.animation.addByPrefix('selected', 'backbutton select');
	back.animation.play('idle');
    back.scale.set(0.286, 0.286);
    back.updateHitbox();
    back.antialiasing = false;
    add(back);

    window = new FlxSprite().loadGraphic(Paths.image('menus/mixes/window'));
    window.antialiasing = true;
    window.scale.set(0.67, 0.75);
    window.screenCenter();
    window.y -= 20;
    window.x += 1;
    add(window);

    eggman = new FlxSprite(400, 100);
	eggman.frames = Paths.getFrames('menus/mixes/eggman_dj');
	eggman.animation.addByPrefix('idle', 'idle', 6);
	eggman.scale.set(3, 3);
    eggman.antialiasing = false;
    eggman.screenCenter();
    eggman.y -= 122;
    add(eggman);

    note1 = new FlxSprite(0, 0).loadGraphic(Paths.image('menus/mixes/note1'));
	note1.scale.set(0.290, 0.290);
    note1.antialiasing = false;
    note1.screenCenter();
    note1.x -= 112.5;
    note1.y -= 104;
    add(note1);

    note2 = new FlxSprite(0, 0).loadGraphic(Paths.image('menus/mixes/note2'));
	note2.scale.set(0.290, 0.290);
    note2.antialiasing = false;
    note2.screenCenter();
    note2.x += 116.5;
    note2.y -= 150.5;
    add(note2);

    jp = new FlxSprite(0, 0);
	jp.frames = Paths.getFrames('menus/mixes/JPbutton');
	jp.animation.addByPrefix('idle', 'JPbutton static');
	jp.animation.addByPrefix('selected', 'JPbutton select');
	jp.animation.play('idle');
    jp.scale.set(0.286, 0.286);
    jp.updateHitbox();
    jp.antialiasing = false;
    jp.screenCenter();
    jp.x -= 202;
    jp.y += 26;
    add(jp);

    og = new FlxSprite(0, 0);
	og.frames = Paths.getFrames('menus/mixes/OGbutton');
	og.animation.addByPrefix('idle', 'OGbutton static');
	og.animation.addByPrefix('selected', 'OGbutton select');
	og.animation.play('idle');
	og.scale.set(0.286, 0.286);
    og.updateHitbox();
    og.antialiasing = false;
    og.screenCenter();
    og.x += 1;
    og.y += 25;
    add(og);

    us = new FlxSprite(0, 0);
	us.frames = Paths.getFrames('menus/mixes/USbutton');
	us.animation.addByPrefix('idle', 'USbutton static');
	us.animation.addByPrefix('selected', 'USbutton select');
	us.animation.play('idle');
	us.scale.set(0.286, 0.286);
    us.updateHitbox();
    us.antialiasing = false;
    us.screenCenter();
    us.x += 206;
    us.y += 26;
    add(us);

    selection = new FlxSprite(0, 0).loadGraphic(Paths.image('menus/mixes/selection'));
    selection.scale.set(0.286, 0.286);
    selection.antialiasing = false;
    selection.screenCenter();
    selection.y += 26;
    add(selection);

    saveData = FunkinSave.getSongHighscore(mixSongs[curMix], 'hard');
    scoreAmt = new FlxText(320, 460, 600, "SCORE: " + saveData.score);
    scoreAmt.setFormat(Paths.font("sonic1HUD.ttf"), 34, FlxColor.WHITE, "center");
    add(scoreAmt);

    FlxTween.tween(note1, { y: 118, }, 1.5, {loopDelay: 0.5, type: FlxTween.PINGPONG});
    FlxTween.tween(note2, { y: note2.y + 42.5, }, 1.5, {loopDelay: 0.5, type: FlxTween.PINGPONG});
    new FlxTimer().start(0.1, function(tmr:FlxTimer)
    {
        canMove = true;
    });
}

function update(elapsed:Float)
{
    
    var mouseAccept:Bool = false;
    var mouseBack:Bool = false;
    var overBack:Bool = false;

    saveData = FunkinSave.getSongHighscore(mixSongs[curMix], 'hard');
    scoreAmt.text = 'SCORE: '+saveData.score;
        
    if (canMove) {
        var buttons = [jp, og, us];
        for (i in 0...buttons.length)
            if (FlxG.mouse.screenX >= buttons[i].x + 15 && FlxG.mouse.screenX <= buttons[i].x + buttons[i].width - 15
            && FlxG.mouse.screenY >= buttons[i].y + 10 && FlxG.mouse.screenY <= buttons[i].y + buttons[i].height - 10) {
                if (curMix != i) {
                    curMix = i;
                    FlxG.sound.play(Paths.sound('menu/scroll'));
                }
                if (FlxG.mouse.justPressed) mouseAccept = true;
                break;
            }

        overBack = FlxG.mouse.screenX >= back.x + 10 && FlxG.mouse.screenX <= back.x + back.width - 10
            && FlxG.mouse.screenY >= back.y + 6 && FlxG.mouse.screenY <= back.y + back.height - 6;
        mouseBack = FlxG.mouse.justPressed && overBack;
        

    }

    if((controls.ACCEPT || mouseAccept) && canMove)
    {
        FlxG.sound.play(Paths.sound('menu/CDSelect'));
        canMove = false;

        var buttons = [jp, og, us];
        FlxFlicker.flicker(buttons[curMix], 0.5, 0.04, true, true, () -> {
            Loader.loadSongWithReturn(mixSongs[curMix], 'hard', "XEternalMixesMenu");
            FlxG.switchState(new PlayState());
        });
    }

    if(controls.BACK || mouseBack)
    {
        FlxG.sound.play(Paths.sound('menu/cancel'));
        FlxG.switchState(new GameState("XEternalFreeplayState"));
        back.animation.play('selected');
    }
    else
        back.animation.play(overBack ? 'selected' : 'idle');

    if(curMix < 0)
    {
        curMix = 2;
    }
    else if(curMix > 2)
    {
        curMix = 0;
    }

    var buttons = [jp, og, us];
    selection.x = mixSelectX[curMix];
    for (i in 0...buttons.length)
        buttons[i].animation.play(i == curMix ? 'selected' : 'idle');

    if(controls.LEFT_P && canMove){
        FlxG.sound.play(Paths.sound('menu/scroll'));
        curMix -= 1;
    }else if(controls.RIGHT_P && canMove){
        FlxG.sound.play(Paths.sound('menu/scroll'));
        curMix += 1;
    }
}

function beatHit(curBeat:Int) {
    if (curBeat % 4 == 0)eggman.animation.play('idle');

    
}