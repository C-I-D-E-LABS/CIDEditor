// Checkpoint - made from the "Checkpoint" template. It's your script now: change anything.
//
// The first time the player touches it, the player's respawn point moves here - falling off the
// map or getting hurt (the Platformer Player template's onHurt) now brings them back here.

@export var sprite = "";               // a sprite from the sprite editor - give it an "active" animation to switch to
@export var hitboxWidth = 8;           // without a sprite: a plain box this size...
@export var hitboxHeight = 24;
@export var boxColor = 0xFF8090B0;     // ...this color before it's been reached...
@export var activeColor = 0xFF40E080;  // ...and this color after

var activated = false;

function create() {
	if (sprite == "" || !useSprite(sprite)) {
		makeGraphic(hitboxWidth, hitboxHeight, boxColor);
		setSize(hitboxWidth, hitboxHeight);
	}

	collidesWithMap = false;
	moves = false;
}

function update(elapsed) {
	if (activated) return;
	var player = map.getPlayer();
	if (player != null && overlaps(player)) {
		activated = true;
		// respawn standing on the same ground this stands on, centered on it
		player.spawnX = x + width / 2 - player.width / 2;
		player.spawnY = y + height - player.height;

		if (spriteData == null) makeGraphic(hitboxWidth, hitboxHeight, activeColor);
		else playAnim("active");
	}
}
