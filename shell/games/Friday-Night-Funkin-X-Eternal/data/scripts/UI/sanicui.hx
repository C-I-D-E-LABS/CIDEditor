var sanicGun:FlxSprite;
var bandi:FlxSprite;

function create() {
	graphicCache.cache(Paths.image("game/sonicUI/sanic/sanicportalgun"));
	graphicCache.cache(Paths.image("game/sonicUI/sanic/bandi"));
}

function postCreate() {
	sanicGun = new FlxSprite(320, 250).loadGraphic(Paths.image("game/sonicUI/sanic/sanicportalgun"));
	sanicGun.camera = camHUD;
	sanicGun.scrollFactor.set();
	sanicGun.scale.set(0.75, 0.75);
	sanicGun.updateHitbox();
	sanicGun.antialiasing = true;
	insert(0, sanicGun);

	bandi = new FlxSprite().loadGraphic(Paths.image("game/sonicUI/sanic/bandi"));
	bandi.camera = camHUD;
	bandi.scrollFactor.set();
	bandi.antialiasing = true;
	add(bandi);

	for (txt in [scoreTxt, missesTxt, accuracyTxt]) {
		txt.x = 32;
		txt.y -= 8;
	}
}
