import funkin.game.cutscenes.ScriptedCutscene;
import flixel.FlxG;
import hxvlc.flixel.FlxVideoSprite; // Used if your cutscene is an MP4 video

// Import the specific state you want to open next. Replace with your actual state name.
import funkin.menus.MainMenuState; 

function create() {
    // Option A: If your end cutscene is a video
    startVideo(Paths.video("You Cant Run End"), function() {
        goToCustomState();
    });
}

function goToCustomState() {
    // 1. Tell FlxG to switch to your destination state instance
    // Note: Replace 'MainMenuState' with whatever state class you have compiled in your source
    FlxG.switchState(new GameState("XEternalDecider"));
    
    // 2. Clear any lingering assets from the current song session
    //close(); 
}
