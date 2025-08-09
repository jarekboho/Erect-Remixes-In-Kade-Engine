package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxSprite;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxObject;

	var stageSuffix:String = "";

	var deathSpriteRetry:FlxSprite;
	var deathSpriteNene:FlxSprite;

	var CAMERA_ZOOM_DURATION:Float = 0.5;

	var targetCameraZoom:Float = 1.0;

	public function new(x:Float, y:Float)
	{
		var daStage = PlayState.curStage;
		var daBf:String = '';
		switch (daStage)
		{
			case 'school':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel';
			case 'schoolEvil':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel';
			case 'phillyStreets':
				stageSuffix = '-pico';
				daBf = 'pico-playable';
			default:
				daBf = 'bf';
		}

		super();

		Conductor.songPosition = 0;

		bf = new Boyfriend(x, y, daBf);
		var playState = cast(FlxG.state, PlayState);
		@:privateAccess
		if(playState.boyfriend.shader != null && daBf != 'bf-pixel' && PlayState.curStage != 'tank')
		bf.shader = playState.boyfriend.shader;
		add(bf);

		bf.updateHitbox();

		var playState = cast(FlxG.state, PlayState);

		@:privateAccess
		targetCameraZoom = playState.stageZoom;

		@:privateAccess
		{
		camFollow = new FlxObject(playState.camFollow.x, playState.camFollow.y, 1, 1);
		if(daBf == 'pico-playable')
		{
		camFollow.x = getMidPointOld(bf).x + 10;
		camFollow.y = getMidPointOld(bf).y + -40;
		}
		else
		{
		camFollow.x = getMidPointOld(bf).x;
		camFollow.y = getMidPointOld(bf).y;
		}
		}
		add(camFollow);

		FlxG.sound.play(Paths.sound('fnf_loss_sfx' + stageSuffix));
		Conductor.changeBPM(100);

		FlxG.camera.target = null;

		bf.playAnim('firstDeath');

		FlxG.camera.setFilters([]);

		if(daBf == 'pico-playable')
		{
		createDeathSprites();

		add(deathSpriteRetry);
		deathSpriteRetry.antialiasing = true;
		add(deathSpriteNene);
		deathSpriteNene.antialiasing = true;
		deathSpriteNene.animation.play("throw");
		}
	}

	function getMidPointOld(spr:FlxSprite, ?point:FlxPoint):FlxPoint
	{
		if (point == null) point = FlxPoint.get();
		return point.set(spr.x + spr.frameWidth * 0.5 * spr.scale.x, spr.y + spr.frameHeight * 0.5 * spr.scale.y);
	}

	function createDeathSprites() {
		deathSpriteRetry = new FlxSprite(0, 0);
		deathSpriteRetry.frames = Paths.getSparrowAtlas("Pico_Death_Retry", 'weekend1');

		if (bf.shader != null)
		{
		deathSpriteRetry.shader = bf.shader;
		}
		deathSpriteRetry.animation.addByPrefix('idle', "Retry Text Loop0", 24, true);
		deathSpriteRetry.animation.addByPrefix('confirm', "Retry Text Confirm0", 24, false);

		deathSpriteRetry.visible = false;

		deathSpriteNene = new FlxSprite(0, 0);
		deathSpriteNene.frames = Paths.getSparrowAtlas("NeneKnifeToss", 'weekend1');
		var playState = cast(FlxG.state, PlayState);
		@:privateAccess
		{
		deathSpriteNene.x = playState.gf.originalPosition.x + 120;
		deathSpriteNene.y = playState.gf.originalPosition.y - 200;
		}
		deathSpriteNene.origin.x = 172;
		deathSpriteNene.origin.y = 205;
		deathSpriteNene.animation.addByPrefix('throw', "knife toss0", 24, false);
		deathSpriteNene.visible = true;
		deathSpriteNene.animation.finishCallback = function(name:String)
		{
			deathSpriteNene.visible = false;
		}
	}

	public static function lerp(base:Float, target:Float, progress:Float):Float
	{
		return base + progress * (target - base);
	}

	public static function smoothLerp(current:Float, target:Float, elapsed:Float, duration:Float, precision:Float = 1 / 100):Float
	{
		if (current == target) return target;

		var result:Float = lerp(current, target, 1 - Math.pow(precision, elapsed / duration));

		if (Math.abs(result - target) < (precision * target)) result = target;

		return result;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		FlxG.camera.zoom = smoothLerp(FlxG.camera.zoom, targetCameraZoom, elapsed, CAMERA_ZOOM_DURATION);

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();

			FlxG.switchState(new FreeplayState());
			PlayState.loadRep = false;
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
		}

		if(bf.curCharacter == 'pico-playable')
		{
		if (bf.animation.curAnim.name == "firstDeath" && bf.animation.curAnim.curFrame == 36 - 1) {
			if (deathSpriteRetry != null && deathSpriteRetry.animation != null)
			{
				deathSpriteRetry.animation.play('idle');
				deathSpriteRetry.visible = true;

				deathSpriteRetry.x = bf.x + 195;
				deathSpriteRetry.y = bf.y - 70;
			}

			if(!isEnding)
			{
			FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix));
			}
			bf.playAnim('deathLoop');
		}
		}
		else
		{
		var playState = cast(FlxG.state, PlayState);
		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
		{
			@:privateAccess
			if(playState.dad.curCharacter == 'tankman')
			{
			FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix), 0.2);
			FlxG.sound.play(Paths.sound('jeffGameover/jeffGameover-' + FlxG.random.int(1, 25), 'week7'), 1, false, null, true, function()
			{
			FlxG.sound.music.fadeIn(4, 0.2, 1);
			});
			}
			else
			FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix));
		}
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			if(deathSpriteRetry != null)
			{
			deathSpriteRetry.animation.play('confirm');
			deathSpriteRetry.x -= 250;
			deathSpriteRetry.y -= 200;
			}
			if(bf.curCharacter != 'pico-playable')
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('gameOverEnd' + stageSuffix));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
	}
}