import hxvlc.flixel.FlxVideoSprite;
import flixel.tweens.FlxTweenType;
import flixel.addons.display.FlxBackdrop;
import flixel.math.FlxMath;
import funkin.backend.MusicBeatState;
import funkin.backend.system.framerate.Framerate;
import funkin.menus.ModSwitchMenu;

static var seenVideo:Bool = false;
var introVid:FlxVideoSprite;
var bgStatic:FlxBackdrop;
var titleLogo:FlxSprite;
var transitioning:Bool = true;
public var enterTxt:FlxSprite;

var currentPage:Int = 0;
var pageTransitioning:Bool = false;

var rfBg:FlxSprite;
var rfLogo:FlxSprite;
var rfEyes:FlxSprite;
var rfVG:FlxSprite;
var arrowLeft:FlxSprite;
var arrowRight:FlxSprite;
// Debug combo
var comboProgress:Int = 0;
var debugUnlocked:Bool = false;
function create()
{
    for (sound in ['showMoment', 'menumomentclick', 'titleLaughSonicEXE', 'titleLaughNMI'])
        FlxG.sound.cache(Paths.sound(sound));
    for (asset in [
        'exe/tt-stage/x/Static',
        'menus/TitleScreen/logo', 'menus/TitleScreen/enterTxt',
        'menus/TitleScreen/redactedFiles/Static',
        'menus/TitleScreen/redactedFiles/logoRF',
        'menus/TitleScreen/redactedFiles/logoEyes',
        'menus/TitleScreen/redactedFiles/blackVG',
        'exe/tt-stage/x/Static', 'menus/TitleScreen/logo',
        'menus/TitleScreen/enterTxt'
    ])
        graphicCache.cache(Paths.image(asset));

    MusicBeatState.skipTransIn = false;
    CoolUtil.playMenuSong();
    FlxG.sound.music.volume = 0;
    FlxG.mouse.visible = true;

    bgStatic = new FlxBackdrop(null, FlxAxes.XY, 0, 0);
    bgStatic.frames = Paths.getSparrowAtlas('exe/tt-stage/x/Static');
    bgStatic.animation.addByPrefix('skyAnim', 'Static', 12, true);
    bgStatic.animation.play('skyAnim');
    bgStatic.alpha = 0;
    bgStatic.velocity.x -= 150;
    bgStatic.updateHitbox();
   add(bgStatic);

    titleLogo = new FlxSprite(-1870, -1200).loadGraphic(Paths.image('menus/TitleScreen/logo'));
    titleLogo.setGraphicSize(Std.int(titleLogo.width * 0.2));
    titleLogo.alpha = 0.001;
    titleLogo.antialiasing = true;
    add(titleLogo);

    arrowLeft = new FlxText(-600, FlxG.height - 80, FlxG.width, "<");
    arrowLeft.setFormat(Paths.font("sonic3TitleCard"), 68, FlxColor.WHITE, "center");
    arrowLeft.screenCenter(FlxAxes.Y);
    arrowLeft.alpha = 0;
    add(arrowLeft);

     arrowRight = new FlxText(0, FlxG.height - 80, FlxG.width, ">");
    arrowRight.setFormat(Paths.font("sonic3TitleCard"), 68, FlxColor.WHITE, "center");
    arrowRight.x = FlxG.width - arrowRight.width + 600;
    arrowRight.screenCenter(FlxAxes.Y);
    arrowRight.alpha = 0;
    add(arrowRight);

     enterTxt = new FlxSprite(230,600).loadGraphic(Paths.image("menus/TitleScreen/enterTxt"));
    add(enterTxt);
    enterTxt.alpha = 0;

    FlxTween.tween(enterTxt,{y: enterTxt.y + 30}, 3.5,{ease: FlxEase.sineInOut, type: FlxTweenType.PINGPONG});


    if (seenVideo) {
        seenVid();
    } else {
        introVid = new FlxVideoSprite(0, 0);
        introVid.load(Paths.video('XEternalIntroVid'));
        introVid.bitmap.onFormatSetup.add(() -> {
            if (introVid.bitmap != null && introVid.bitmap.bitmapData != null) {
                var scale = Math.min(
                    FlxG.width  / introVid.bitmap.bitmapData.width,
                    FlxG.height / introVid.bitmap.bitmapData.height
                );
                introVid.setGraphicSize(
                    introVid.bitmap.bitmapData.width  * scale,
                    introVid.bitmap.bitmapData.height * scale
                );
                introVid.updateHitbox();
                introVid.screenCenter();
            }
        });
        introVid.bitmap.onEndReached.add(() -> { seenVid(); });

        FlxG.camera.alpha = 0;
        add(introVid);
        new FlxTimer().start(1, (_) -> {
            FlxTween.tween(FlxG.camera, {alpha: 1}, 5, {ease: FlxEase.quintOut});
            introVid.play();
        });
    }
    
    
   
}



function seenVid()
{
    seenVideo = true;
    if (introVid != null) { introVid.destroy(); introVid = null; }

    window.title = windowTitle + " - Title";
    transitioning = false;
    FlxG.camera.flash(FlxColor.RED, 0.8);

    FlxG.sound.playMusic(Paths.music('menus/title'), 0);
    FlxG.sound.music.fadeIn(5, 0, 0.6);
    FlxG.sound.play(Paths.sound('showMoment'), 1);
    FlxG.sound.play(Paths.sound('menumomentclick'), 2);

    bgStatic.alpha = 1;
    titleLogo.alpha = 1;
    FlxTween.tween(titleLogo.scale, {x: 0.22, y: 0.22}, 1, {ease: FlxEase.quintOut});
    enterTxt.alpha = 1;

    FlxTween.tween(arrowRight, {alpha: 1}, 0.5, {ease: FlxEase.quintOut});
}

function switchPage(direction:Int)
{
    if (pageTransitioning) return;
    pageTransitioning = true;

    var fadeOut = 0.4;
    var fadeIn  = 0.5;

    if (direction == 1)
    {
        if (rfBg == null) {
            rfBg = new FlxBackdrop(null, FlxAxes.XY, 0, 0);
            rfBg.frames = Paths.getSparrowAtlas('menus/TitleScreen/redactedFiles/Static');
            rfBg.animation.addByPrefix('skyAnim', 'Static', 12, true);
            rfBg.animation.play('skyAnim');
            rfBg.alpha = 0;
            rfBg.velocity.x -= 150;
            rfBg.updateHitbox();
            insert(2, rfBg);

            rfLogo = new FlxSprite(-2040, -1200).loadGraphic(Paths.image('menus/TitleScreen/redactedFiles/logoRF'));
            rfLogo.setGraphicSize(Std.int(rfLogo.width * 0.22));
            rfLogo.alpha = 0;
            insert(3, rfLogo);

            rfEyes = new FlxSprite(250, 0).loadGraphic(Paths.image('menus/TitleScreen/redactedFiles/logoEyes'));
            rfEyes.setGraphicSize(Std.int(rfLogo.width * 0.04));
            rfEyes.alpha = 0;
            insert(4, rfEyes);

            rfVG = new FlxSprite(0, 0).loadGraphic(Paths.image('menus/TitleScreen/redactedFiles/blackVG'));
            rfVG.screenCenter();
            rfVG.scrollFactor.set(0, 0);
            rfVG.alpha = 0;
            insert(5, rfVG);
        }

        FlxG.sound.playMusic(Paths.music('menus/dlc'), 0);
        FlxG.sound.music.fadeIn(5, 0, 0.6);
        rfVG.alpha = 1;

        FlxTween.tween(titleLogo, {alpha: 0}, fadeOut, {ease: FlxEase.quintOut});
        FlxTween.tween(bgStatic,  {alpha: 0}, fadeOut, {ease: FlxEase.quintOut,
            onComplete: (_) -> {
                FlxTween.tween(rfBg, {alpha: 1}, fadeIn, {ease: FlxEase.quintOut});
                FlxTween.tween(rfLogo, {alpha: 1}, fadeIn, {ease: FlxEase.quintOut,
                    onComplete: (_) -> {
                        currentPage = 1;
                        pageTransitioning = false;
                    }
                });

                for (i => arrow in [arrowLeft, arrowRight])
                    FlxTween.tween(arrow, {alpha: i == 0 ? 1 : 0}, 0.3);
            }
        });
    }
    else
    {
        FlxG.sound.playMusic(Paths.music('menus/title'), 0);
        FlxG.sound.music.fadeIn(5, 0, 0.3);

        for (sprite in [rfVG, rfLogo])
            FlxTween.tween(sprite, {alpha: 0}, fadeOut, {ease: FlxEase.quintOut});

        FlxTween.tween(rfBg,   {alpha: 0}, fadeOut, {ease: FlxEase.quintOut,
            onComplete: (_) -> {
                FlxTween.tween(bgStatic, {alpha: 1}, fadeIn, {ease: FlxEase.quintOut});
                FlxTween.tween(titleLogo, {alpha: 1}, fadeIn, {ease: FlxEase.quintOut,
                    onComplete: (_) -> {
                        currentPage = 0;
                        pageTransitioning = false;

                        for (sprite in [rfBg, rfLogo, rfVG]) {
                            remove(sprite);
                            sprite.destroy();
                        }

                        rfBg = null;
                        rfLogo = null;
                        rfVG = null;
                    }
                });

                for (i => arrow in [arrowLeft, arrowRight])
                    FlxTween.tween(arrow, {alpha: i == 1 ? 1 : 0}, 0.3);
            }
        });
    }

    CoolUtil.playMenuSFX(0, 0.5);
}

function update(elapsed:Float)
{
    if (transitioning) return;

    FlxG.camera.scroll.x = FlxMath.lerp(FlxG.camera.scroll.x, (FlxG.mouse.screenX - FlxG.width / 2) * -0.02, FlxMath.bound(elapsed * 4, 0, 1));
    FlxG.camera.scroll.y = FlxMath.lerp(FlxG.camera.scroll.y, (FlxG.mouse.screenY - FlxG.height / 2) * -0.015, FlxMath.bound(elapsed * 4, 0, 1));

    var mouseAccept:Bool = false;

    //Debug combo (checked first, only on main page, before ENTER falls through
    if (!debugUnlocked && currentPage == 0)
    {
        checkDebugCombo();
        if (debugUnlocked) return; // swallow this frame so ENTER doesn't also confirm
    }

    //Page switching
    if (!pageTransitioning && comboProgress == 0)
    {
        var overLeft = currentPage == 1 && FlxG.mouse.screenX < 140 && FlxG.mouse.screenY >= arrowLeft.y && FlxG.mouse.screenY <= arrowLeft.y + arrowLeft.height;
        var overRight = currentPage == 0 && FlxG.mouse.screenX > FlxG.width - 140 && FlxG.mouse.screenY >= arrowRight.y && FlxG.mouse.screenY <= arrowRight.y + arrowRight.height;

        arrowLeft.alpha = currentPage == 1 ? (overLeft ? 1 : 0.6) : 0;
        arrowRight.alpha = currentPage == 0 ? (overRight ? 1 : 0.6) : 0;

        if ((FlxG.keys.justPressed.RIGHT || controls.RIGHT_P) && currentPage == 0)
            switchPage(1);

        if ((FlxG.keys.justPressed.LEFT || controls.LEFT_P) && currentPage == 1)
            switchPage(-1);

        if (FlxG.mouse.justPressed) {
            if (overRight) switchPage(1);
            else if (overLeft) switchPage(-1);
            else if (FlxG.mouse.overlaps(enterTxt) || FlxG.mouse.overlaps(currentPage == 0 ? titleLogo : rfLogo))
                mouseAccept = true;
        }
    }
    
    if(controls.SWITCHMOD){
        persistentUpdate = !(persistentDraw = true);
        openSubState(new ModSwitchMenu());
    }

    if ((FlxG.keys.justPressed.ENTER || mouseAccept) && !pageTransitioning)
    {
        transitioning = true;
        CoolUtil.playMenuSFX(1, 0.6);

        if (currentPage == 0)
        {
            FlxG.sound.play(Paths.sound("titleLaughSonicEXE"));
            FlxTween.cancelTweensOf(titleLogo);
            FlxTween.tween(titleLogo, {y: -1200}, 0.6, {ease: FlxEase.quintOut});
            FlxTween.tween(bgStatic,  {alpha: 1},  0.6, {ease: FlxEase.quintOut});
            FlxTween.tween(titleLogo.scale, {x: 0.2, y: 0.2}, 1.2, {
                ease: FlxEase.quintOut,
                onComplete: (_) -> new FlxTimer().start(1.5, (_) ->
                    FlxG.switchState(new MainMenuState())
                )
            });
        }
        else
        {
            rfEyes.alpha = 1;
            FlxG.camera.flash(FlxColor.RED, 0.7);
            FlxG.sound.play(Paths.sound("CFTitleLaugh"));
            FlxTween.tween(rfEyes.scale, {x: 0.2, y: 0.2}, 1.2,  {ease: FlxEase.quintOut});
            FlxTween.tween(rfLogo.scale, {x: 0.2, y: 0.2}, 1.2,  {ease: FlxEase.quintOut,
                onComplete: (_) -> new FlxTimer().start(4, (_) ->
                    FlxG.switchState(new GameState("XEternalDlcMenu"))
                )
            });
        }
    }
    
}


function checkDebugCombo()
{
    var upP     = FlxG.keys.justPressed.UP;
    var downP   = FlxG.keys.justPressed.DOWN;
    var leftP   = FlxG.keys.justPressed.LEFT;
    var rightP  = FlxG.keys.justPressed.RIGHT;
    var enterP  = FlxG.keys.justPressed.ENTER;

    var expected:Array<Bool> = [upP, downP, leftP, rightP, enterP];

    if (expected[comboProgress]) {
        comboProgress++;
        if (comboProgress >= expected.length) {
            unlockDebugMenu();
        }
    } else if (upP || downP || leftP || rightP || enterP) {
        comboProgress = 0;
    }
}

function unlockDebugMenu()
{
    debugUnlocked = true;
    comboProgress = 0;
    FlxG.sound.play(Paths.sound('pause'));
    bgStatic.visible = false;
    enterTxt.visible = false;
    titleLogo.color = 0x90482424;
    persistentUpdate = !(persistentDraw = true);
    openSubState(new GameSubState("XEternalDebugMenu"));
    arrowRight.visible = false;
}