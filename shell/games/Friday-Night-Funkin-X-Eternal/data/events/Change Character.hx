import haxe.ds.StringMap;

var charMap:Array<Array<StringMap<Character>>> = [];
function charMapNullCheck(strumIndex:Int, charIndex:Int) {
	if (charMap[strumIndex] == null) charMap[strumIndex] = [];
	if (charMap[strumIndex][charIndex] == null) charMap[strumIndex][charIndex] = new StringMap();
}

// partially stole from gorefield lol
function postCreate() {
	// add preexisting
	for (strumLine in strumLines) {
		var strumIndex:Int = strumLines.members.indexOf(strumLine);
		for (char in strumLine.characters) {
			var charIndex:Int = strumLine.characters.indexOf(char);

			// null check
			charMapNullCheck(strumIndex, charIndex);

			// le code
			charMap[strumIndex][charIndex].set(char.curCharacter, char);
			trace('Preexisting index "' + charIndex + '" character "' + char.curCharacter + '" on strumLine "' + strumIndex + '".');
		}
	}
	// precache
	for (event in events)
		if (event.name == 'Change Character')
			precacheCharacter(event.params[0], event.params[1], event.params[2]);
}

public function precacheCharacter(strumIndex:Int, charName:String = 'bf', memberIndex:Int = 0) {
	// null check
	charMapNullCheck(strumIndex, memberIndex);

	// precache process
	if (!charMap[strumIndex][memberIndex].exists(charName)) {
		// vars
		var strumLine:StrumLine = strumLines.members[strumIndex];
		var existingChar:Character = strumLine.characters[memberIndex];

		var newChar:Character = new Character(existingChar.x, existingChar.y, charName, existingChar.isPlayer);
		charMap[strumIndex][memberIndex].set(newChar.curCharacter, newChar);
		newChar.active = false;
		trace('Precached index "' + memberIndex + '" character "' + newChar.curCharacter + '" on strumLine "' + strumIndex + '".');

		try { // sometimes this works because atlases lmao
			if (newChar.animateAtlas != null) newChar.animateAtlas.drawComplex(FlxG.camera);
			else newChar.drawComplex(FlxG.camera);
		} catch(e:Dynamic) {
			trace('drawComplex didn\'t work this time for some reason');
		}

		// cam stage offsets
		switch (strumIndex) {
			case 0:
				newChar.cameraOffset.x += stage?.characterPoses['dad']?.camxoffset;
				newChar.cameraOffset.y += stage?.characterPoses['dad']?.camyoffset;
			case 1:
				newChar.cameraOffset.x += stage?.characterPoses['boyfriend']?.camxoffset;
				newChar.cameraOffset.y += stage?.characterPoses['boyfriend']?.camyoffset;
			case 2:
				newChar.cameraOffset.x += stage?.characterPoses['girlfriend']?.camxoffset;
				newChar.cameraOffset.y += stage?.characterPoses['girlfriend']?.camyoffset;
		}
		newChar.setPosition(existingChar.x, existingChar.y);
		scripts.call('onCharacterCached', [newChar, strumIndex, memberIndex]);
	}
}

public function changeCharacter(strumIndex:Int, charName:String = 'bf', memberIndex:Int = 0, ?updateBar:Bool = true) {
	// if new char no exist
	if (!charMap[strumIndex][memberIndex].exists(charName))
		precacheCharacter(strumIndex, charName, memberIndex);

	// vars
	var oldChar:Character = strumLines.members[strumIndex].characters[memberIndex];
	var newChar:Character = charMap[strumIndex][memberIndex].get(charName);

	// null check
	if (oldChar == null || newChar == null) return;
	if (oldChar.curCharacter == newChar.curCharacter) return trace('It\'s the same character bro.');

	// icon change
	if (memberIndex == 0 && updateBar) {
		if (strumIndex == 0) { // opponent side
			iconP2.setIcon(newChar.getIcon());
			if (Options.colorHealthBar) healthBar.createColoredEmptyBar(newChar.iconColor ?? (PlayState.opponentMode ? 0xFF66FF33 : 0xFFFF0000));
			healthBar.updateBar();
		} else if (strumIndex == 1) { // player side
			iconP1.setIcon(newChar.getIcon());
			if (Options.colorHealthBar) healthBar.createColoredFilledBar(newChar.iconColor ?? (PlayState.opponentMode ? 0xFFFF0000 : 0xFF66FF33));
			healthBar.updateBar();
		}
	}

	// swaps old and new char
	var group = FlxTypedGroup.resolveGroup(oldChar) ?? this;
	group.insert(group.members.indexOf(oldChar), newChar);
	newChar.active = true;
	oldChar.active = false;
	group.remove(oldChar);

	// fully apply change
	newChar.setPosition(oldChar.x, oldChar.y);
	newChar.playAnim(oldChar.animation?.name, true, oldChar.lastAnimContext);
	newChar.animation?.curAnim?.curFrame = oldChar.animation?.curAnim?.curFrame;
	strumLines.members[strumIndex].characters[memberIndex] = newChar;
	trace('Character index "' + memberIndex + '" changed to "' + newChar.curCharacter + '" on strumLine "' + strumIndex + '"!');
	scripts.call('onChangeCharacter', [oldChar, newChar, strumIndex, memberIndex]);
}

function onEvent(event) {
	switch (event.event.name) {
		case 'Change Character':
			changeCharacter(event.event.params[0], event.event.params[1], event.event.params[2], event.event.params[3]);
	}
}
