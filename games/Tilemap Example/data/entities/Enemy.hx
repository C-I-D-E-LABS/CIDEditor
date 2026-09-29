// Enemy - made from the "Patrolling Enemy" template. It's your script now: change anything.
//
// Walks back and forth, turning around at walls (and, if turnAtLedges, at the edge of a drop).
// Land on it from above and it's stomped (calls the player's onStomp); touch it any other way
// and it calls the player's onHurt. Runs as the entity itself, like a Godot script on its node.

@export var sprite = "";               // a sprite from the sprite editor - its first animation plays (make it the walk)
@export var hitboxWidth = 14;          // without a sprite: a plain box this size and color
@export var hitboxHeight = 12;
@export var boxColor = 0xFFC03030;
@export var walkSpeed = 40;
@export var gravity = 900;
@export var startDirection = -1;       // -1 = walks left first, 1 = right
@export var turnAtLedges = true;       // false = walks right off edges
@export var stompable = true;          // false = hurts even when landed on (spikes, fire...)

var direction = -1;

function create() {
	if (sprite == "" || !useSprite(sprite)) {
		makeGraphic(hitboxWidth, hitboxHeight, boxColor);
		setSize(hitboxWidth, hitboxHeight);
	}

	acceleration.y = gravity;
	maxVelocity.y = 600;
	direction = startDirection < 0 ? -1 : 1;
}

function update(elapsed) {
	velocity.x = walkSpeed * direction;
	flipX = direction > 0;   // art is expected to face left
}

function postUpdate(elapsed) {
	// turn around at walls...
	if (isOnWall()) {
		direction = -direction;
	} else if (turnAtLedges && isOnFloor()) {
		// ...and at ledges: no ground a few pixels ahead of the leading foot = about to walk off
		var aheadX = direction > 0 ? x + width + 1 : x - 1;
		var groundAhead = false;
		for (d in 1...6) if (map.isSolidAt(aheadX, y + height + d)) groundAhead = true;
		if (!groundAhead) direction = -direction;
	}

	var player = map.getPlayer();
	if (player != null && player.alive && overlaps(player)) {
		// A player script with onTouchEnemy(enemy) decides for itself (Sonic: rolling or jumping into
		// an enemy destroys it) - it returns true = destroyed, false = dealt with it.
		var result = player.callScript("onTouchEnemy", [this]);
		if (result == true) {
			kill();
		} else if (result == null) {
			// falling, with its feet in our top half = a stomp
			if (stompable && player.velocity.y > 0 && player.y + player.height <= y + height * 0.6) {
				player.callScript("onStomp", [this]);
				kill();
			} else {
				player.callScript("onHurt", [this]);
			}
		}
	}
}
