package;

class Loader {
	public static function loadSongWithReturn(name:String, difficulty:String, returnTo:String, opponentMode:Bool = false, coopMode:Bool = false):Void {
		setReturnState(returnTo);
		PlayState.loadSong(name, difficulty, opponentMode, coopMode);
		FlxG.switchState(new PlayState());
	}

	public static function loadWeekWithReturn(weekData:WeekData, difficulty:String, returnTo:String):Void {
		setReturnState(returnTo);
		PlayState.loadWeek(weekData, difficulty);
		FlxG.switchState(new PlayState());
	}

	static function setReturnState(returnTo:String):Void {
		FlxG.save.data.returnState = returnTo;
		FlxG.save.flush();
	}
}