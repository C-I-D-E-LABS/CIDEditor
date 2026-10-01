package;

class OptionsData {
    public static function goBack():Void {
        var state = FlxG.save.data.optionsReturnState;
        trace("goBack() -> optionsReturnState is: " + state);

        switch (state) {
            case "song":
                PlayState.loadSong(FlxG.save.data.optionsReturnSongName, FlxG.save.data.optionsReturnDifficulty);
                FlxG.switchState(new PlayState());
            case "dlc":
                FlxG.switchState(new GameState("XEternalDlcMenu"));
            default:
                FlxG.switchState(new MainMenuState());
        }
    }
}