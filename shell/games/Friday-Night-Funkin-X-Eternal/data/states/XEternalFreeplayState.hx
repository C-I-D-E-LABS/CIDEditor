import flixel.addons.display.FlxBackdrop;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import funkin.menus.FreeplayState.FreeplaySonglist;

import StringTools;

var transitioning:Bool = false;
var fpSongs:FreeplaySonglist;

var songsByCharacter:Map<String, Array<String>> = [];
var characterOrder:Array<String> = [];
var largeList:Bool = false;
var curCharSelected:Int = 0;
var curSongSelected:Int = 0;
var currentPortraitPath:String = "";
var characterLocked:Array<Bool> = [];
var grpChars:FlxTypedGroup;
var grpSongs:FlxTypedGroup;

var crtShader = null;
var buzzTime:Float = 0;

var charTxt:FunkinText;
var arrowLeft:FlxText;
var arrowRight:FlxText;

var lockedMsgTxt:FunkinText;
var lockedMsgTimer:Float = 0;
var lockedMsgDuration:Float = 2.5;

// Songs added here are locked (Add the songs you want to lock to XEternalPlayState as well)
var soundtestGatedSongs:Array<String> = [ 
    "Endless",
    "Endless JP",
    "Endless US",
    "Endeavors",
    "Cycles",
    "Fate",
    "ILLEGAL INSTRUCTION",
    "Hellbent",
	"Prey",
	"Chaos",
	"Milk",
	"Personel",
	"Too Fest",
	"Sunshine",
    "Soulless"
];

function isSongUnlocked(songName:String):Bool {
    if (!soundtestGatedSongs.contains(songName)) return true;
    var unlocked:Array<Dynamic> = FlxG.save.data.unlockedSongs;
    if (unlocked == null) return false;
    return unlocked.contains(songName);
}

function getDisplaySongName(songName:String):String {
    if (isSongUnlocked(songName)) return songName;

    var result:String = "";
    for (i in 0...songName.length) {
        var c:String = songName.charAt(i);
        result += (c == " " ? " " : "?");
    }
    return result;
}

function create()
{    
    for (sound in ['menu/scroll', 'menu/denied', 'menu/confirmFreeplay'])
        FlxG.sound.cache(Paths.sound(sound));
    for (asset in ['block2', 'menus/freeplay/backgroundlool2', 'menus/freeplay/exeTv', 'menus/freeplay/fpstuff/locked'])
        graphicCache.cache(Paths.image(asset));

    crtShader = new CustomShader("vcrDistort");
    FlxG.camera.addShader(crtShader);
    crtShader.distortionOn = false;
    crtShader.scandistortOn = false;

    window.title = windowTitle + " - Freeplay";
    FlxG.mouse.visible = true;

    FlxG.sound.playMusic(Paths.music('menus/freeplay'), 0);
    FlxG.sound.music.fadeIn(5, 0, 0.5);

    bgSonic = new FlxSprite(0, 0, Paths.image('menus/freeplay/backgroundlool2'));
    bgSonic.antialiasing = false;
    bgSonic.screenCenter();
    bgSonic.setGraphicSize(FlxG.width, FlxG.height);
    add(bgSonic);

    bg = new FlxBackdrop(Paths.image('block2'), FlxAxes.XY);
	bg.screenCenter();
	bg.scrollFactor.set(0, 0);
	bg.scale.set(2, 2);
	bg.velocity.set(100, 100);
    bg.alpha = 0.7;
	add(bg);

    fpSongs = FreeplaySonglist.get();
    for (song in fpSongs.songs){
        if (song.name == "Eclipsera") continue;

        if (song.customValues != null && Reflect.hasField(song.customValues, 'character')) {

            var rawCharName:String = Std.string(song.customValues.character).toUpperCase();
            var songName:String = song.name;

            if (rawCharName == "UNLISTED") break;

            var charName:String = rawCharName;
            var charPortrait = Paths.image('menus/freeplay/fpstuff/' + rawCharName.toLowerCase());
            var songPortrait = Paths.image('menus/freeplay/fpstuff/' + StringTools.replace(songName.toUpperCase(), " ", " "));
            if (Assets.exists(charPortrait)) graphicCache.cache(charPortrait);
            if (Assets.exists(songPortrait)) graphicCache.cache(songPortrait);
            
            if (!songsByCharacter.exists(charName)) {
                characterOrder.push(charName);
                songsByCharacter.set(charName, [songName]);
            } else {
                songsByCharacter.get(charName).push(songName);
            }
        } else {
            var missingCharName:String = "locked";
            var songName:String = song.name;
            var songPortrait = Paths.image('menus/freeplay/fpstuff/' + StringTools.replace(songName.toUpperCase(), " ", " "));
            if (Assets.exists(songPortrait)) graphicCache.cache(songPortrait);

            if (!songsByCharacter.exists(missingCharName)) {
                characterOrder.push(missingCharName);
                songsByCharacter.set(missingCharName, [songName]);
            } else {
                songsByCharacter.get(missingCharName).push(songName);
            }
        }
    }

    characterLocked = [];
    for (charName in characterOrder) {
        var charSongs:Array<String> = songsByCharacter.get(charName);
        characterLocked.push(charSongs != null && charSongs.filter(s -> !isSongUnlocked(s)).length == charSongs.length);
    }

    grpSongs = new FlxTypedGroup();
    add(grpSongs);

    grpChars = new FlxTypedGroup();
    add(grpChars);
    for (i => charName in characterOrder){
        var portraitKey:String = characterLocked[i] ? 'locked' : charName.toLowerCase();
        var charPort:FreeplayBox = new FreeplayBox(0, 0, portraitKey);
        charPort.ID = i;
        grpChars.add(charPort);
        charPort.y = 185;
    }

    for (item in grpChars.members) {
        var spot = ((FlxG.width / 2) - (item.border.width / 2)) - (400 * (curCharSelected - item.ID));
        item.x = spot;
        item.alpha = (item.ID == curCharSelected ? 1 : 0.4);
        item.scale.x = item.scale.y = (item.ID == curCharSelected ? 0.7 : 0.6);
        item.buzzAmount = item.ID == curCharSelected ? 0 : 1;
        item.portrait.color = item.ID == curCharSelected ? 0xFFFFFFFF : 0xFF000000;
        item.portrait.shader = item.ID == curCharSelected ? null : item.buzz;
    }   
}

function postCreate(){
    lockedMsgTxt = new FunkinText(0, FlxG.height / 2 - 20, FlxG.width, "BEAT THIS SONG IN SOUND TEST FIRST!!!", 22);
    lockedMsgTxt.setFormat(Paths.font("sonic-cd-menu-font.ttf"), 22, FlxColor.RED, 'center');
    lockedMsgTxt.alpha = 0;
    lockedMsgTxt.scrollFactor.set(0, 0);
    lockedMsgTxt.setPosition(0, 100);
    add(lockedMsgTxt);

    charTxt = new FunkinText(0,0,FlxG.width,"Majin",36);
    charTxt.setFormat(Paths.font("sonic-1-title-card.ttf"), charTxt.size, FlxColor.WHITE, 'center');
    charTxt.y += 20;
    add(charTxt);

    arrowLeft = new FlxText(-600, FlxG.height - 80, FlxG.width, "<");
    arrowRight = new FlxText(0, FlxG.height - 80, FlxG.width, ">");
    for (arrow in [arrowLeft, arrowRight]) {
        arrow.setFormat(Paths.font("sonic3TitleCard"), 68, FlxColor.WHITE, "center");
        arrow.screenCenter(FlxAxes.Y);
        arrow.scrollFactor.set(0, 0);
        arrow.alpha = 0.6;
        add(arrow);
    }
    arrowRight.x = FlxG.width - arrowRight.width + 600;
    changeSelection(0);
}

function makeSongsList() {
    var songsArr:Array<String> = songsByCharacter.get(characterOrder[curCharSelected]);
    largeList = (songsArr.length > 6);
    for (i in 0...songsArr.length){
        var displayName:String = getDisplaySongName(songsArr[i]);

        songsTxt = new FunkinText(0, FlxG.height / 2 - 30 * songsArr.length + i * 20 * songsArr.length, FlxG.width, displayName, 25);
        
        var midPoint = (FlxG.height / 1.3) - (songsTxt.frameHeight / 2);
        songsTxt.y = (midPoint + (30 * i)) - (((songsTxt.frameHeight / 2) * ((songsArr.length - 1) - i)) / 2);

        songsTxt.setFormat(Paths.font("sonic-1-title-card.ttf"), songsTxt.size, FlxColor.WHITE, 'center');
        songsTxt.ID = i;
        songsTxt.alpha = 0.4;
        grpSongs.add(songsTxt);

        if (largeList) songsTxt.size = 18;
    }
}

var selectingSong:Bool = false;
var localTime:Float = 0;
function update(elapsed:Float) {
    localTime += elapsed;
    buzzTime += elapsed;
    if (crtShader != null) crtShader.iTime = localTime;

    FlxG.camera.scroll.x = FlxMath.lerp(FlxG.camera.scroll.x, (FlxG.mouse.screenX - FlxG.width / 2) * -0.02, FlxMath.bound(elapsed * 4, 0, 1));
    FlxG.camera.scroll.y = FlxMath.lerp(FlxG.camera.scroll.y, (FlxG.mouse.screenY - FlxG.height / 2) * -0.015, FlxMath.bound(elapsed * 4, 0, 1));

    if (lockedMsgTxt.alpha > 0) {
        lockedMsgTimer -= elapsed;
        if (lockedMsgTimer <= 0) {
            lockedMsgTxt.alpha = 0;
        } else {
            lockedMsgTxt.alpha = Math.min(1, lockedMsgTimer / 0.5);
        }
    }

    if (!transitioning && controls.BACK){
        if (selectingSong){
            selectingSong = false;

            for (item in grpSongs.members) item.alpha = 0.4;
        } else {
            if (!transitioning) {
                transitioning = true;
                FlxG.switchState(new MainMenuState());
            }
        }
    }

    var mouseAccept:Bool = false;
    var overLeft:Bool = !selectingSong && FlxG.mouse.screenX < 140 && FlxG.mouse.screenY >= arrowLeft.y && FlxG.mouse.screenY <= arrowLeft.y + arrowLeft.height;
    var overRight:Bool = !selectingSong && FlxG.mouse.screenX > FlxG.width - 140 && FlxG.mouse.screenY >= arrowRight.y && FlxG.mouse.screenY <= arrowRight.y + arrowRight.height;
    var pressedArrow:Bool = false;

    arrowLeft.visible = arrowRight.visible = !selectingSong;
    arrowLeft.alpha = overLeft ? 1 : 0.6;
    arrowRight.alpha = overRight ? 1 : 0.6;

    if (!transitioning && FlxG.mouse.justPressed) {
        if (overLeft) {
            pressedArrow = true;
            changeSelection(-1, true);
        } else if (overRight) {
            pressedArrow = true;
            changeSelection(1, true);
        }
    }

    if (!transitioning && selectingSong)
        for (item in grpSongs.members)
            if (item != null && FlxG.mouse.overlaps(item)) {
                if (item.ID != curSongSelected) changeSong(item.ID - curSongSelected, true);
                if (FlxG.mouse.justReleased) mouseAccept = true;
            }
    if (!transitioning && !selectingSong && !pressedArrow && FlxG.mouse.justPressed && FlxG.mouse.overlaps(grpChars.members[curCharSelected]))
        mouseAccept = true;

    if (!transitioning && (controls.ACCEPT || mouseAccept)){
        if (!selectingSong){
            if (characterLocked[curCharSelected]) {
                FlxG.sound.play(Paths.sound('menu/denied'), 0.6);
                FlxG.camera.shake(0.01, 0.15);
                lockedMsgTxt.alpha = 1;
                lockedMsgTimer = lockedMsgDuration;
                return;
            }

            selectingSong = true;
            for (item in grpSongs.members)
                item.alpha = (item.ID == curSongSelected ? 1 : 0.4);
        } else {
            var songsArr:Array<String> = songsByCharacter.get(characterOrder[curCharSelected]);
            var realSongName:String = songsArr[curSongSelected];

            if (!isSongUnlocked(realSongName)) {
                FlxG.sound.play(Paths.sound('menu/denied'), 0.6);
                FlxG.camera.shake(0.01, 0.15);
                lockedMsgTxt.alpha = 1;
                lockedMsgTimer = lockedMsgDuration;
                return;
            }

            transitioning = true;
            FlxTween.tween(FlxG.camera, {zoom: 1.5, alpha: 0}, 1.0);
            FlxTween.tween(FlxG.sound.music, {volume: 0}, 0.3);

            switch(realSongName) {
            case "Endless":
                FlxG.sound.play(Paths.sound('menu/confirmFreeplay'), 0.7); 
                FlxG.camera.flash(FlxColor.BLUE, 1);
                new FlxTimer().start(2.5, (_) -> FlxG.switchState(new GameState("XEternalMixesMenu")));
            default:
                FlxG.sound.play(Paths.sound('menu/confirmFreeplay'), 1.3); 
                FlxG.camera.flash(FlxColor.RED, 1);
                new FlxTimer().start(2.5, (_) -> { 
                    PlayState.loadSong(StringTools.replace(realSongName, ' ', ' '), "hard");
                    FlxG.switchState(new PlayState());
                });
            }
        }
        

    }

    if (transitioning) return;

    var shiftMult:Int = 1;
    if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

    if (selectingSong){
        if(controls.UP_P){
            changeSong(-shiftMult, true);
        } else if(controls.DOWN_P){
            changeSong(shiftMult, true);
        }
    
        if(FlxG.mouse.wheel != 0)
        {
            changeSong(-shiftMult * FlxG.mouse.wheel, false);
        }
    } else {
        if(controls.LEFT_P){
            changeSelection(-shiftMult, true);
        } else if(controls.RIGHT_P){
            changeSelection(shiftMult, true);
        }
    
        if(FlxG.mouse.wheel != 0)
        {
            changeSelection(-shiftMult * FlxG.mouse.wheel, false);
        }
    }
    
    for (item in grpChars.members) {
        var spot = ((FlxG.width / 2) - (item.border.width / 2)) - (400 * (curCharSelected - item.ID));
        var den = FlxMath.bound(elapsed * 6, 0, 1);
        item.x = FlxMath.lerp(item.x, spot, den);
        item.y = 185;
        var allLocked:Bool = characterLocked[item.ID];
        var targetAlpha:Float = (item.ID == curCharSelected && (!allLocked || selectingSong)) ? 1 : 0.4;
        var targetBuzz:Float = item.ID == curCharSelected ? 0 : 1;

        item.alpha = lerp(item.alpha, targetAlpha, den);
        item.scale.x = item.scale.y = lerp(item.scale.y, (item.ID == curCharSelected ? 0.6 : 0.5), den);
        item.buzzAmount = lerp(item.buzzAmount, targetBuzz, den);
        item.buzz.iTime = buzzTime;
        if (Math.abs(item.buzzAmount - item.lastBuzzAmount) > 0.01) {
            item.lastBuzzAmount = item.buzzAmount;
            item.buzz.color = [1, 1, 1, item.buzzAmount];
            item.portrait.color = FlxColor.fromRGB(
                Std.int(255 * (1 - item.buzzAmount)),
                Std.int(255 * (1 - item.buzzAmount)),
                Std.int(255 * (1 - item.buzzAmount))
            );
            item.portrait.shader = item.buzzAmount > 0.02 ? item.buzz : null;
        }
    }

}

function changeSelection(change:Int = 0, playSound:Bool = true)
{
    if (characterOrder.length == 0) return;

    if (playSound){
        FlxG.sound.play(Paths.sound('menu/scroll'),0.6);
    }

    curCharSelected += change;
    curCharSelected = FlxMath.wrap(curCharSelected, 0, characterOrder.length - 1);

    var selectedCharName = characterOrder[curCharSelected];
    var allLocked:Bool = characterLocked[curCharSelected];
    charTxt.text = "FREEPLAY:" + (allLocked ? 'LOCKED' :  selectedCharName.toUpperCase());

    for (item in grpSongs.members)
        if (item != null) item.destroy();
    grpSongs.clear();
    curSongSelected = 0;
    currentPortraitPath = "";
    selectingSong = false;

    makeSongsList();
    changeSong(0, false, false);
}

function changeSong(change:Int = 0, playSound:Bool = true, updateAlpha:Bool = true)
{
    var songsArr:Array<String> = songsByCharacter.get(characterOrder[curCharSelected]);
    if (songsArr.length == 0) return;

    if (playSound) FlxG.sound.play(Paths.sound('menu/scroll'),0.6);
    

    curSongSelected += change;
    curSongSelected = FlxMath.wrap(curSongSelected, 0, songsArr.length - 1);

    for (item in grpSongs.members){
        if (updateAlpha || selectingSong) item.alpha = (item.ID == curSongSelected ? 1 : 0.4);
        
        if (item.ID == curSongSelected){
            var realSongName:String = songsArr[curSongSelected];
            if (isSongUnlocked(realSongName)) {
                charTxt.text = characterOrder[curCharSelected].toUpperCase();
                var newGraphic = Paths.image('menus/freeplay/fpstuff/' + StringTools.replace(realSongName.toUpperCase(), " ", " "));
                if (Assets.exists(newGraphic)){
                    if (currentPortraitPath != newGraphic) {
                        currentPortraitPath = newGraphic;
                        grpChars.members[curCharSelected].portrait.loadGraphic(newGraphic);
                    }
                } else {
                    var fallbackGraphic = Paths.image('menus/freeplay/fpstuff/' + characterOrder[curCharSelected].toLowerCase());
                    if (currentPortraitPath != fallbackGraphic) {
                        currentPortraitPath = fallbackGraphic;
                        grpChars.members[curCharSelected].portrait.loadGraphic(fallbackGraphic);
                    }
                }
            } else {
                charTxt.text = 'LOCKED';
                var lockedGraphic = Paths.image('menus/freeplay/fpstuff/locked');
                if (currentPortraitPath != lockedGraphic) {
                    currentPortraitPath = lockedGraphic;
                    grpChars.members[curCharSelected].portrait.loadGraphic(lockedGraphic);
                }
            }
        }
    }
}

function destroy() {
    if (crtShader != null) {
        FlxG.camera.removeShader(crtShader);
        crtShader = null;
    }
}

class FreeplayBox extends funkin.backend.MusicBeatGroup {
    public var border:FlxSprite;
    public var portrait:FunkinSprite;
    public var buzz = null;
    public var buzzAmount:Float = 1;
    public var lastBuzzAmount:Float = -1;

    public function new(xx:Float, yy:Float, imgPath:String) {
            border = new FlxSprite(0, 0);
            border.frames = Paths.getSparrowAtlas('menus/freeplay/exeTv');
            border.animation.addByPrefix('idle', 'idle0', 24, true);
            border.animation.play('idle');
            border.antialiasing = false;

        var portraitPath = Paths.image('menus/freeplay/fpstuff/' + imgPath);
        portrait = new FunkinSprite(0, 0, portraitPath);
        buzz = new CustomShader("advancedStatic");
        buzz.iTime = 0;
        buzz.color = [1, 1, 1, buzzAmount];
        buzz.size = [3, 3];
        buzz.frameRate = 30;
        buzz.mixColors = true;
        portrait.shader = buzz;

        super(xx, yy, imgPath);

        add(portrait);
        add(border);

        for (stuff in [portrait, border]) {
            if (stuff.graphic != null) {
                stuff.setGraphicSize(Std.int(stuff.width / 1.7));
                stuff.updateHitbox();

            }
        }

        portrait.x = (border.width / 2) - (portrait.width / 2);
        portrait.y = (border.height / 2) - (portrait.height / 2);

    }

}

