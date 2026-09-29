// Coin - made from the "Collectible" template. It's your script now: change anything.
//
// Bobs up and down, and when the player touches it: calls the player's onCollect(this, value),
// then disappears. Runs as the entity itself, like a Godot script on its node.

@export var sprite = "";         // a sprite from the sprite editor - its first animation plays (eg. spinning)
@export var hitboxWidth = 10;    // without a sprite: a plain box this size and color
@export var hitboxHeight = 10;
@export var boxColor = 0xFFFFD040;
@export var value = 1;           // passed to the player's onCollect()
@export var bobHeight = 3;
@export var bobSpeed = 4;

var baseY = 0.0;
var time = 0.0;

function create() {
	if (sprite == "" || !useSprite(sprite)) {
		makeGraphic(hitboxWidth, hitboxHeight, boxColor);
		setSize(hitboxWidth, hitboxHeight);
	}

	collidesWithMap = false;  // floats in place
	baseY = y;
	time = x * 0.05;          // so a row of them doesn't bob in perfect sync
}

function update(elapsed) {
	//time += elapsed;
	//y = baseY + Math.sin(time * bobSpeed) * bobHeight;

	var player = map.getPlayer();
	if (player != null && overlaps(player)) {
		player.callScript("onCollect", [this, value]);
		kill();
	}
}
