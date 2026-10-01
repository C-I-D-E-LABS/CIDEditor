// Sonic - a port of Sonic 2's player object (Obj01) from the disassembly, routine by routine.
//
// Every function named like Sonic_Move / AnglePos / Sonic_DoLevelCollision is the routine of the
// same name in the Sonic 2 disassembly (s2.asm), doing the same steps in the same order, so you can
// read the two side by side. The Sonic Physics Guide (info.sonicretro.org/Sonic_Physics_Guide)
// explains the same things in plain English, using the same names for speeds (gsp/xsp/ysp).
//
// How it differs from the other entities: it does its own collision like the Mega Drive did - no
// hitbox pushing, but "sensors" (map.sensors) that measure how far the floor, walls and ceiling
// are, plus the ground angle, which is what lets it run up walls and round loops. The Entity's own
// movement and collision are switched off (moves = false, collidesWithMap = false).
//
// NUMBERS: all speeds are in SUBPIXELS PER FRAME, like the original: 256 = 1 pixel per frame at
// 60fps. So a top speed of 0x600 is 6 pixels per frame (= 360 px/s). Positions are kept in
// subpixels too (xPos >> 8 = the pixel). The game runs at a fixed 60 ticks per second whatever the
// frame rate is, like the Mega Drive - see update().
//
// ANGLES are hex angles: 0-255 for a full turn, clockwise - 0x00 floor, 0x40 left wall,
// 0x80 ceiling, 0xC0 right wall, 0xE0 = a slope going up to the right ( / ). See HexMath.
//
// Animations it plays (give your sprite whichever of these you have - missing ones fall back):
//   idle walk run roll roll2 spindash skid push lookUp duck balance hurt death
//   (lookUp falls back to "up", duck to "down", roll to "jump")
//
// Loops: put the loop's two halves on collision layers A and B (the AB button next to a layer in the
// tilemap editor) and place Path Switcher entities where Sonic should swap - see collisionPath below.

import cide.physics.HexMath;
import openfl.utils.Assets;

@export var sprite = "sonic";          // a sprite from the sprite editor (Explorer > Sprites)
@export var spindash = true;           // Sonic 2's spin dash (Down + jump while standing still)
@export var smoothRotation = false;    // false = tilt in 45 degree steps like the original sprites; true = any angle
@export var classicCamera = true;      // the original's camera (the 16px dead zone, look up/down, spin dash lag); false = FlxCamera follow
@export var ringsProtect = true;       // like rings: hurt with coins = lose them all and get knocked back, hurt with none = die

// -------------------------------------------------------------------------------------------------
// Constants - the values from the disassembly (subpixels per frame; 256 = 1 px/frame)
// -------------------------------------------------------------------------------------------------

var ACCELERATION = 0x0C;       // Sonic_acceleration   0.046875  - also the ground friction
var DECELERATION = 0x80;       // Sonic_deceleration   0.5       - pressing against your movement
var TOP_SPEED = 0x600;         // Sonic_top_speed      6         - fastest you can RUN (slopes/rolling go faster)
var GRAVITY = 0x38;            // ObjectMoveAndFall    0.21875
var JUMP_FORCE = 0x680;        // Sonic_Jump           6.5
var JUMP_RELEASE = -0x400;     // Sonic_JumpHeight     let go of jump while rising faster than 4 = cut to 4
var MAX_UP_SPEED = -0xFC0;     // Sonic_UpVelCap       15.75 (only when not from a jump)
var SLOPE_FACTOR = 0x20;       // Sonic_SlopeResist    0.125
var ROLL_SLOPE_DOWN = 0x50;    // Sonic_RollRepel      0.3125 rolling downhill...
var ROLL_DECELERATION = 0x20;  // Sonic_RollSpeed      0.125  pressing against a roll (plus friction)
var ROLL_MAX_X = 0x1000;       // Sonic_SetRollSpeeds  16 - rolling x speed cap
var FALL_OFF_SPEED = 0x280;    // Sonic_SlopeRepel     2.5 - slower than this on a wall/ceiling = fall off
var HURT_GRAVITY = 0x30;       // Obj01_Hurt
var SPINDASH_SPEEDS = [0x800, 0x880, 0x900, 0x980, 0xA00, 0xA80, 0xB00, 0xB80, 0xC00];

// radii: Sonic's position is his CENTER; sensors sit this far out from it
var STAND_WIDTH = 9;           // x_radius
var STAND_HEIGHT = 19;         // y_radius ($13)
var ROLL_WIDTH = 7;
var ROLL_HEIGHT = 14;          // ($E) - rolling/jumping moves the center down 5 so the feet stay put

// sensor directions (SensorCollider)
var SENSE_DOWN = 0;
var SENSE_RIGHT = 1;
var SENSE_UP = 2;
var SENSE_LEFT = 3;
var NO_ANGLE = -1;

// -------------------------------------------------------------------------------------------------
// State - the object's RAM (names from the disassembly in brackets)
// -------------------------------------------------------------------------------------------------

var xPos = 0;                  // [x_pos] in subpixels, center
var yPos = 0;                  // [y_pos]
var xSpeed = 0;                // [x_vel]   xsp
var ySpeed = 0;                // [y_vel]   ysp
var groundSpeed = 0;           // [inertia] gsp - speed along the ground
var groundAngle = 0;           // [angle]   hex
var widthRadius = STAND_WIDTH; // [x_radius]
var heightRadius = STAND_HEIGHT; // [y_radius]

var facingLeft = false;        // [status bit 0]
var inAir = false;             // [status bit 1]
var inBall = false;            // [status bit 2] rolling or jumping
var rollJumping = false;       // [status bit 4] jumped out of a roll - no air control
var pushing = false;           // [status bit 5]
var jumping = false;           // [jumping]  in a jump (variable jump height applies)
var moveLock = 0;              // [move_lock] frames left/right are ignored (after slipping off a wall)
var spindashing = false;       // [spindash_flag]
var spindashCounter = 0;       // [spindash_counter]
var lookDelay = 0;             // [Sonic_Look_delay_counter]
var invulnerable = 0;          // [invulnerable_time]
var routine = "control";       // [routine] "control", "hurt" or "dead"
var sonicAnim = "idle";        // [anim]
var collisionPath = 0;         // 0 = path A, 1 = path B - Path Switcher entities change it (for loops)

var coins = 0;

// sensor results
var hitDist = 0;
var hitOther = 0;
var hitAngle = 0;
var primaryAngle = NO_ANGLE;   // the angles the last pair() of sensors found (NO_ANGLE = nothing there)
var secondaryAngle = NO_ANGLE;
var rightFootAngle = NO_ANGLE; // [next_tilt] what the right foot found in the last AnglePos (for balancing)
var leftFootAngle = NO_ANGLE;  // [tilt]      the left foot

// input for this tick
var inLeft = false;
var inRight = false;
var inUp = false;
var inDown = false;
var inJumpPress = false;
var inJumpHeld = false;
var jumpPressLatch = false;

// fixed 60Hz timing
var TICK = 1 / 60;
var tickTime = 0.0;

// camera
var camX = 0;
var camY = 0;
var viewW = 320;
var viewH = 224;
var cameraBias = 96;           // [Camera_Y_pos_bias] where on screen (y) the camera keeps Sonic
var defaultBias = 96;
var scrollDelay = 0;           // [Horiz_scroll_delay_val] spin dash camera lag
var xHistory = [];             // [Sonic_Pos_Record_Buf]

var shownAnim = null;

// -------------------------------------------------------------------------------------------------
// Setup
// -------------------------------------------------------------------------------------------------

function create() {
	if (sprite == "" || !useSprite(sprite)) {
		makeGraphic(STAND_WIDTH * 2 + 1, STAND_HEIGHT * 2 + 1, 0xFF3050E0);
		setSize(STAND_WIDTH * 2 + 1, STAND_HEIGHT * 2 + 1);
	}
	moves = false;             // the Entity doesn't move us...
	collidesWithMap = false;   // ...or push us out of tiles - the routines below do all of it
	isPlayer = true;
	alwaysActive = true;

	// The editor places the sprite's hitbox; stand Sonic on the bottom of it, centered.
	var feet = Math.floor(y + height);
	xPos = Math.floor(x + width / 2) << 8;
	yPos = (feet - STAND_HEIGHT - 1) << 8;

	// From here on the Entity's box is the box enemies and pickups touch: the sprite's hitbox width,
	// from Sonic's head (standing) down to his feet. Kept this size even while rolling, so
	// checkpoints/respawning always know where his feet go.
	var boxWidth = spriteData != null ? spriteData.hitboxWidth : 16;
	setSize(boxWidth, STAND_HEIGHT * 2 - 2);
	syncEntity();
	spawnX = x;
	spawnY = y;

	initCamera();
}

function onRespawn() {
	// Entity.respawn() put the box back at the spawn point / last checkpoint - stand Sonic in it
	var feet = Math.floor(y + height);
	xPos = Math.floor(x + width / 2) << 8;
	yPos = (feet - STAND_HEIGHT - 1) << 8;
	xSpeed = 0;
	ySpeed = 0;
	groundSpeed = 0;
	groundAngle = 0;
	widthRadius = STAND_WIDTH;
	heightRadius = STAND_HEIGHT;
	inAir = true;              // lands on whatever is under him next tick
	inBall = false;
	rollJumping = false;
	pushing = false;
	jumping = false;
	spindashing = false;
	moveLock = 0;
	invulnerable = 0;
	routine = "control";
	sonicAnim = "walk";
	scrollDelay = 0;
	xHistory = [];
	syncEntity();
	initCamera();
}

// -------------------------------------------------------------------------------------------------
// Main loop
// -------------------------------------------------------------------------------------------------

function update(elapsed) {
	// A press is remembered until the next tick runs, so it's never lost between ticks (or used twice).
	if (jumpJustPressed()) jumpPressLatch = true;

	// The Mega Drive ran the game exactly 60 times a second - so do we, however fast the screen
	// refreshes. (Capped so a long hitch doesn't make it run a burst of catch-up ticks.)
	tickTime += elapsed;
	if (tickTime > TICK * 4) tickTime = TICK * 4;
	while (tickTime >= TICK) {
		tickTime -= TICK;
		readInput();
		jumpPressLatch = false;
		tick();
	}
}

/** One frame of the original game. **/
function tick() {
	if (map.sensors == null) return;
	map.sensors.path = collisionPath;

	switch (routine) {
		case "control": Obj01_Control();
		case "hurt": Obj01_Hurt();
		case "dead": Obj01_Dead();
	}
	Sonic_RecordPos();
	Sonic_Animate();
	if (routine != "dead") ScrollCamera();
	syncEntity();
}

function Obj01_Control() {
	// the four modes, picked by the in-air and in-ball status bits
	if (inAir) Obj01_MdAir();            // MdAir and MdJump are the same routine
	else if (inBall) Obj01_MdRoll();
	else Obj01_MdNormal();

	if (invulnerable > 0) invulnerable--;
}

function Obj01_MdNormal() {
	if (spindash && Sonic_CheckSpindash()) return;
	if (Sonic_Jump()) return;
	Sonic_SlopeResist();
	Sonic_Move();
	Sonic_Roll();
	Sonic_LevelBound();
	ObjectMove();
	AnglePos();
	Sonic_SlopeRepel();
}

function Obj01_MdRoll() {
	if (Sonic_Jump()) return;
	Sonic_RollRepel();
	Sonic_RollSpeed();
	Sonic_LevelBound();
	ObjectMove();
	AnglePos();
	Sonic_SlopeRepel();
}

function Obj01_MdAir() {
	Sonic_JumpHeight();
	Sonic_ChgJumpDir();
	Sonic_LevelBound();
	ObjectMoveAndFall();
	Sonic_JumpAngle();
	Sonic_DoLevelCollision();
}

// -------------------------------------------------------------------------------------------------
// On the ground
// -------------------------------------------------------------------------------------------------

/** Walking / running: left, right, friction, then turn groundSpeed into x/y speed along the slope. **/
function Sonic_Move() {
	if (moveLock == 0) {
		if (inLeft) Sonic_MoveLeft();
		if (inRight) Sonic_MoveRight();

		// standing still on the floor: idle, balance on a ledge, look up, duck
		if (((groundAngle + 0x20) & 0xC0) == 0 && groundSpeed == 0) {
			pushing = false;
			sonicAnim = "idle";
			if (Sonic_Balance()) {
				Obj01_ResetScr();
			} else if (inUp) {
				sonicAnim = "lookUp";
				lookDelay++;
				if (lookDelay < 120) {
					resetCameraBias();
				} else {
					lookDelay = 120;
					if (cameraBias < defaultBias + 104) cameraBias += 2;
				}
			} else if (inDown) {
				sonicAnim = "duck";
				lookDelay++;
				if (lookDelay < 120) {
					resetCameraBias();
				} else {
					lookDelay = 120;
					if (cameraBias > defaultBias - 88) cameraBias -= 2;
				}
			} else {
				Obj01_ResetScr();
			}
		} else {
			Obj01_ResetScr();
		}
	} else {
		Obj01_ResetScr();
	}

	// Obj01_UpdateSpeedOnGround: friction (same as acceleration) when not pressing left/right
	if (!inLeft && !inRight && groundSpeed != 0) {
		if (groundSpeed > 0) {
			groundSpeed -= ACCELERATION;
			if (groundSpeed < 0) groundSpeed = 0;
		} else {
			groundSpeed += ACCELERATION;
			if (groundSpeed > 0) groundSpeed = 0;
		}
	}

	// Obj01_Traction
	xSpeed = (groundSpeed * HexMath.cos(groundAngle)) >> 8;
	ySpeed = (groundSpeed * HexMath.sin(groundAngle)) >> 8;
	Obj01_CheckWallsOnGround();
}

function Sonic_MoveLeft() {
	var speed = groundSpeed;
	if (speed > 0) {
		// Sonic_TurnLeft: braking. Crossing zero sets -0.5 straight away (the original's quirk).
		speed -= DECELERATION;
		if (speed < 0) speed = -0x80;
		groundSpeed = speed;
		if (((groundAngle + 0x20) & 0xC0) == 0 && speed >= 0x400) {
			sonicAnim = "skid";
			facingLeft = false;
			sfx("skid");
		}
		return;
	}
	if (!facingLeft) {
		facingLeft = true;
		pushing = false;
	}
	// Accelerate - but never slow down just because you're over top speed (downhill, etc.)
	speed -= ACCELERATION;
	if (speed <= -TOP_SPEED) {
		speed += ACCELERATION;
		if (speed > -TOP_SPEED) speed = -TOP_SPEED;
	}
	groundSpeed = speed;
	sonicAnim = "walk";
}

function Sonic_MoveRight() {
	var speed = groundSpeed;
	if (speed < 0) {
		// Sonic_TurnRight
		speed += DECELERATION;
		if (speed >= 0) speed = 0x80;
		groundSpeed = speed;
		if (((groundAngle + 0x20) & 0xC0) == 0 && speed <= -0x400) {
			sonicAnim = "skid";
			facingLeft = true;
			sfx("skid");
		}
		return;
	}
	if (facingLeft) {
		facingLeft = false;
		pushing = false;
	}
	speed += ACCELERATION;
	if (speed >= TOP_SPEED) {
		speed -= ACCELERATION;
		if (speed < TOP_SPEED) speed = TOP_SPEED;
	}
	groundSpeed = speed;
	sonicAnim = "walk";
}

/** Standing still with a foot over a ledge? (Sonic_Balance) Returns true if balancing. **/
function Sonic_Balance() {
	// ChkFloorEdge: is there floor under the CENTER within 12px? then not balancing
	var centerDist = castOne(xPos >> 8, (yPos >> 8) + heightRadius, SENSE_DOWN, 0);
	if (centerDist < 12) return false;
	var edgeOnRight = rightFootAngle == NO_ANGLE;
	var edgeOnLeft = leftFootAngle == NO_ANGLE;
	if (!edgeOnRight && !edgeOnLeft) return false;
	// facing the drop = teetering over it; facing away = the other balance pose
	sonicAnim = (edgeOnRight != facingLeft) ? "balance" : "balance2";
	return true;
}

/** Gravity along slopes while walking: slows you going up, speeds you up going down. **/
function Sonic_SlopeResist() {
	if (((groundAngle + 0x60) & 0xFF) >= 0xC0) return;   // on a ceiling: no effect
	var force = (HexMath.sin(groundAngle) * SLOPE_FACTOR) >> 8;
	if (groundSpeed != 0) {
		groundSpeed += force;
	} else if (iabs(force) >= 0x0D) {
		// standing still: only very steep slopes start you sliding
		groundSpeed += force;
	}
}

/** Too slow on a wall or ceiling? Fall off, and ignore left/right for 30 frames. **/
function Sonic_SlopeRepel() {
	if (moveLock > 0) {
		moveLock--;
		return;
	}
	if (((groundAngle + 0x20) & 0xC0) == 0) return;      // on the floor: fine
	if (iabs(groundSpeed) >= FALL_OFF_SPEED) return;
	groundSpeed = 0;
	inAir = true;
	moveLock = 30;
}

/** Down while moving = roll. **/
function Sonic_Roll() {
	if (iabs(groundSpeed) < 0x80) return;
	if (inLeft || inRight) return;
	if (!inDown) return;
	if (inBall) return;
	inBall = true;
	widthRadius = ROLL_WIDTH;
	heightRadius = ROLL_HEIGHT;
	sonicAnim = "roll";
	yPos += 5 << 8;             // smaller radius, same feet
	sfx("roll");
	if (groundSpeed == 0) groundSpeed = 0x200;
}

/** Rolling: slopes pull harder downhill than they slow you uphill. **/
function Sonic_RollRepel() {
	if (((groundAngle + 0x60) & 0xFF) >= 0xC0) return;
	var force = (HexMath.sin(groundAngle) * ROLL_SLOPE_DOWN) >> 8;
	if (groundSpeed >= 0) {
		if (force < 0) force = force >> 2;   // uphill: a quarter
	} else {
		if (force >= 0) force = force >> 2;
	}
	groundSpeed += force;
}

/** Rolling: you can only brake, not accelerate; friction is half; stop and you stand up. **/
function Sonic_RollSpeed() {
	var friction = ACCELERATION >> 1;
	if (moveLock == 0) {
		if (inLeft) {
			if (groundSpeed > 0) {
				groundSpeed -= ROLL_DECELERATION;
				if (groundSpeed < 0) groundSpeed = -0x80;
			} else {
				facingLeft = true;
				sonicAnim = "roll";
			}
		}
		if (inRight) {
			if (groundSpeed < 0) {
				groundSpeed += ROLL_DECELERATION;
				if (groundSpeed >= 0) groundSpeed = 0x80;
			} else {
				facingLeft = false;
				sonicAnim = "roll";
			}
		}
	}
	// Sonic_ApplyRollSpeed: friction, always
	if (groundSpeed > 0) {
		groundSpeed -= friction;
		if (groundSpeed < 0) groundSpeed = 0;
	} else if (groundSpeed < 0) {
		groundSpeed += friction;
		if (groundSpeed > 0) groundSpeed = 0;
	}
	// Sonic_CheckRollStop
	if (groundSpeed == 0) {
		inBall = false;
		widthRadius = STAND_WIDTH;
		heightRadius = STAND_HEIGHT;
		sonicAnim = "idle";
		yPos -= 5 << 8;
	}
	resetCameraBias();

	// Sonic_SetRollSpeeds
	ySpeed = (groundSpeed * HexMath.sin(groundAngle)) >> 8;
	xSpeed = (groundSpeed * HexMath.cos(groundAngle)) >> 8;
	if (xSpeed > ROLL_MAX_X) xSpeed = ROLL_MAX_X;
	if (xSpeed < -ROLL_MAX_X) xSpeed = -ROLL_MAX_X;
	Obj01_CheckWallsOnGround();
}

/** Spin dash: duck, press jump to rev (up to 4 times' worth), let go of Down to launch. Returns true if it used up this frame. **/
function Sonic_CheckSpindash() {
	if (!spindashing) {
		if (sonicAnim != "duck" || !inJumpPress) return false;
		sonicAnim = "spindash";
		shownAnim = null;       // restart the animation
		sfx("spindash");
		spindashing = true;
		spindashCounter = 0;
		Sonic_LevelBound();
		AnglePos();
		return true;
	}

	if (inDown) {
		// Sonic_ChargingSpindash: the rev slowly wears off...
		if (spindashCounter != 0) {
			spindashCounter -= spindashCounter >> 5;
			if (spindashCounter < 0) spindashCounter = 0;
		}
		// ...each press adds more
		if (inJumpPress) {
			sonicAnim = "spindash";
			shownAnim = null;
			sfx("spindash");
			spindashCounter += 0x200;
			if (spindashCounter > 0x800) spindashCounter = 0x800;
		}
	} else {
		// released: go!
		widthRadius = ROLL_WIDTH;
		heightRadius = ROLL_HEIGHT;
		sonicAnim = "roll";
		yPos += 5 << 8;
		spindashing = false;
		groundSpeed = SPINDASH_SPEEDS[spindashCounter >> 8];
		// the camera lags behind for a moment, more the faster you launch
		scrollDelay = 0x2000 - (((groundSpeed - 0x800) * 2) & 0x1F00);
		if (facingLeft) groundSpeed = -groundSpeed;
		inBall = true;
		sfx("release");
	}
	resetCameraBias();
	Sonic_LevelBound();
	AnglePos();
	return true;
}

/** Jump - straight out from the ground, whatever its angle. Returns true if it jumped (the rest of the frame is skipped). **/
function Sonic_Jump() {
	if (!inJumpPress) return false;
	if (CalcRoomOverHead((groundAngle + 0x80) & 0xFF) < 6) return false;   // ceiling right above: can't
	var launchAngle = (groundAngle - 0x40) & 0xFF;
	xSpeed += (JUMP_FORCE * HexMath.cos(launchAngle)) >> 8;
	ySpeed += (JUMP_FORCE * HexMath.sin(launchAngle)) >> 8;
	inAir = true;
	pushing = false;
	jumping = true;
	sfx("jump");
	widthRadius = STAND_WIDTH;
	heightRadius = STAND_HEIGHT;
	if (inBall) {
		// jumping out of a roll: keeps the standing radius (the original does too) and no air control
		rollJumping = true;
	} else {
		widthRadius = ROLL_WIDTH;
		heightRadius = ROLL_HEIGHT;
		sonicAnim = "roll";
		inBall = true;
		yPos += 5 << 8;
	}
	return true;
}

// -------------------------------------------------------------------------------------------------
// In the air
// -------------------------------------------------------------------------------------------------

/** Variable jump height: let go of jump early and upward speed is cut to 4. **/
function Sonic_JumpHeight() {
	if (jumping) {
		if (ySpeed < JUMP_RELEASE && !inJumpHeld) ySpeed = JUMP_RELEASE;
	} else if (ySpeed < MAX_UP_SPEED) {
		ySpeed = MAX_UP_SPEED;   // Sonic_UpVelCap
	}
}

/** Air control (twice ground acceleration, keeps speed over the top), and air drag near the top of a jump. **/
function Sonic_ChgJumpDir() {
	if (!rollJumping) {
		var airAccel = ACCELERATION * 2;
		var speed = xSpeed;
		if (inLeft) {
			facingLeft = true;
			speed -= airAccel;
			if (speed <= -TOP_SPEED) {
				speed += airAccel;
				if (speed > -TOP_SPEED) speed = -TOP_SPEED;
			}
		}
		if (inRight) {
			facingLeft = false;
			speed += airAccel;
			if (speed >= TOP_SPEED) {
				speed -= airAccel;
				if (speed < TOP_SPEED) speed = TOP_SPEED;
			}
		}
		xSpeed = speed;
	}
	resetCameraBias();   // Obj01_Jump_ResetScr

	// Sonic_JumpPeakDecelerate: air drag while moving up slower than 4
	if (ySpeed < 0 && ySpeed >= -0x400) {
		var drag = xSpeed >> 5;
		if (drag != 0) {
			if (xSpeed > 0) {
				xSpeed -= drag;
				if (xSpeed < 0) xSpeed = 0;
			} else {
				xSpeed -= drag;
				if (xSpeed > 0) xSpeed = 0;
			}
		}
	}
}

/** In the air the angle eases back to upright, 2 per frame. **/
function Sonic_JumpAngle() {
	var a = groundAngle;
	if (a == 0) return;
	if (a >= 0x80) {
		a += 2;
		if (a > 0xFF) a = 0;
	} else {
		a -= 2;
		if (a < 0) a = 0;
	}
	groundAngle = a;
}

/**
 * Air collision. Which sensors get checked depends on which way Sonic is moving (mostly down /
 * left / up / right), and landing converts his air speed into ground speed depending on how
 * steep the ground he lands on is.
 */
function Sonic_DoLevelCollision() {
	var moveDir = (HexMath.atan2(xSpeed, ySpeed) - 0x20) & 0xC0;

	if (moveDir == 0x40) {
		// Sonic_HitLeftWall - moving mostly left
		if (CheckLeftWallDist() < 0) {
			xPos -= hitDist << 8;
			xSpeed = 0;
			groundSpeed = ySpeed;
			return;
		}
		Sonic_HitCeilingOrFloor();
		return;
	}
	if (moveDir == 0xC0) {
		// Sonic_HitRightWall - moving mostly right
		if (CheckRightWallDist() < 0) {
			xPos += hitDist << 8;
			xSpeed = 0;
			groundSpeed = ySpeed;
			return;
		}
		Sonic_HitCeilingOrFloor();
		return;
	}

	// walls first either way
	if (CheckLeftWallDist() < 0) {
		xPos -= hitDist << 8;
		xSpeed = 0;
	}
	if (CheckRightWallDist() < 0) {
		xPos += hitDist << 8;
		xSpeed = 0;
	}

	if (moveDir == 0x80) {
		// Sonic_HitCeilingAndWalls - moving mostly up
		if (Sonic_CheckCeiling() >= 0) return;
		yPos -= hitDist << 8;
		if ((((hitAngle + 0x20) & 0xFF) & 0x40) != 0) {
			// a steep enough ceiling to run on: land on it
			groundAngle = hitAngle;
			Sonic_ResetOnFloor();
			groundSpeed = hitAngle >= 0x80 ? -ySpeed : ySpeed;
		} else {
			ySpeed = 0;   // bonk
		}
		return;
	}

	// moving mostly down
	if (Sonic_CheckFloor() >= 0) return;
	// only land if the floor isn't further in than we're falling this frame
	var landDepth = -((ySpeed >> 8) + 8);
	if (hitDist < landDepth && hitOther < landDepth) return;
	yPos += hitDist << 8;
	groundAngle = hitAngle;
	Sonic_ResetOnFloor();
	if ((((hitAngle + 0x20) & 0xFF) & 0x40) != 0) {
		// steep (46-90 degrees): all the falling speed becomes ground speed
		xSpeed = 0;
		if (ySpeed > 0xFC0) ySpeed = 0xFC0;
		groundSpeed = hitAngle >= 0x80 ? -ySpeed : ySpeed;
	} else if ((((hitAngle + 0x10) & 0xFF) & 0x20) != 0) {
		// slope (23-45 degrees): half the falling speed
		ySpeed = ySpeed >> 1;
		groundSpeed = hitAngle >= 0x80 ? -ySpeed : ySpeed;
	} else {
		// flat (0-22 degrees): keep the horizontal speed
		ySpeed = 0;
		groundSpeed = xSpeed;
	}
}

/** Sonic_HitCeiling -> Sonic_HitFloor: moving mostly sideways and didn't hit a wall. **/
function Sonic_HitCeilingOrFloor() {
	if (Sonic_CheckCeiling() < 0) {
		yPos -= hitDist << 8;
		if (ySpeed < 0) ySpeed = 0;
		return;
	}
	if (ySpeed < 0) return;
	if (Sonic_CheckFloor() < 0) {
		yPos += hitDist << 8;
		groundAngle = hitAngle;
		Sonic_ResetOnFloor();
		ySpeed = 0;
		groundSpeed = xSpeed;
	}
}

/** Landed: back to standing radius (if he was in a ball), clear the air flags. **/
function Sonic_ResetOnFloor() {
	sonicAnim = "walk";
	if (inBall) {
		inBall = false;
		widthRadius = STAND_WIDTH;
		heightRadius = STAND_HEIGHT;
		yPos -= 5 << 8;
	}
	inAir = false;
	pushing = false;
	rollJumping = false;
	jumping = false;
	lookDelay = 0;
}

// -------------------------------------------------------------------------------------------------
// Moving + ground collision
// -------------------------------------------------------------------------------------------------

function ObjectMove() {
	xPos += xSpeed;
	yPos += ySpeed;
}

/** Move, THEN add gravity (the order matters for exact jump heights). **/
function ObjectMoveAndFall() {
	xPos += xSpeed;
	yPos += ySpeed;
	ySpeed += GRAVITY;
}

/**
 * Keeps Sonic stuck to the ground: two sensors at his feet (rotated to whichever way is "down"
 * for his angle - floor, walls or ceiling), snap to the nearer surface and take its angle. If the
 * ground drops away further than he can follow, he goes airborne.
 */
function AnglePos() {
	var px = xPos >> 8;
	var py = yPos >> 8;
	var mode = HexMath.mode(groundAngle);
	// sensor pairs: [primary, secondary], pointing "down" for this mode
	if (mode == 0x00) pair(px + widthRadius, py + heightRadius, px - widthRadius, py + heightRadius, SENSE_DOWN);
	else if (mode == 0x80) pair(px + widthRadius, py - heightRadius, px - widthRadius, py - heightRadius, SENSE_UP);
	else if (mode == 0x40) pair(px - heightRadius, py - widthRadius, px - heightRadius, py + widthRadius, SENSE_LEFT);
	else pair(px + heightRadius, py - widthRadius, px + heightRadius, py + widthRadius, SENSE_RIGHT);
	rightFootAngle = primaryAngle;
	leftFootAngle = secondaryAngle;

	// Sonic_Angle: take the surface's angle - or snap to the nearest 90 degrees if it had none
	if (hitAngle == NO_ANGLE) groundAngle = (groundAngle + 0x20) & 0xC0;
	else groundAngle = hitAngle;

	var dist = hitDist;
	if (dist == 0) return;
	if (dist < 0) {
		if (dist < -14) return;   // too far inside: ignore (walls take care of it)
		moveAlongMode(mode, dist);
		return;
	}
	// the ground is below the feet: follow it down, as far as speed allows (max 14px)
	var speed = (mode == 0x00 || mode == 0x80) ? xSpeed : ySpeed;
	var follow = iabs(speed >> 8) + 4;
	if (follow > 14) follow = 14;
	if (dist > follow) {
		inAir = true;             // ran off
		pushing = false;
		return;
	}
	moveAlongMode(mode, dist);
}

function moveAlongMode(mode, dist) {
	if (mode == 0x00) yPos += dist << 8;
	else if (mode == 0x80) yPos -= dist << 8;
	else if (mode == 0x40) xPos -= dist << 8;
	else xPos += dist << 8;
}

/** Walls while on the ground: looks where Sonic will be next frame, and stops him at the wall. **/
function Obj01_CheckWallsOnGround() {
	if (((groundAngle + 0x40) & 0x80) != 0) return;   // on a wall/ceiling: no wall checks
	if (groundSpeed == 0) return;
	var dir = (groundAngle + (groundSpeed < 0 ? 0x40 : -0x40)) & 0xFF;
	var dist = CalcRoomInFront(dir);
	if (dist >= 0) return;
	dist = dist << 8;
	var side = (dir + 0x20) & 0xC0;
	if (side == 0x00) {
		ySpeed += dist;
	} else if (side == 0x40) {
		xSpeed -= dist;
		pushing = true;
		groundSpeed = 0;
	} else if (side == 0x80) {
		ySpeed -= dist;
	} else {
		xSpeed += dist;
		pushing = true;
		groundSpeed = 0;
	}
}

/** Keeps Sonic inside the level's left/right edges; falling off the bottom kills him. **/
function Sonic_LevelBound() {
	var nextX = (xPos + xSpeed) >> 8;
	var leftEdge = Math.floor(map.x) + 16;
	var rightEdge = Math.floor(map.x) + map.worldWidth - 24;
	if (nextX < leftEdge || nextX >= rightEdge) {
		xPos = (nextX < leftEdge ? leftEdge : rightEdge) << 8;
		xSpeed = 0;
		groundSpeed = 0;
	}
	if ((yPos >> 8) > Math.floor(map.y) + map.worldHeight) KillCharacter();
}

// -------------------------------------------------------------------------------------------------
// Sensors - the named checks the routines above use
// -------------------------------------------------------------------------------------------------

/** Two sensors; hitDist = the nearer one (the second wins ties, like the original), hitOther = the other, hitAngle = the nearer one's angle. **/
function pair(x1, y1, x2, y2, dir) {
	var s = map.sensors;
	s.angle = NO_ANGLE;
	var d1 = s.sense(x1, y1, dir);
	primaryAngle = s.angle;
	s.angle = NO_ANGLE;
	var d2 = s.sense(x2, y2, dir);
	secondaryAngle = s.angle;
	if (d2 <= d1) {
		hitDist = d2;
		hitOther = d1;
		hitAngle = secondaryAngle;
	} else {
		hitDist = d1;
		hitOther = d2;
		hitAngle = primaryAngle;
	}
	return hitDist;
}

/** One sensor; with no angle found, hitAngle = `flatAngle`. **/
function castOne(sx, sy, dir, flatAngle) {
	var s = map.sensors;
	s.angle = NO_ANGLE;
	hitDist = s.sense(sx, sy, dir);
	hitAngle = s.angle == NO_ANGLE ? flatAngle : s.angle;
	return hitDist;
}

function Sonic_CheckFloor() {
	var px = xPos >> 8;
	var py = yPos >> 8;
	pair(px + widthRadius, py + heightRadius, px - widthRadius, py + heightRadius, SENSE_DOWN);
	if (hitAngle == NO_ANGLE) hitAngle = 0;
	return hitDist;
}

function Sonic_CheckCeiling() {
	var px = xPos >> 8;
	var py = yPos >> 8;
	pair(px + widthRadius, py - heightRadius, px - widthRadius, py - heightRadius, SENSE_UP);
	if (hitAngle == NO_ANGLE) hitAngle = 0x80;
	return hitDist;
}

/** Air wall sensors: 10px out from the center, at center height. **/
function CheckLeftWallDist() {
	return castOne((xPos >> 8) - 10, yPos >> 8, SENSE_LEFT, 0x40);
}

function CheckRightWallDist() {
	return castOne((xPos >> 8) + 10, yPos >> 8, SENSE_RIGHT, 0xC0);
}

/** Distance to a wall in direction `dir` from where Sonic will be NEXT frame (8px lower on flat ground, so small steps don't count). **/
function CalcRoomInFront(dir) {
	var px = (xPos + xSpeed) >> 8;
	var py = (yPos + ySpeed) >> 8;
	var mode = HexMath.mode(dir);
	if (mode == 0x00) return castOne(px, py + 10, SENSE_DOWN, 0);
	if (mode == 0x80) return castOne(px, py - 10, SENSE_UP, 0x80);
	if ((dir & 0x38) == 0) py += 8;
	if (mode == 0x40) return castOne(px - 10, py, SENSE_LEFT, 0x40);
	return castOne(px + 10, py, SENSE_RIGHT, 0xC0);
}

/** Room above Sonic's head (for his current angle) - jumping needs at least 6px. **/
function CalcRoomOverHead(dir) {
	var px = xPos >> 8;
	var py = yPos >> 8;
	var mode = (dir + 0x20) & 0xC0;
	if (mode == 0x40) return pair(px - heightRadius, py - widthRadius, px - heightRadius, py + widthRadius, SENSE_LEFT);
	if (mode == 0x80) return pair(px + widthRadius, py - heightRadius, px - widthRadius, py - heightRadius, SENSE_UP);
	if (mode == 0xC0) return pair(px + heightRadius, py - widthRadius, px + heightRadius, py + widthRadius, SENSE_RIGHT);
	return pair(px + widthRadius, py + heightRadius, px - widthRadius, py + heightRadius, SENSE_DOWN);
}

// -------------------------------------------------------------------------------------------------
// Getting hurt / dying
// -------------------------------------------------------------------------------------------------

/** Enemies call this when they touch Sonic. Return true = the enemy is destroyed. **/
function onTouchEnemy(enemy) {
	if (routine != "control") return false;
	var attacking = inBall || spindashing;
	var canBeHit = enemy.getVar("stompable") != false;   // spikes etc. hurt even when you're rolling
	if (attacking && canBeHit) {
		// Touch_KillEnemy: the bounce
		if (ySpeed < 0) ySpeed += 0x100;
		else if ((yPos >> 8) < enemy.y + enemy.height / 2) ySpeed = -ySpeed;
		else ySpeed -= 0x100;
		return true;
	}
	if (invulnerable == 0) HurtCharacter(enemy.x + enemy.width / 2);
	return false;
}

// Older enemy scripts call these two instead.
function onStomp(enemy) {
	if (ySpeed > 0) ySpeed = -ySpeed;
}

function onHurt(enemy) {
	if (routine == "control" && invulnerable == 0) HurtCharacter(enemy.x + enemy.width / 2);
}

function onCollect(item, value) {
	coins += value;
}

/** Knocked back up and away from whatever hit him (or killed, with no coins). **/
function HurtCharacter(fromX) {
	if (ringsProtect) {
		if (coins == 0) {
			KillCharacter();
			return;
		}
		coins = 0;   // (the original scatters them - these are just lost)
	}
	routine = "hurt";
	if (inBall) {
		inBall = false;
		widthRadius = STAND_WIDTH;
		heightRadius = STAND_HEIGHT;
		yPos -= 5 << 8;
	}
	inAir = true;
	pushing = false;
	rollJumping = false;
	jumping = false;
	spindashing = false;
	ySpeed = -0x400;
	xSpeed = (xPos >> 8) < fromX ? -0x200 : 0x200;
	groundSpeed = 0;
	sonicAnim = "hurt";
	invulnerable = 120;
	sfx("hurt");
}

function Obj01_Hurt() {
	ObjectMove();
	ySpeed += HURT_GRAVITY;
	// Sonic_HurtStop: land = control back, with 2 seconds of flashing
	if ((yPos >> 8) > Math.floor(map.y) + map.worldHeight) {
		KillCharacter();
		return;
	}
	Sonic_DoLevelCollision();
	if (!inAir) {
		xSpeed = 0;
		ySpeed = 0;
		groundSpeed = 0;
		sonicAnim = "walk";
		routine = "control";
		invulnerable = 120;
		spindashing = false;
	}
	Sonic_LevelBound();
}

function KillCharacter() {
	if (routine == "dead") return;
	routine = "dead";
	inAir = true;
	inBall = false;
	spindashing = false;
	xSpeed = 0;
	groundSpeed = 0;
	ySpeed = -0x700;
	sonicAnim = "death";
	sfx("death");
}

function Obj01_Dead() {
	ObjectMoveAndFall();
	// off the bottom of the screen: back to the last checkpoint
	if ((yPos >> 8) > camY + viewH + 256) respawn();
}

// -------------------------------------------------------------------------------------------------
// Animation
// -------------------------------------------------------------------------------------------------

var displayAngle = 0.0;

/** Picks the animation + its speed, and how far to tilt the sprite. **/
function Sonic_Animate() {
	var speed = iabs(groundSpeed);
	var names = null;
	var duration = -1;          // frames each animation frame lasts, minus 1 (-1 = the sprite's own fps)
	displayAngle = 0;

	if (sonicAnim == "skid" && (!hasAnim("skid") || (shownAnim == "skid" && animation.finished))) sonicAnim = "walk";

	switch (sonicAnim) {
		case "walk":
			if (pushing) {
				names = ["push", "walk"];
				duration = imax(0, 0x800 - speed) >> 6;
			} else {
				names = speed >= 0x600 ? ["run", "walk"] : ["walk", "run"];
				duration = imax(0, 0x800 - speed) >> 8;
				displayAngle = tiltAngle();
			}
		case "roll":
			names = speed >= 0x600 ? ["roll2", "roll", "jump"] : ["roll", "jump"];
			duration = imax(0, 0x400 - speed) >> 8;
		case "spindash": names = ["spindash", "roll", "jump"];
		case "lookUp": names = ["lookUp", "up", "idle"];
		case "duck": names = ["duck", "down", "idle"];
		case "balance": names = ["balance", "idle"];
		case "balance2": names = ["balance2", "balance", "idle"];
		case "skid": names = ["skid"];
		case "hurt": names = ["hurt", "fall", "jump"];
		case "death": names = ["death", "hurt", "fall"];
		default: names = ["idle"];
	}

	var name = null;
	for (n in names) if (name == null && hasAnim(n)) name = n;
	if (name == null) return;
	if (name != shownAnim) {
		playAnim(name, true);
		shownAnim = name;
	}
	if (duration >= 0 && animation.curAnim != null) animation.curAnim.frameRate = 60 / (duration + 1);
}

var shownTilt = 0;

/** The walking sprite's tilt: the ground angle in 45 degree steps like the original (or exact with smoothRotation). **/
function tiltAngle() {
	if (smoothRotation) return HexMath.toDegrees(groundAngle);
	// Only moves to another step once the angle is a bit (4) past halfway to it - otherwise a slope
	// sitting right on the halfway point (22.5 degrees) flickers between the two.
	var diff = HexMath.signedByte(groundAngle - shownTilt);
	if (diff > 0x14 || diff < -0x14) {
		var a = groundAngle;
		if (a != 0 && a < 0x80) a--;
		shownTilt = (a + 0x10) & 0xE0;
	}
	return HexMath.toDegrees(shownTilt);
}

// -------------------------------------------------------------------------------------------------
// Camera - ScrollHoriz / ScrollVerti
// -------------------------------------------------------------------------------------------------

function initCamera() {
	if (!classicCamera) {
		FlxG.camera.follow(this);
		FlxG.camera.setScrollBoundsRect(map.x, map.y, map.worldWidth, map.worldHeight);
		return;
	}
	FlxG.camera.target = null;
	updateViewSize();
	cameraBias = defaultBias;
	camX = (xPos >> 8) - Math.floor(viewW / 2);
	camY = (yPos >> 8) - cameraBias;
	clampCamera();
	applyCamera();
}

function updateViewSize() {
	viewW = Math.floor(FlxG.camera.viewWidth);
	viewH = Math.floor(FlxG.camera.viewHeight);
	defaultBias = Math.floor(viewH / 2) - 16;   // 96 on the Mega Drive's 224px screen
}

function ScrollCamera() {
	if (!classicCamera) return;
	updateViewSize();

	// ScrollHoriz: Sonic can move within a 16px window just left of center before it scrolls, at most 16px a frame
	var targetX = xPos >> 8;
	if (scrollDelay != 0) {
		// after a spin dash, follow where Sonic was a few frames ago
		scrollDelay -= 0x100;
		var back = scrollDelay >> 8;
		if (back < xHistory.length) targetX = xHistory[xHistory.length - 1 - back];
	}
	var dx = targetX - camX - (Math.floor(viewW / 2) - 16);
	if (dx < 0) {
		if (dx < -16) dx = -16;
	} else {
		dx -= 16;
		if (dx < 0) dx = 0;
		if (dx > 16) dx = 16;
	}
	camX += dx;

	// ScrollVerti
	var dy = (yPos >> 8) - camY;
	if (inBall) dy -= 5;   // so rolling (lower center) doesn't nudge the camera
	if (inAir) {
		// in the air: a 64px tall window around the bias point, up to 16px a frame
		dy += 32 - cameraBias;
		if (dy < 0) {
			if (dy < -16) dy = -16;
		} else {
			dy -= 64;
			if (dy < 0) dy = 0;
			if (dy > 16) dy = 16;
		}
	} else {
		// on the ground: straight to the bias point - 6px a frame, 16 when running fast, 2 while looking up/down
		dy -= cameraBias;
		var maxStep = cameraBias != defaultBias ? 2 : (iabs(groundSpeed) >= 0x600 ? 16 : 6);
		if (dy > maxStep) dy = maxStep;
		if (dy < -maxStep) dy = -maxStep;
	}
	camY += dy;

	clampCamera();
	applyCamera();
}

function clampCamera() {
	var minX = Math.floor(map.x);
	var minY = Math.floor(map.y);
	var maxX = minX + map.worldWidth - viewW;
	var maxY = minY + map.worldHeight - viewH;
	if (camX > maxX) camX = maxX;
	if (camX < minX) camX = minX;
	if (camY > maxY) camY = maxY;
	if (camY < minY) camY = minY;
}

function applyCamera() {
	FlxG.camera.scroll.set(camX - FlxG.camera.viewMarginX, camY - FlxG.camera.viewMarginY);
}

/** Obj01_ResetScr: not looking up/down - the camera eases back to normal. **/
function Obj01_ResetScr() {
	lookDelay = 0;
	resetCameraBias();
}

function resetCameraBias() {
	if (iabs(cameraBias - defaultBias) < 2) cameraBias = defaultBias;
	else if (cameraBias < defaultBias) cameraBias += 2;
	else cameraBias -= 2;
}

function Sonic_RecordPos() {
	xHistory.push(xPos >> 8);
	if (xHistory.length > 64) xHistory.shift();
}

// -------------------------------------------------------------------------------------------------
// Glue: input, putting the Entity where the physics says, sounds
// -------------------------------------------------------------------------------------------------

function readInput() {
	inLeft = controls.LEFT;
	inRight = controls.RIGHT;
	inUp = controls.UP;
	inDown = controls.DOWN;
	inJumpPress = jumpPressLatch;
	inJumpHeld = controls.ACCEPT_HOLD || FlxG.keys.pressed.SPACE || FlxG.keys.pressed.Z || FlxG.keys.pressed.X || FlxG.keys.pressed.C;
}

function jumpJustPressed() {
	return controls.ACCEPT || FlxG.keys.justPressed.SPACE || FlxG.keys.justPressed.Z || FlxG.keys.justPressed.X || FlxG.keys.justPressed.C;
}

/** Moves the Entity (its box, sprite, rotation) to match the physics. **/
function syncEntity() {
	var px = xPos >> 8;
	var py = yPos >> 8;
	var feet = py + heightRadius + 1;   // the first pixel row below Sonic
	x = px - Math.floor(width / 2);
	y = feet - height;
	flipX = facingLeft;
	angle = displayAngle;
	// in pixels per second, for other scripts that look at it (the physics never uses it)
	velocity.set(xSpeed * 60 / 256, ySpeed * 60 / 256);

	if (spriteData != null) {
		// the sprite's hitbox bottom sits on Sonic's feet...
		offset.y = spriteData.hitboxY + spriteData.hitboxHeight - height;
		// ...and it tilts around his center (Entity.draw sets offset.x the same way, mirrored when flipped)
		var offsetX = flipX ? frameWidth - spriteData.hitboxX - spriteData.hitboxWidth : spriteData.hitboxX;
		origin.set(px - x + offsetX, py - y + offset.y);
	}

	// flashing after getting hurt: shown 4 frames, hidden 4
	visible = routine != "control" || invulnerable == 0 || ((invulnerable >> 2) & 1) == 1;
}

/** Plays sounds/<name>.ogg if the game has it (jump, roll, skid, spindash, release, hurt, death). **/
function sfx(name) {
	var soundPath = Paths.sound(name);
	if (Assets.exists(soundPath)) FlxG.sound.play(soundPath);
}

function iabs(v) {
	return v < 0 ? -v : v;
}

function imax(a, b) {
	return a > b ? a : b;
}
