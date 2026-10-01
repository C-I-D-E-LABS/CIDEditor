// Goal - made from the "Level Exit" template. It's your script now: change anything.
//
// When the player touches it: fades out and loads nextLevel (data/tilemaps/<nextLevel>.json) in
// place of this one - the player starts wherever it's placed in that map. Leave nextLevel empty
// to restart this level instead.

@export var sprite = "";               // a sprite from the sprite editor (eg. a door or flag)
@export var hitboxWidth = 16;          // without a sprite: a plain box this size and color
@export var hitboxHeight = 32;
@export var boxColor = 0xFFF0F0F0;
@export var nextLevel = "";           // tilemap name, eg. "level2"
@export var fade = true;

var used = false;

function create() {
	if (sprite == "" || !useSprite(sprite)) {
		makeGraphic(hitboxWidth, hitboxHeight, boxColor);
		setSize(hitboxWidth, hitboxHeight);
	}

	collidesWithMap = false;
	moves = false;
}

function update(elapsed) {
	if (used) return;
	var player = map.getPlayer();
	if (player != null && overlaps(player)) {
		used = true;
		map.changeLevel(nextLevel != "" ? nextLevel : map.name, fade);
	}
}
