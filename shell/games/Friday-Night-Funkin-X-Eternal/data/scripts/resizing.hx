import openfl.system.Capabilities;
import funkin.backend.utils.ShaderResizeFix;
import flixel.system.scaleModes.RatioScaleMode;
import funkin.backend.MusicBeatTransition;

public function ratioThing(width:Int,height:Int,?skip:Bool = false){
	if (FlxG.state != null && FlxG.state.subState is MusicBeatTransition) {
		new FlxTimer().start(0, function(_) ratioThing(width, height, skip));
		return;
	}

	var nextState = null;
	@:privateAccess {
		nextState = FlxG.game._requestedState;
	}
	var nextStateName = nextState == null ? "" : Type.getClassName(Type.getClass(nextState));
	if (nextStateName == null) nextStateName = "";

	final isEditor = nextStateName.indexOf("Charter") != -1 || nextStateName.indexOf("Editor") != -1;

	final winYRatio = 1;
	var winY = height * winYRatio;
	var winX = width * winYRatio;

	if (isEditor) {
		// force back to native/default resolution for the editor
		winX = 1280;
		winY = 720;
	}

	if (skip) {
		if (FlxG.width == winX && FlxG.height == winY && Std.int(window.width) == winX && Std.int(window.height) == winY) {
			window.resizable = winX == 1280;
			return;
		}
	}

	if (camHUD != null)
		camHUD.fade(FlxColor.BLACK, 0);

	FlxTween.cancelTweensOf(window);
	if (!skip){
		FlxTween.tween(window, {
			width: winX,
			height: winY,
			y: Math.floor((Capabilities.screenResolutionY / 2) - (winY / 2)),
			x: Math.floor(((Capabilities.screenResolutionX) / 2) - (winX / 2)) + ((Capabilities.screenResolutionX) * Math.floor(window.x / (Capabilities.screenResolutionX)))
		}, 0.4, {
			ease: FlxEase.quadInOut,
			onComplete: function(a) {
				if (camHUD != null)
					camHUD.fade(FlxColor.BLACK, 0, true);
			}
		});
	} else {
		FlxG.resizeWindow(width, height);
		FlxG.width = winX;
		FlxG.height = winY;
		window.y = Math.floor((Capabilities.screenResolutionY / 2) - (winY / 2));
		window.x = Math.floor(((Capabilities.screenResolutionX) / 2) - (winX / 2)) + ((Capabilities.screenResolutionX) * Math.floor(window.x / (Capabilities.screenResolutionX)));
	}
	FlxG.scaleMode = new RatioScaleMode(true);
	window.resizable = winX == 1280;

	ShaderResizeFix.doResizeFix = true;
	ShaderResizeFix.fixSpritesShadersSizes();
}