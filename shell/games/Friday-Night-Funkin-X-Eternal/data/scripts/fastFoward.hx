
// THIS IS USED JUST FOR TESTING EVENTS QUICKLY  
// IT WILL BE REMOVED IN THE FINAL BUILD

function update() {
    if (startingSong || !canPause || paused || health <= 0) return;

    if (FlxG.keys.pressed.TWO) updateSpeed(true);
    if (FlxG.keys.justReleased.TWO) {
        updateSpeed(false);
        player.cpu = false;
    }
}

function updateSpeed(fast:Bool) {
    FlxG.timeScale = inst.pitch = vocals.pitch = (player.cpu = fast) ? 10 : 1;

    for (i in 0...strumLines.length) 
        strumLines.members[i].vocals.pitch = FlxG.timeScale;

    FlxG.sound.muted = fast;
    health = !(canDie != fast) ? 2 : health;
}

function onGamePause() updateSpeed(false);
function onSongEnd() updateSpeed(false);
function destroy() {FlxG.timeScale = 1;FlxG.sound.muted = false; player.cpu = false;}
