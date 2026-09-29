// Tilemap Test - the whole game is this one level.
//
// data/config/game.ini redirects the engine's starting state (TitleState) here, so running the
// game from the Games menu drops you straight in.
//
// Arrows / WASD move - Space / Enter / Up jump (hold for higher) - Down + jump drops through
// ledges - R respawn - Esc back to the Games menu (editor build only).
//
// All this state does is load the level - the player is whichever entity sets isPlayer (the
// Platformer Player template does - data/entities/Player.hx or Sonic.hx; edit it to change how the
// player moves). Coins, enemies, checkpoints and the Goal are entities too. Open a map from
// the workbench Explorer and switch the left panel to its Entities tab to move/add/remove them.

import flixel.text.FlxText;
import funkin.menus.GamesMenu;

var MAP_NAME = "GHZTest";

var map:TileMap;
var hud:FlxCamera;
var info:FlxText;

function create() {
	FlxG.camera.bgColor = 0xFF6FB7E8;
	FlxG.camera.zoom = 2;

	map = new TileMap(MAP_NAME);
	add(map);
	if (map.getPlayer() == null)
		trace("No Player entity placed in " + MAP_NAME + " - open it in the tilemap editor, Entities tab, and place one.");

	// separate, unzoomed camera for the text
	hud = new FlxCamera();
	hud.bgColor = 0x00000000;
	FlxG.cameras.add(hud, false);
	info = new FlxText(10, 10, 0, "", 16);
	info.cameras = [hud];
	add(info);
}

function update(elapsed) {
	var player = map.getPlayer();
	if (player != null && FlxG.keys.justPressed.R) player.respawn();
	// no menus in this game - Esc only means something in the editor build
	if (controls.BACK && !Main.isReleaseShell) FlxG.switchState(new GamesMenu());
}

function postUpdate(elapsed) {
	var player = map.getPlayer();
	if (player == null) return;
	var coins = player.getVar("coins");
	var left = map.getEntities("Coin").length;
	info.text = "Coins: " + coins + " / " + (coins + left) + (left == 0 ? "   - got them all!" : "")
		+ "\nArrows/WASD move - Space/Enter/Up jump (hold for higher) - Down + jump drops through ledges - R respawn";
}
