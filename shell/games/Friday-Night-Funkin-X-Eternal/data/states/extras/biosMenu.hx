import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.text.FlxTextBorderStyle;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import funkin.backend.assets.GamesFolder;
import flixel.addons.display.FlxBackdrop;

var bioKeys:Array<String> = [];
var currentIndex:Int = 0;
var bioData:Array<Dynamic> = [];
var bioSprites:Array<Array<Character>> = [];

var nameText:FlxText;
var titleText:FlxText;
var bioText:FlxText;
var arrowLeft:FlxText;
var arrowRight:FlxText;

function create() {

        stat = new FlxBackdrop(null, FlxAxes.XY, 0, 0);
	stat.frames = Paths.getSparrowAtlas('exe/tt-stage/x/Static');
	stat.animation.addByPrefix('skyAnim', 'Static', 12, true);
	stat.animation.play('skyAnim');
    stat.alpha = 0.7;
    stat.updateHitbox();
    add(stat);

      bg = new FlxBackdrop(Paths.image('block2'), FlxAxes.XY);
	bg.screenCenter();
	bg.scrollFactor.set(0, 0);
	bg.scale.set(2, 2);
	bg.velocity.set(100, 100);
    bg.alpha = 0.7;
	add(bg);

    blackBox = new FlxSprite(20, 30).makeGraphic(FlxG.width/2.1, FlxG.height - 60, FlxColor.BLACK);
    add(blackBox);
    blackBox.alpha = 0.5;

    loadBioList();

    nameText = new FlxText(60, 100, 500, "", 48);
    nameText.font = Paths.font('greenm03.ttf');
    nameText.color = FlxColor.WHITE;
    nameText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 3);
    add(nameText);

    titleText = new FlxText(60, 160, 500, "", 20);
    titleText.font = Paths.font('greenm03.ttf');
    titleText.color = FlxColor.WHITE;
    add(titleText);

    bioText = new FlxText(60, 220, 550, "", 20);
    bioText.font = Paths.font('greenm03.ttf');
    bioText.color = FlxColor.WHITE;
    add(bioText);

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

    if (bioKeys.length > 0) {
        var startIndex = bioKeys.indexOf("sonicexe");
        loadBio(startIndex < 0 ? 0 : startIndex);
    }
}

function loadBioList() {
    var dir:String  = 'games/' +  GamesFolder.currentModFolder + '/data/bios';

    if (!sys.FileSystem.exists(dir)) return;

    for (file in sys.FileSystem.readDirectory(dir)) {
        if (StringTools.endsWith(file, '.json')) {
            var path = dir + "/" + file;
            var key = file.substr(0, file.length - 5);
            var data:Dynamic = haxe.Json.parse(sys.io.File.getContent(path));

            bioKeys.push(key);
            bioData.push(data);

            var sprites:Array<Character> = [];
            var chars:Array<Dynamic> = data.characters != null ? data.characters : [
                {character: data.character, x: data.x, y: data.y, scale: data.scale, flipX: data.flipX},
                {character: data.character2, x: data.x2, y: data.y2, scale: data.scale2, flipX: data.flipX2}
            ];

            for (charData in chars) {
                var charName = charData.character != null ? charData.character : charData.name;
                if (charName == null) continue;

                var charSprite = new Character(charData.x != null ? charData.x : 0, charData.y != null ? charData.y : 0, charName);
                add(charSprite);
                charSprite.visible = false;
                charSprite.active = false;
                charSprite.flipX = charData.flipX != null ? charData.flipX : true;

                var scale:Float = charData.scale != null ? charData.scale : 1;
                charSprite.scale.set(scale, scale);
                sprites.push(charSprite);
            }

            bioSprites.push(sprites);
        }
    }
}

function loadBio(index:Int) {
    if (bioKeys.length == 0) return;

    var data:Dynamic = bioData[index];

    nameText.text = data.name;
    titleText.text = data.title != null ? data.title : "";
    bioText.text = data.bio;

    for (sprites in bioSprites)
        for (sprite in sprites) {
            sprite.visible = false;
            sprite.active = false;
        }

    for (sprite in bioSprites[index]) {
        sprite.visible = true;
        sprite.active = true;
    }

    currentIndex = index;

    nameText.x = -400;
    bioText.alpha = 0;

    FlxTween.tween(nameText, {x: 60}, 0.4, {ease: FlxEase.quartOut});
    FlxTween.tween(bioText, {alpha: 1}, 0.4, {startDelay: 0.1});
}

function update(elapsed:Float) {
    if (bioKeys.length == 0) return;

    var overLeft = FlxG.mouse.screenX < 140 && FlxG.mouse.screenY >= arrowLeft.y && FlxG.mouse.screenY <= arrowLeft.y + arrowLeft.height;
    var overRight = FlxG.mouse.screenX > FlxG.width - 140 && FlxG.mouse.screenY >= arrowRight.y && FlxG.mouse.screenY <= arrowRight.y + arrowRight.height;

    arrowLeft.alpha = overLeft ? 1 : 0.6;
    arrowRight.alpha = overRight ? 1 : 0.6;

    if (controls.LEFT_P || (overLeft && FlxG.mouse.justPressed)) {
        FlxG.sound.play(Paths.sound('menu/scroll'), 0.5);
        var newIndex = currentIndex - 1;
        if (newIndex < 0) newIndex = bioKeys.length - 1;
        loadBio(newIndex);
    }

    if (controls.RIGHT_P || (overRight && FlxG.mouse.justPressed)) {
        FlxG.sound.play(Paths.sound('menu/scroll'), 0.5);
        var newIndex = currentIndex + 1;
        if (newIndex >= bioKeys.length) newIndex = 0;
        loadBio(newIndex);
    }

    if (controls.BACK) {
        FlxG.switchState(new GameState("XEternalExtras"));
    }
}
