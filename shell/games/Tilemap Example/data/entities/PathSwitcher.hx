// PathSwitcher - made from the "Path Switcher" template. Change anything.
//
// Puts the player on collision path A or B as they pass through it, like the Sonic games
// plane switchers - how loops work: the loop has its two halves on layers marked A and B (the
// AB button next to each layer in the tilemap editor), and a switcher on each side of it flips
// the player over at the right moment. Invisible in the game (see showInGame).
//
// Works with a player script that has a `collisionPath` variable and uses map.sensors (like Sonic.hx).

@export var hitboxWidth = 16;
@export var hitboxHeight = 64;
@export var leftPath = 0;              // leaving it on its left side puts the player on this path (0 = A, 1 = B)
@export var rightPath = 1;             // ...and on its right side, this one
@export var groundOnly = false;        // only switch while the player is on the ground
@export var showInGame = false;

function create() {
	makeGraphic(hitboxWidth, hitboxHeight, 0x604080FF);
	setSize(hitboxWidth, hitboxHeight);
	visible = showInGame;
	collidesWithMap = false;
	moves = false;
}

function update(elapsed) {
	var player = map.getPlayer();
	if (player == null || !overlaps(player)) return;
	if (groundOnly && player.getVar("inAir") == true) return;
	// whichever side of the middle the player is on decides the path
	var side = player.x + player.width / 2 < x + width / 2 ? leftPath : rightPath;
	player.setVar("collisionPath", side);
}
