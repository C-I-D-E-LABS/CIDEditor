// var s:Int = 0;

// function laserThingy(first:Bool)
// 	{

// 		FlxG.sound.play(Paths.sound('laser'));

// 		warning:FlxSprite = new FlxSprite();
// 		warning.frames = Paths.getSparrowAtlas('Warning', 'exe');
// 		warning.cameras = [camHUD];
// 		warning.scale.set(0.5, 0.5);
// 		warning.screenCenter();
// 		warning.animation.addByPrefix('a', 'Warning Flash', 24, false);
// 		warning.alpha = 0;
// 		add(warning);
// 		canDodge = true;

// 		dodgething:FlxSprite = new FlxSprite(0, 600);
// 		dodgething.frames = Paths.getSparrowAtlas('spacebar_icon', 'exe');
// 		dodgething.animation.addByPrefix('a', 'spacebar', 24, false);
// 		dodgething.scale.x = .5;
// 		dodgething.scale.y = .5;
// 		dodgething.screenCenter();
// 		dodgething.x -= 60;
// 		dodgething.cameras = [camHUD];
// 		add(dodgething);

// 		new FlxTimer().start(0, function(a:FlxTimer)
// 		{
// 			s++;
// 			warning.animation.play('a', true);
// 			if (s < 4)
// 				a.reset(0.32);
// 			else
// 				remove(warning);
// 			if (s == 3)
// 			{
// 				remove(dad);
// 				tailscircle = '';
// 				dodgething.animation.play('a', true);
// 				dad = new Character(61.15, -74.75, 'fleetway-extras3');
// 				add(dad);
// 				dad.playAnim('a', true);
// 				dad.animation.finishCallback = function(a:String)
// 				{
// 					remove(dad);
// 					tailscircle = 'hovering';
// 					dad = new Character(61.15, -94.75, 'fleetway');
// 					add(dad);
// 				}
// 			}
// 			else if (s == 4)
// 			{
// 				remove(dodgething);
// 			}
// 		});
// 	}