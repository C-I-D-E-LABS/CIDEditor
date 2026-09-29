// Player - made from the "Platformer Player" template. It's your script now: change anything.
//
// This script runs AS the entity (a FunkinSprite), like a Godot script attached to its node -
// x, y, velocity, acceleration, animation, loadGraphic(), flipX... are all right here. Also:
//   map         the TileMap this is in          controls    the player's controls
//   isOnFloor() isOnWall() isOnCeiling()        floorAngle()  ground angle in degrees
//   respawn()   back to the last checkpoint     collidesWithMap / alwaysActive / dropThrough
//
// Every frame: update() -> moves by velocity/acceleration -> pushed out of solid tiles and walked
// along slopes -> postUpdate().
//
// @export vars can be changed per placed copy in the tilemap editor (select it in the Entities tab).

@export var sprite = "";               // a sprite from the sprite editor (Explorer > Sprites): its art, animations and hitbox
@export var hitboxWidth = 12;          // without a sprite: a plain box this size...
@export var hitboxHeight = 22;
@export var boxColor = 0xFF3050E0;     // ...in this color

@export var runSpeed = 150;            // top speed, pixels per second
@export var runAccel = 1000;           // how fast it gets there
@export var friction = 1400;           // how fast it stops when you let go
@export var gravity = 900;
@export var maxFallSpeed = 600;
@export var jumpSpeed = 400;           // ~88px high with gravity 900
@export var jumpCutSpeed = 160;        // let go of jump early = upward speed cut to this (short hop)
@export var coyoteTime = 0.1;          // seconds you can still jump after running off a ledge
@export var jumpBufferTime = 0.12;     // seconds a jump pressed just before landing still counts
@export var dropThroughTime = 0.25;    // Down + jump on a one-way platform = fall through it for this long
@export var stompBounce = 300;         // how high you bounce off an enemy you land on
@export var hurtInvincibility = 1.0;   // seconds of flashing (can't be hurt again) after getting hit

var coyoteTimer = 0.0;
var jumpBufferTimer = 0.0;
var dropTimer = 0.0;
var invincibleTimer = 0.0;
var coins = 0;

function create() {
	// A sprite brings its own art, animations and hitbox (all set up in the sprite editor).
	// Without one, it's a plain box.
	if (sprite == "" || !useSprite(sprite)) {
		makeGraphic(hitboxWidth, hitboxHeight, boxColor);
		setSize(hitboxWidth, hitboxHeight);
	}

	maxVelocity.set(runSpeed, maxFallSpeed);
	drag.x = friction;
	acceleration.y = gravity;

	isPlayer = true;       // so enemies, coins, checkpoints and exits find this with map.getPlayer()
	alwaysActive = true;   // never falls asleep off screen - the camera's following it anyway
	FlxG.camera.follow(this);
	FlxG.camera.followLerp = 0.15;
	FlxG.camera.setScrollBoundsRect(map.x, map.y, map.worldWidth, map.worldHeight);
}

function update(elapsed) {
	// --- run ---
	acceleration.x = 0;
	if (controls.LEFT && !controls.RIGHT) acceleration.x = -runAccel;
	if (controls.RIGHT && !controls.LEFT) acceleration.x = runAccel;
	if (acceleration.x != 0) flipX = acceleration.x < 0;

	// --- jump (or, holding Down on a one-way platform, drop through it) ---
	if (isOnFloor()) coyoteTimer = coyoteTime;
	else coyoteTimer -= elapsed;
	if (jumpPressed()) jumpBufferTimer = jumpBufferTime;
	else jumpBufferTimer -= elapsed;

	if (jumpBufferTimer > 0 && coyoteTimer > 0) {
		jumpBufferTimer = 0;
		coyoteTimer = 0;
		// standing on nothing but one-way platforms (map.isOnFloor ignoring them says no)?
		if (controls.DOWN && isOnFloor() && !map.isOnFloor(this, true)) {
			dropThrough = true;
			dropTimer = dropThroughTime;
		} else {
			velocity.y = -jumpSpeed;
		}
	}
	if (!jumpHeld() && velocity.y < -jumpCutSpeed) velocity.y = -jumpCutSpeed;

	if (dropTimer > 0) {
		dropTimer -= elapsed;
		if (dropTimer <= 0) dropThrough = false;
	}

	// --- flashing after getting hurt ---
	if (invincibleTimer > 0) {
		invincibleTimer -= elapsed;
		visible = invincibleTimer <= 0 || Math.floor(invincibleTimer * 20) % 2 == 0;
	}

	// --- animation: name your sprite's animations these in the sprite editor and they just play.
	// (playAnim does nothing for an animation the sprite doesn't have, so these are safe without one.)
	if (!isOnFloor()) playAnim(velocity.y < 0 || !hasAnim("fall") ? "jump" : "fall");
	else if (Math.abs(velocity.x) > 10) playAnim("run");
	else playAnim("idle");
}

function postUpdate(elapsed) {
	// fell out of the level? back to the last checkpoint (or where it was placed)
	if (y > map.y + map.worldHeight + 64) respawn();
}

// Collectibles call this when you touch them.
function onCollect(item, value) {
	coins += value;
}

// Enemies call this when you land on them from above.
function onStomp(enemy) {
	velocity.y = -stompBounce;
}

// Enemies call this when they touch you any other way. Simplest version: back to the last
// checkpoint - swap in health, knockback, a death animation... whatever your game needs.
function onHurt(enemy) {
	if (invincibleTimer > 0) return;
	respawn();
	invincibleTimer = hurtInvincibility;
}

function jumpPressed() {
	return controls.ACCEPT || controls.UP_P || FlxG.keys.justPressed.SPACE;
}

function jumpHeld() {
	return controls.ACCEPT_HOLD || controls.UP || FlxG.keys.pressed.SPACE;
}

// ---------------------------------------------------------------------------------------------
// Taking it further:
//
//  Mario-ish:  add a run button (hold it for runSpeed * 1.6 and a higher jump); skid when you
//              turn around at speed; fall faster than you rise (acceleration.y = gravity * 1.6
//              while velocity.y > 0) for snappier jumps.
//
//  Sonic-ish:  keep momentum - much lower friction and a higher runSpeed; add speed going
//              downhill and lose it uphill using floorAngle() (degrees - eg.
//              velocity.x += Math.sin(floorAngle() * Math.PI / 180) * 600 * elapsed);
//              tilt the sprite to the ground with angle = floorAngle();
//              roll by shrinking the hitbox with setSize().
//
//  Want total control? Set collidesWithMap = false and move yourself with map.overlapsAt(this, x, y)
//  and map.isSolidAt(x, y) checks.
// ---------------------------------------------------------------------------------------------
