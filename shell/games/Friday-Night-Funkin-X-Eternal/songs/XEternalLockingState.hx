var songsBeaten:Int = FlxG.save.data.songsBeaten == null ? 0 : FlxG.save.data.songsBeaten;

function onSongEnd(event) {
    trace("JUST FINISHED " + songName);

    if (weeks.contains(songName) || songName == "Eclipsera") {
        var alreadyBeaten:Bool = false;

        switch(songName) {
            case "Too Slow":
                alreadyBeaten = songsBeaten >= 1;
                if (songsBeaten < 1) songsBeaten = 1;
            case "You Cant Run":
                alreadyBeaten = songsBeaten >= 2;
                if (songsBeaten < 2) songsBeaten = 2;
            case "Triple Trouble":
                alreadyBeaten = songsBeaten >= 4;
                if (songsBeaten < 4) songsBeaten = 4;
            case "Eclipsera":
                alreadyBeaten = songsBeaten >= 3;
                if (songsBeaten < 3) songsBeaten = 3;
        }

        FlxG.save.data.songsBeaten = songsBeaten;
        FlxG.save.flush();
        trace("Songs Beaten Updated: " + songsBeaten);

        if (alreadyBeaten) {
            event.cancelled = true; // cancel CNE's native continue/advance behavior
            FlxG.sound.music.stop();
            FlxG.switchState(new StoryMenuState());
        }
    }
}