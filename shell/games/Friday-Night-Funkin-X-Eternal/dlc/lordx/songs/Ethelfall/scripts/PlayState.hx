// data/states/PlayState.hx
// Intercepts song end and redirects back to your DLC menu instead of Freeplay

function onSongEnd(event)
{
    // Only intercept if we came from the DLC menu
    // We use a static flag set before launching PlayState
    if (FlxG.save.data.cameFromDLCMenu == true)
    {
        event.cancelled = true; // stop the default freeplay redirect
        FlxG.save.data.cameFromDLCMenu = false;
        FlxG.save.flush();
        FlxG.switchState(new GameState("XEternalDlcMenu"));
    }
}