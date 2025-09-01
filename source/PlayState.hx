package;

import openfl.geom.Matrix;
import openfl.display.BitmapData;
import openfl.utils.AssetType;
import lime.graphics.Image;
import flixel.graphics.FlxGraphic;
import openfl.utils.AssetManifest;
import openfl.utils.AssetLibrary;
import flixel.system.FlxAssets;
import llua.Convert;
import llua.Lua;
import llua.State;
import llua.LuaL;
import lime.app.Application;
import lime.media.AudioContext;
import lime.media.AudioManager;
import openfl.Lib;
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffectRuntime.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import flixel.addons.display.FlxBackdrop;
import Song.SongEventData;
import flixel.addons.display.FlxTiledSprite;
import flxanimate.FlxAnimate;

#if windows
import Discord.DiscordClient;
#end
#if desktop
import Sys;
import sys.FileSystem;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var storyWeek:Int = 0;
	public static var storyDifficulty:Int = 1;
	public static var weekSong:Int = 0;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;

	public static var songPosBG:FlxSprite;
	public static var songPosBar:FlxBar;

	public static var rep:Replay;
	public static var loadRep:Bool = false;

	public static var noteBools:Array<Bool> = [false, false, false, false];

	var halloweenLevel:Bool = false;

	var songLength:Float = 0;
	var kadeEngineWatermark:FlxText;
	
	#if windows
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	private var vocals:FlxSound;

	private var dad:Character;
	private var gf:Character;
	private var boyfriend:Boyfriend;

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;

	private var curSong:String = "";

	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	private var combo:Int = 0;
	public static var misses:Int = 0;
	private var accuracy:Float = 0.00;
	private var accuracyDefault:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalNotesHitDefault:Float = 0;
	private var totalPlayed:Int = 0;
	private var ss:Bool = false;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
	private var songPositionBar:Float = 0;
	
	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	public static var offsetTesting:Bool = false;

	var notesHitArray:Array<Date> = [];
	var currentFrames:Int = 0;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;

	var bgLight:FlxSprite;
	var stairsLight:FlxSprite;

	var rainShaderTarget:FlxSprite;
	var rainShader:RainShader = new RainShader();

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var train:FlxSprite;
	var trainSound:FlxSound;

	var LIGHT_COUNT:Int = 5;

	var lightShader:BuildingEffectShader;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;
	var songName:FlxText;
	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var mist0:FlxBackdrop;
	var mist1:FlxBackdrop;
	var mist2:FlxBackdrop;
	var mist3:FlxBackdrop;
	var mist4:FlxBackdrop;
	var mist5:FlxBackdrop;

	var shootingStarBeat:Int = 0;
	var shootingStarOffset:Int = 2;
	var shootingStar:FlxSprite;

	var _timer:Float = 0;

	var fc:Bool = true;

	var wiggleBack:WiggleEffectRuntime = null;
	var wiggleSchool:WiggleEffectRuntime = null;
	var wiggleGround:WiggleEffectRuntime = null;
	var wiggleSpike:WiggleEffectRuntime = null;

	var talking:Bool = true;
	var songScore:Int = 0;
	var songScoreDef:Int = 0;
	var scoreTxt:FlxText;
	var replayTxt:FlxText;

	public static var campaignScore:Int = 0;

	public static var daPixelZoom:Float = 6;

	public static var theFunne:Bool = true;
	var inCutscene:Bool = false;
	public static var repPresses:Int = 0;
	public static var repReleases:Int = 0;

	public static var timeCurrently:Float = 0;
	public static var timeCurrentlyR:Float = 0;
	
	// Will fire once to prevent debug spam messages and broken animations
	private var triggeredAlready:Bool = false;
	
	// Will decide if she's even allowed to headbang at all depending on the song
	private var allowedToHeadbang:Bool = false;
	// Per song additive offset
	public static var songOffset:Float = 0;

	private var executeModchart = false;

	// LUA SHIT
		
	public static var lua:State = null;

	var songEvents:Array<SongEventData> = [];

	var cameraSpeed:Float = 0;

	var cameraFollowTween:FlxTween;

	var cameraZoomTween:FlxTween;

	var stageZoom:Float;

	var currentCameraZoom:Float = FlxCamera.defaultZoom;

	var cameraBopMultiplier:Float = 1.0;

	var defaultHUDCameraZoom:Float = FlxCamera.defaultZoom * 1.0;

	var cameraBopIntensity:Float = 1.015;

	var hudCameraZoomIntensity:Float = 0.015 * 2.0;

	var cameraZoomRate:Int = 4;

	var sniper:FlxSprite;
	var guy:FlxSprite;

	var scrollingSky:FlxTiledSprite;

	var phillyCars:FlxSprite;
	var phillyCars2:FlxSprite;

	var phillyTraffic:FlxSprite;

	var lightsStop:Bool = false;
	var lastChange:Int = 0;
	var changeInterval:Int = 8;

	var carWaiting:Bool = false;
	var carInterruptable:Bool = true;
	var car2Interruptable:Bool = true;

	var abot:ABotSpeaker;
	var abotLookDir:Bool = false;

	var rainShaderStartIntensity:Float = 0;
	var rainShaderEndIntensity:Float = 0;

	var santaDead:FlxAnimate;
	var parentsShoot:FlxAnimate;

	function callLua(func_name : String, args : Array<Dynamic>, ?type : String) : Dynamic
	{
		var result : Any = null;

		Lua.getglobal(lua, func_name);

		for( arg in args ) {
		Convert.toLua(lua, arg);
		}

		result = Lua.pcall(lua, args.length, 1, 0);

		if (getLuaErrorMessage(lua) != null)
			trace(func_name + ' LUA CALL ERROR ' + Lua.tostring(lua,result));

		if( result == null) {
			return null;
		} else {
			return convert(result, type);
		}

	}

	function getType(l, type):Any
	{
		return switch Lua.type(l,type) {
			case t if (t == Lua.LUA_TNIL): null;
			case t if (t == Lua.LUA_TNUMBER): Lua.tonumber(l, type);
			case t if (t == Lua.LUA_TSTRING): (Lua.tostring(l, type):String);
			case t if (t == Lua.LUA_TBOOLEAN): Lua.toboolean(l, type);
			case t: throw 'you don goofed up. lua type error ($t)';
		}
	}

	function getReturnValues(l) {
		var lua_v:Int;
		var v:Any = null;
		while((lua_v = Lua.gettop(l)) != 0) {
			var type:String = getType(l,lua_v);
			v = convert(lua_v, type);
			Lua.pop(l, 1);
		}
		return v;
	}

	private function convert(v : Any, type : String) : Dynamic { // I didn't write this lol
		if( Std.is(v, String) && type != null ) {
		var v : String = v;
		if( type.substr(0, 4) == 'array' ) {
			if( type.substr(4) == 'float' ) {
			var array : Array<String> = v.split(',');
			var array2 : Array<Float> = new Array();

			for( vars in array ) {
				array2.push(Std.parseFloat(vars));
			}

			return array2;
			} else if( type.substr(4) == 'int' ) {
			var array : Array<String> = v.split(',');
			var array2 : Array<Int> = new Array();

			for( vars in array ) {
				array2.push(Std.parseInt(vars));
			}

			return array2;
			} else {
			var array : Array<String> = v.split(',');
			return array;
			}
		} else if( type == 'float' ) {
			return Std.parseFloat(v);
		} else if( type == 'int' ) {
			return Std.parseInt(v);
		} else if( type == 'bool' ) {
			if( v == 'true' ) {
			return true;
			} else {
			return false;
			}
		} else {
			return v;
		}
		} else {
		return v;
		}
	}

	function getLuaErrorMessage(l) {
		var v:String = Lua.tostring(l, -1);
		Lua.pop(l, 1);
		return v;
	}

	public function setVar(var_name : String, object : Dynamic){
		// trace('setting variable ' + var_name + ' to ' + object);

		Lua.pushnumber(lua,object);
		Lua.setglobal(lua, var_name);
	}

	public function getVar(var_name : String, type : String) : Dynamic {
		var result : Any = null;

		// trace('getting variable ' + var_name + ' with a type of ' + type);

		Lua.getglobal(lua, var_name);
		result = Convert.fromLua(lua,-1);
		Lua.pop(lua,1);

		if( result == null ) {
		return null;
		} else {
		var result = convert(result, type);
		//trace(var_name + ' result: ' + result);
		return result;
		}
	}

	function getActorByName(id:String):Dynamic
	{
		// pre defined names
		switch(id)
		{
			case 'boyfriend':
				return boyfriend;
			case 'girlfriend':
				return gf;
			case 'dad':
				return dad;
		}
		// lua objects or what ever
		if (luaSprites.get(id) == null)
			return strumLineNotes.members[Std.parseInt(id)];
		return luaSprites.get(id);
	}

	public static var luaSprites:Map<String,FlxSprite> = [];

	function makeLuaSprite(spritePath:String,toBeCalled:String, drawBehind:Bool)
	{
		#if sys
		var data:BitmapData = BitmapData.fromFile(Sys.getCwd() + "assets/data/" + PlayState.SONG.song.toLowerCase() + '/' + spritePath + ".png");

		var sprite:FlxSprite = new FlxSprite(0,0);
		var imgWidth:Float = FlxG.width / data.width;
		var imgHeight:Float = FlxG.height / data.height;
		var scale:Float = imgWidth <= imgHeight ? imgWidth : imgHeight;

		// Cap the scale at x1
		if (scale > 1)
		{
			scale = 1;
		}

		sprite.makeGraphic(Std.int(data.width * scale),Std.int(data.width * scale),FlxColor.TRANSPARENT);

		var data2:BitmapData = sprite.pixels.clone();
		var matrix:Matrix = new Matrix();
		matrix.identity();
		matrix.scale(scale, scale);
		data2.fillRect(data2.rect, FlxColor.TRANSPARENT);
		data2.draw(data, matrix, null, null, null, true);
		sprite.pixels = data2;
		
		luaSprites.set(toBeCalled,sprite);
		// and I quote:
		// shitty layering but it works!
		if (drawBehind)
		{
			remove(gf);
			remove(boyfriend);
			remove(dad);
		}
		add(sprite);
		if (drawBehind)
		{
			add(gf);
			add(boyfriend);
			add(dad);
		}
		#end
		return toBeCalled;
	}

	// LUA SHIT

	override public function create()
	{

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		sicks = 0;
		bads = 0;
		shits = 0;
		goods = 0;

		misses = 0;

		repPresses = 0;
		repReleases = 0;

		#if sys
		executeModchart = FileSystem.exists(Paths.lua(PlayState.SONG.song.toLowerCase()  + "/modchart"));
		#end
		#if !cpp
		executeModchart = false; // FORCE disable for non cpp targets
		#end

		trace('Mod chart: ' + executeModchart + " - " + Paths.lua(PlayState.SONG.song.toLowerCase() + "/modchart"));

		#if windows
		// Making difficulty text for Discord Rich Presence.
		switch (storyDifficulty)
		{
			case 0:
				storyDifficultyText = "Easy";
			case 1:
				storyDifficultyText = "Erect";
			case 2:
				storyDifficultyText = "Nightmare";
		}

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		detailsText = "Freeplay";

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " + generateRanking(), "\nAcc: " + truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC);
		#end

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('bopeebo');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		trace('INFORMATION ABOUT WHAT U PLAYIN WIT:\nFRAMES: ' + Conductor.safeFrames + '\nZONE: ' + Conductor.safeZoneOffset + '\nTS: ' + Conductor.timeScale);

		switch(SONG.song.toLowerCase())
		{
			case 'spookeez' | 'south': 
			{
				curStage = 'spooky';
				currentCameraZoom = 1.0;
				halloweenLevel = true;

				isHalloween = true;

				var solid = new FlxSprite(-300, -500).makeGraphic(1, 1, 0xFF242336);
				solid.scrollFactor.set(0, 0);
				solid.scale.set(2400, 2000);
				solid.updateHitbox();
				add(solid);

				var bgTrees:FlxSprite = new FlxSprite(200, 50);
				bgTrees.frames = Paths.getSparrowAtlas("erect/bgtrees", 'week2');
				bgTrees.antialiasing = true;
				bgTrees.scrollFactor.set(0.8, 0.8);
				bgTrees.animation.addByPrefix("bgtrees", "bgtrees", 5, true);
				bgTrees.animation.play("bgtrees");
				add(bgTrees);

				var bgDark:FlxSprite = new FlxSprite(-560, -220).loadGraphic(Paths.image("erect/bgDark", 'week2'));
				bgDark.antialiasing = true;
				add(bgDark);

				bgLight = new FlxSprite(-560, -220).loadGraphic(Paths.image("erect/bgLight", 'week2'));
				bgLight.antialiasing = true;
				bgLight.alpha = 0.00000001;
				add(bgLight);

		// adjust this value so that the rain looks nice
		rainShader.scale = FlxG.height / 200 * 2;
		rainShader.intensity = 0.4;
		rainShader.spriteMode = true;

		rainShaderTarget = bgTrees;
		rainShaderTarget.shader = rainShader;
		rainShaderTarget.animation.callback = function(name:String, frameNumber:Int, frameIndex:Int)
		{
		rainShader.updateFrameInfo(rainShaderTarget.frame);
		}
			}
			case 'pico' | 'blammed' | 'philly': 
					{
					curStage = 'philly';
					currentCameraZoom = 1.1;

					var bg:FlxSprite = new FlxSprite(-100, 0).loadGraphic(Paths.image('philly/erect/sky', 'week3'));
					bg.antialiasing = true;
					bg.scrollFactor.set(0.1, 0.1);
					add(bg);

					var city:FlxSprite = new FlxSprite(-255, 45).loadGraphic(Paths.image('philly/erect/city', 'week3'));
					city.scrollFactor.set(0.3, 0.3);
					city.scale.set(0.9, 0.9);
					city.updateHitbox();
					city.antialiasing = true;
					add(city);

					phillyCityLights = new FlxTypedGroup<FlxSprite>();
					add(phillyCityLights);

					lightShader = new BuildingEffectShader(1.0);

					var light0:FlxSprite = new FlxSprite(-255, 45).loadGraphic(Paths.image('philly/erect/win0', 'week3'));
					light0.scrollFactor.set(0.3, 0.3);
					light0.shader = lightShader;
					light0.visible = false;
					light0.scale.set(0.9, 0.9);
					light0.updateHitbox();
					light0.antialiasing = true;
					phillyCityLights.add(light0);

					var light1:FlxSprite = new FlxSprite(-255, 45).loadGraphic(Paths.image('philly/erect/win1', 'week3'));
					light1.scrollFactor.set(0.3, 0.3);
					light1.shader = lightShader;
					light1.visible = false;
					light1.scale.set(0.9, 0.9);
					light1.updateHitbox();
					light1.antialiasing = true;
					phillyCityLights.add(light1);

					var light2:FlxSprite = new FlxSprite(-255, 45).loadGraphic(Paths.image('philly/erect/win2', 'week3'));
					light2.scrollFactor.set(0.3, 0.3);
					light2.shader = lightShader;
					light2.visible = false;
					light2.scale.set(0.9, 0.9);
					light2.updateHitbox();
					light2.antialiasing = true;
					phillyCityLights.add(light2);

					var light3:FlxSprite = new FlxSprite(-255, 45).loadGraphic(Paths.image('philly/erect/win3', 'week3'));
					light3.scrollFactor.set(0.3, 0.3);
					light3.shader = lightShader;
					light3.visible = false;
					light3.scale.set(0.9, 0.9);
					light3.updateHitbox();
					light3.antialiasing = true;
					phillyCityLights.add(light3);

					var light4:FlxSprite = new FlxSprite(-255, 45).loadGraphic(Paths.image('philly/erect/win4', 'week3'));
					light4.scrollFactor.set(0.3, 0.3);
					light4.shader = lightShader;
					light4.visible = false;
					light4.scale.set(0.9, 0.9);
					light4.updateHitbox();
					light4.antialiasing = true;
					phillyCityLights.add(light4);

					var behindTrain:FlxSprite = new FlxSprite(-299, 144).loadGraphic(Paths.image('philly/erect/behindTrain', 'week3'));
					behindTrain.antialiasing = true;
					add(behindTrain);

					train = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train', 'week3'));
					train.antialiasing = true;
					add(train);

					var colorShader = new AdjustColorShader();
					colorShader.hue = -26;
					colorShader.saturation = -16;
					colorShader.contrast = 0;
					colorShader.brightness = -5;
					train.shader = colorShader;

					trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
					FlxG.sound.list.add(trainSound);

					var street:FlxSprite = new FlxSprite(-299, 144).loadGraphic(Paths.image('philly/erect/street', 'week3'));
					street.antialiasing = true;
					add(street);
			}
			case 'satin-panties' | 'high':
			{
					curStage = 'limo';
					currentCameraZoom = 0.9;

					var limoSunset:FlxSprite = new FlxSprite(-220, -80).loadGraphic(Paths.image('limo/erect/limoSunset', 'week4'));
					limoSunset.scrollFactor.set(0.1, 0.1);
					limoSunset.scale.set(0.9, 0.9);
					limoSunset.updateHitbox();
					limoSunset.antialiasing = true;
					add(limoSunset);

					mist5 = new FlxBackdrop(Paths.image('limo/erect/mistMid', 'week4'), X);
					mist5.setPosition(-650, -400);
					mist5.scrollFactor.set(0.2, 0.2);
					mist5.blend = ADD;
					mist5.color = 0xFFE7A480;
					mist5.alpha = 1;
					mist5.velocity.x = 100;
					mist5.scale.set(1.5, 1.5);
					add(mist5);

					shootingStar = new FlxSprite(200, 0);
					shootingStar.frames = Paths.getSparrowAtlas("limo/erect/shooting star", 'week4');
					shootingStar.scrollFactor.set(0.12, 0.12);
					shootingStar.antialiasing = true;
					shootingStar.animation.addByPrefix('star', "shooting star", 24, false);
					shootingStar.animation.play('star', true);
					shootingStar.visible = false;
					shootingStar.blend = ADD;
					add(shootingStar);

					var bgLimo:FlxSprite = new FlxSprite(-200, 480);
					bgLimo.frames = Paths.getSparrowAtlas('limo/erect/bgLimo', 'week4');
					bgLimo.animation.addByPrefix('drive', "background limo blue", 24);
					bgLimo.animation.play('drive');
					bgLimo.scrollFactor.set(0.4, 0.4);
					add(bgLimo);

					grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
					add(grpLimoDancers);

					var colorShader = new AdjustColorShader();
					colorShader.hue = -30;
					colorShader.saturation = -20;
					colorShader.contrast = 0;
					colorShader.brightness = -30;

					for (i in 0...5)
					{
							var dancer:BackgroundDancer = new BackgroundDancer(100 + (300 * i), 100);
							dancer.scrollFactor.set(0.4, 0.4);
							dancer.shader = colorShader;
							grpLimoDancers.add(dancer);
					}

					mist4 = new FlxBackdrop(Paths.image('limo/erect/mistBack', 'week4'), X);
					mist4.setPosition(-650, -380);
					mist4.scrollFactor.set(0.6, 0.6);
					mist4.blend = ADD;
					mist4.color = 0xFF9c77c7;
					mist4.alpha = 1;
					mist4.velocity.x = 700;
					mist4.scale.set(1.5, 1.5);
					add(mist4);

					mist3 = new FlxBackdrop(Paths.image('limo/erect/mistMid', 'week4'), X);
					mist3.setPosition(-650, -100);
					mist3.scrollFactor.set(0.8, 0.8);
					mist3.blend = ADD;
					mist3.color = 0xFFa7d9be;
					mist3.alpha = 0.5;
					mist3.velocity.x = 900;
					mist3.scale.set(1.5, 1.5);
					add(mist3);

					var limoTex = Paths.getSparrowAtlas('limo/erect/limoDrive', 'week4');

					limo = new FlxSprite(-120, 520);
					limo.frames = limoTex;
					limo.animation.addByPrefix('drive', "Limo stage", 24);
					limo.animation.play('drive');
					limo.antialiasing = true;

					fastCar = new FlxSprite(-12600, 160).loadGraphic(Paths.image('limo/fastCarLol', 'week4'));
					fastCar.shader = colorShader;
					// add(limo);
			}
			case 'cocoa' | 'eggnog':
			{
					curStage = 'mall';
					currentCameraZoom = 0.8;

					var bgWalls:FlxSprite = new FlxSprite(-726, -566).loadGraphic(Paths.image('christmas/erect/bgWalls', 'week5'));
					bgWalls.antialiasing = true;
					bgWalls.scrollFactor.set(0.2, 0.2);
					bgWalls.scale.set(0.9, 0.9);
					bgWalls.updateHitbox();
					add(bgWalls);

					upperBoppers = new FlxSprite(-374, -98);
					upperBoppers.frames = Paths.getSparrowAtlas('christmas/erect/upperBop', 'week5');
					upperBoppers.animation.addByPrefix('bop', "upperBop", 24, false);
					upperBoppers.antialiasing = true;
					upperBoppers.scrollFactor.set(0.28, 0.28);
					upperBoppers.scale.set(0.85, 0.85);
					upperBoppers.updateHitbox();
					add(upperBoppers);

					var bgEscalator:FlxSprite = new FlxSprite(-1100, -540).loadGraphic(Paths.image('christmas/erect/bgEscalator', 'week5'));
					bgEscalator.antialiasing = true;
					bgEscalator.scrollFactor.set(0.3, 0.3);
					bgEscalator.scale.set(0.9, 0.9);
					bgEscalator.updateHitbox();
					add(bgEscalator);

					var christmasTree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/erect/christmasTree', 'week5'));
					christmasTree.antialiasing = true;
					christmasTree.scrollFactor.set(0.4, 0.4);
					add(christmasTree);

					var fog:FlxSprite = new FlxSprite(-1000, 100).loadGraphic(Paths.image('christmas/erect/white', 'week5'));
					fog.antialiasing = true;
					fog.scrollFactor.set(0.85, 0.85);
					fog.scale.set(0.9, 0.9);
					fog.updateHitbox();
					add(fog);

					bottomBoppers = new FlxSprite(-410, 100);
					bottomBoppers.frames = Paths.getSparrowAtlas('christmas/erect/bottomBop', 'week5');
					bottomBoppers.animation.addByPrefix('bop', 'bottomBop', 24, false);
					bottomBoppers.antialiasing = true;
					bottomBoppers.scrollFactor.set(0.9, 0.9);
					add(bottomBoppers);

					var snowUnder = new FlxSprite(-1500, 800).makeGraphic(1, 1, 0xFFF3F4F5);
					snowUnder.scale.set(5700, 3000);
					snowUnder.updateHitbox();
					add(snowUnder);

					var fgSnow:FlxSprite = new FlxSprite(-1350, 680).loadGraphic(Paths.image('christmas/fgSnow', 'week5'));
					fgSnow.antialiasing = true;
					add(fgSnow);

					santa = new FlxSprite(-840, 150);
					santa.frames = Paths.getSparrowAtlas('christmas/santa', 'week5');
					santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
					santa.antialiasing = true;
					add(santa);
			}
			case 'senpai' | 'roses':
			{
					curStage = 'school';

					currentCameraZoom = 1;

					var sky = new FlxSprite(-626, -78).loadGraphic(Paths.image('weeb/erect/weebSky', 'week6'));
					sky.scrollFactor.set(0.2, 0.2);
					add(sky);

					var backTrees:FlxSprite = new FlxSprite(-842, -80).loadGraphic(Paths.image('weeb/erect/weebBackTrees', 'week6'));
					backTrees.scrollFactor.set(0.5, 0.5);
					add(backTrees);

					var school:FlxSprite = new FlxSprite(-816, -38).loadGraphic(Paths.image('weeb/erect/weebSchool', 'week6'));
					school.scrollFactor.set(0.75, 0.75);
					add(school);

					var street:FlxSprite = new FlxSprite(-662, 6).loadGraphic(Paths.image('weeb/erect/weebStreet', 'week6'));
					add(street);

					var treesFG:FlxSprite = new FlxSprite(-500, 6).loadGraphic(Paths.image('weeb/erect/weebTreesBack', 'week6'));
					add(treesFG);

					var treesBG:FlxSprite = new FlxSprite(-806, -1050);
					var treetex = Paths.getPackerAtlas('weeb/erect/weebTrees', 'week6');
					treesBG.frames = treetex;
					treesBG.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
					treesBG.animation.play('treeLoop');
					add(treesBG);

					var petals:FlxSprite = new FlxSprite(-20, -40);
					petals.frames = Paths.getSparrowAtlas('weeb/erect/petals', 'week6');
					petals.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
					petals.animation.play('leaves');
					petals.scrollFactor.set(0.85, 0.85);
					add(petals);

					sky.scale.set(6, 6);
					backTrees.scale.set(6, 6);
					school.scale.set(6, 6);
					street.scale.set(6, 6);
					treesFG.scale.set(6, 6);
					treesBG.scale.set(6, 6);
					petals.scale.set(6, 6);

					sky.updateHitbox();
					backTrees.updateHitbox();
					school.updateHitbox();
					street.updateHitbox();
					treesFG.updateHitbox();
					treesBG.updateHitbox();
					petals.updateHitbox();
			}
			case 'thorns':
			{
					curStage = 'schoolEvil';

					currentCameraZoom = 1;

					var solid = new FlxSprite(-500, -1000).makeGraphic(1, 1, 0xFF000000);
					solid.scrollFactor.set(0, 0);
					solid.scale.set(2400, 2000);
					solid.updateHitbox();
					add(solid);

					var backspikes:FlxSprite = new FlxSprite(-842, -180).loadGraphic(Paths.image('weeb/erect/evil/weebBackSpikes', 'week6'));
					backspikes.scrollFactor.set(0.5, 0.5);
					backspikes.scale.set(6, 6);
					backspikes.updateHitbox();
					add(backspikes);

					var school:FlxSprite = new FlxSprite(-816, -38).loadGraphic(Paths.image('weeb/erect/evil/weebSchool', 'week6'));
					school.scrollFactor.set(0.75, 0.75);
					school.scale.set(6, 6);
					school.updateHitbox();
					add(school);

					var backspike:FlxSprite = new FlxSprite(1416, 464).loadGraphic(Paths.image('weeb/erect/evil/backSpike', 'week6'));
					backspike.scrollFactor.set(0.85, 0.85);
					backspike.scale.set(6, 6);
					backspike.updateHitbox();
					add(backspike);

					var evilstreet:FlxSprite = new FlxSprite(-662, 6).loadGraphic(Paths.image('weeb/erect/evil/weebStreet', 'week6'));
					evilstreet.scrollFactor.set(1, 1);
					evilstreet.scale.set(6, 6);
					evilstreet.updateHitbox();
					add(evilstreet);

					wiggleBack = new WiggleEffectRuntime(2 * 0.8, 4 * 0.4, 0.011, WiggleEffectType.DREAMY);
					wiggleSchool = new WiggleEffectRuntime(2, 4, 0.017, WiggleEffectType.DREAMY);
					wiggleSpike = new WiggleEffectRuntime(2, 4, 0.01, WiggleEffectType.DREAMY);
					wiggleGround = new WiggleEffectRuntime(2, 4, 0.007, WiggleEffectType.DREAMY);

					school.shader = wiggleSchool;
					evilstreet.shader = wiggleGround;
					backspikes.shader = wiggleBack;
					backspike.shader = wiggleSpike;
			}
			case 'ugh':
			{
					curStage = 'tank';

					currentCameraZoom = 0.7;

					var bg = new FlxSprite(-985, -805).loadGraphic(Paths.image('erect/bg', 'week7'));
					bg.antialiasing = true;
					bg.scale.set(1.15, 1.15);
					bg.updateHitbox();
					add(bg);

					sniper = new FlxSprite(-127, 349);
					sniper.frames = Paths.getSparrowAtlas('erect/sniper', 'week7');
					sniper.antialiasing = true;
					sniper.scale.set(1.15, 1.15);
					sniper.updateHitbox();
					sniper.animation.addByPrefix("idle", "Tankmanidlebaked instance 1", 24, false);
					sniper.animation.addByPrefix("sip", "tanksippingBaked instance 1", 24, false);
					sniper.animation.play("idle");
					add(sniper);

					guy = new FlxSprite(1398, 407);
					guy.frames = Paths.getSparrowAtlas('erect/guy', 'week7');
					guy.antialiasing = true;
					guy.scale.set(1.15, 1.15);
					guy.updateHitbox();
					guy.animation.addByPrefix("idle", "BLTank2 instance 1", 24, false);
					guy.animation.play("idle");
					add(guy);
			}
			case 'darnell':
			{
					curStage = 'phillyStreets';

					currentCameraZoom = 0.77;

					scrollingSky = new FlxTiledSprite(Paths.image('phillyStreets/erect/phillySkybox', 'weekend1'), 2922, 718, true, false);
					scrollingSky.setPosition(-650, -375);
					scrollingSky.scrollFactor.set(0.1, 0.1);
					scrollingSky.scale.set(0.65, 0.65);
					add(scrollingSky);

					var phillySkyline = new FlxSprite(-545, -273).loadGraphic(Paths.image("phillyStreets/erect/phillySkyline", 'weekend1'));
					phillySkyline.scrollFactor.set(0.2, 0.2);
					phillySkyline.antialiasing = true;
					add(phillySkyline);

					var phillyForegroundCity = new FlxSprite(600, 69).loadGraphic(Paths.image("phillyStreets/erect/phillyForegroundCity", 'weekend1'));
					phillyForegroundCity.scrollFactor.set(0.3, 0.3);
					phillyForegroundCity.antialiasing = true;
					add(phillyForegroundCity);

					var phillyForegroundCity2 = new FlxSprite(1860, 185).loadGraphic(Paths.image("phillyStreets/erect/phillyForegroundCity", 'weekend1'));
					phillyForegroundCity2.scrollFactor.set(0.3, 0.3);
					phillyForegroundCity2.antialiasing = true;
					phillyForegroundCity2.angle = 5;
					phillyForegroundCity2.flipX = true;
					add(phillyForegroundCity2);

					mist5 = new FlxBackdrop(Paths.image('phillyStreets/erect/mistMid', 'weekend1'), X);
					mist5.setPosition(-650, -100);
					mist5.scrollFactor.set(0.5, 0.5);
					mist5.blend = ADD;
					mist5.color = 0xFF5c5c5c;
					mist5.alpha = 1;
					mist5.velocity.x = 20;
					mist5.scale.set(1.1, 1.1);
					add(mist5);

					var phillyConstruction2 = new FlxSprite(1795, 360).loadGraphic(Paths.image("phillyStreets/erect/phillyConstruction", 'weekend1'));
					phillyConstruction2.scrollFactor.set(0.7, 1);
					phillyConstruction2.antialiasing = true;
					add(phillyConstruction2);

					var phillyHighwayLights = new FlxSprite(122, 201).loadGraphic(Paths.image("phillyStreets/erect/phillyHighwayLights", 'weekend1'));
					phillyHighwayLights.scrollFactor.set(0.8, 0.8);
					phillyHighwayLights.antialiasing = true;
					add(phillyHighwayLights);

					var phillyHighwayLights_lightmap = new FlxSprite(122, 201).loadGraphic(Paths.image("phillyStreets/phillyHighwayLights_lightmap", 'weekend1'));
					phillyHighwayLights_lightmap.scrollFactor.set(0.8, 0.8);
					phillyHighwayLights_lightmap.antialiasing = true;
					phillyHighwayLights_lightmap.blend = ADD;
					phillyHighwayLights_lightmap.alpha = 0.6;
					add(phillyHighwayLights_lightmap);

					var phillyHighway2 = new FlxSprite(-23, 105).loadGraphic(Paths.image("phillyStreets/erect/phillyHighway", 'weekend1'));
					phillyHighway2.scrollFactor.set(0.8, 0.8);
					phillyHighway2.antialiasing = true;
					add(phillyHighway2);

					phillyCars2 = new FlxSprite(1200, 818);
					phillyCars2.frames = Paths.getSparrowAtlas("phillyStreets/erect/phillyCars", 'weekend1');
					phillyCars2.scrollFactor.set(0.9, 1);
					phillyCars2.antialiasing = true;
					phillyCars2.flipX = true;
					phillyCars2.animation.addByPrefix("car1", "car1", 0, false);
					phillyCars2.animation.addByPrefix("car2", "car2", 0, false);
					phillyCars2.animation.addByPrefix("car3", "car3", 0, false);
					phillyCars2.animation.addByPrefix("car4", "car4", 0, false);
					add(phillyCars2);

					phillyCars = new FlxSprite(1200, 818);
					phillyCars.frames = Paths.getSparrowAtlas("phillyStreets/erect/phillyCars", 'weekend1');
					phillyCars.scrollFactor.set(0.9, 1);
					phillyCars.antialiasing = true;
					phillyCars.animation.addByPrefix("car1", "car1", 0, false);
					phillyCars.animation.addByPrefix("car2", "car2", 0, false);
					phillyCars.animation.addByPrefix("car3", "car3", 0, false);
					phillyCars.animation.addByPrefix("car4", "car4", 0, false);
					add(phillyCars);

					mist4 = new FlxBackdrop(Paths.image('phillyStreets/erect/mistBack', 'weekend1'), X);
					mist4.setPosition(-650, -100);
					mist4.scrollFactor.set(0.8, 0.8);
					mist4.blend = ADD;
					mist4.color = 0xFF5c5c5c;
					mist4.alpha = 1;
					mist4.velocity.x = 40;
					mist4.scale.set(0.7, 0.7);
					add(mist4);

					phillyTraffic = new FlxSprite(1840, 608);
					phillyTraffic.frames = Paths.getSparrowAtlas("phillyStreets/erect/phillyTraffic", 'weekend1');
					phillyTraffic.scrollFactor.set(0.9, 1);
					phillyTraffic.antialiasing = true;
					phillyTraffic.animation.addByPrefix("togreen", "redtogreen", 24, false);
					phillyTraffic.animation.addByPrefix("tored", "greentored", 24, false);
					add(phillyTraffic);
					phillyTraffic.animation.play('togreen');

					var phillyTraffic_lightmap = new FlxSprite(1840, 608).loadGraphic(Paths.image("phillyStreets/erect/phillyTraffic_lightmap", 'weekend1'));
					phillyTraffic_lightmap.scrollFactor.set(0.9, 1);
					phillyTraffic_lightmap.antialiasing = true;
					phillyTraffic_lightmap.blend = ADD;
					phillyTraffic_lightmap.alpha = 0.6;
					add(phillyTraffic_lightmap);

					var grey1 = new FlxSprite(-388, 7).loadGraphic(Paths.image("phillyStreets/erect/greyGradient", 'weekend1'));
					grey1.antialiasing = true;
					grey1.scale.set(1.3, 1.3);
					grey1.updateHitbox();
					grey1.blend = ADD;
					grey1.alpha = 0.3;
					add(grey1);

					var grey2 = new FlxSprite(-388, 7).loadGraphic(Paths.image("phillyStreets/erect/greyGradient", 'weekend1'));
					grey2.antialiasing = true;
					grey2.scale.set(1.3, 1.3);
					grey2.updateHitbox();
					grey2.blend = MULTIPLY;
					grey2.alpha = 0.8;
					add(grey2);

					mist3 = new FlxBackdrop(Paths.image('phillyStreets/erect/mistMid', 'weekend1'), X);
					mist3.setPosition(-650, -100);
					mist3.scrollFactor.set(0.95, 0.95);
					mist3.blend = ADD;
					mist3.color = 0xFF5c5c5c;
					mist3.alpha = 0.5;
					mist3.velocity.x = -50;
					mist3.scale.set(0.8, 0.8);
					add(mist3);

					var phillyForeground = new FlxSprite(88, 317).loadGraphic(Paths.image("phillyStreets/erect/phillyForeground", 'weekend1'));
					phillyForeground.antialiasing = true;
					add(phillyForeground);

					resetCar(true, true);

					setupRainShader();
			}
			default:
			{
					currentCameraZoom = 0.85;
					curStage = 'stage';
					var solid = new FlxSprite(-500, -1000).makeGraphic(1, 1, 0xFF222026);
					solid.scrollFactor.set(0, 0);
					solid.scale.set(2400, 2000);
					solid.updateHitbox();
					add(solid);

					var crowd:FlxSprite = new FlxSprite(682, 290);
					crowd.frames = Paths.getSparrowAtlas("erect/crowd", 'week1');
					crowd.antialiasing = true;
					crowd.scrollFactor.set(0.8, 0.8);
					crowd.animation.addByPrefix("idle", "idle0", 12, true);
					crowd.animation.play("idle");
					add(crowd);

					var brightLightSmall:FlxSprite = new FlxSprite(967, -103).loadGraphic(Paths.image("erect/brightLightSmall", 'week1'));
					brightLightSmall.antialiasing = true;
					brightLightSmall.blend = BlendMode.ADD;
					brightLightSmall.scrollFactor.set(1.2, 1.2);
					add(brightLightSmall);

					var bg:FlxSprite = new FlxSprite(-765, -247).loadGraphic(Paths.image("erect/bg", 'week1'));
					bg.antialiasing = true;
					add(bg);

					var server:FlxSprite = new FlxSprite(-991, 205).loadGraphic(Paths.image("erect/server", 'week1'));
					server.antialiasing = true;
					add(server);

					var lightgreen:FlxSprite = new FlxSprite(-171, 242).loadGraphic(Paths.image("erect/lightgreen", 'week1'));
					lightgreen.antialiasing = true;
					lightgreen.blend = BlendMode.ADD;
					add(lightgreen);

					var lightred:FlxSprite = new FlxSprite(-101, 560).loadGraphic(Paths.image("erect/lightred", 'week1'));
					lightred.antialiasing = true;
					lightred.blend = BlendMode.ADD;
					add(lightred);

					var orangeLight:FlxSprite = new FlxSprite(189, -500).loadGraphic(Paths.image("erect/orangeLight", 'week1'));
					orangeLight.antialiasing = true;
					orangeLight.scale.set(1, 1.2);
					orangeLight.blend = BlendMode.ADD;
					add(orangeLight);
			}
		}
		stageZoom = currentCameraZoom;

		var gfVersion:String = 'gf';

		switch (curStage)
		{
			case 'spooky':
				gfVersion = 'gf-dark';
			case 'limo':
				gfVersion = 'gf-car';
			case 'mall':
				gfVersion = 'gf-christmas';
			case 'school':
				gfVersion = 'gf-pixel';
			case 'schoolEvil':
				gfVersion = 'gf-pixel';
			case 'tank':
				gfVersion = 'gf-tankmen';
			case 'phillyStreets':
				gfVersion = 'nene';
		}

		PauseSubState.musicSuffix = '';

		gf = new Character(400, 130, gfVersion);

		dad = new Character(100, 100, SONG.player2);
		
		boyfriend = new Boyfriend(770, 450, SONG.player1);

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'schoolEvil':
				// trailArea.scrollFactor.set();

				//var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
				// evilTrail.changeValuesEnabled(false, false, false, false);
				// evilTrail.changeGraphic()
				//add(evilTrail);
				// evilTrail.scrollFactor.set(1.1, 1.1);

				var evilTrail = new FunkTrail(dad, null, 4, 24, 0.3, 0.069);
				add(evilTrail);
		}

		boyfriend.updateHitbox();
		dad.updateHitbox();
		gf.updateHitbox();

		switch (curStage)
		{
			case 'stage':
				boyfriend.x = 977.5 - boyfriend.characterOrigin.x;
				boyfriend.y = 865 - boyfriend.characterOrigin.y;
				dad.x = 40 - dad.characterOrigin.x;
				dad.y = 850 - dad.characterOrigin.y;
				gf.x = 501.5 - gf.characterOrigin.x;
				gf.y = 825 - gf.characterOrigin.y;
			case 'spooky':
				boyfriend.x = 1250 - boyfriend.characterOrigin.x;
				boyfriend.y = 835 - boyfriend.characterOrigin.y;
				dad.x = 382 - dad.characterOrigin.x;
				dad.y = 831 - dad.characterOrigin.y;
				gf.x = 821.5 - gf.characterOrigin.x;
				gf.y = 800 - gf.characterOrigin.y;
			case 'philly':
				boyfriend.x = 1020.5 - boyfriend.characterOrigin.x;
				boyfriend.y = 885 - boyfriend.characterOrigin.y;
				dad.x = 468 - dad.characterOrigin.x;
				dad.y = 885 - dad.characterOrigin.y;
				gf.x = 751.5 - gf.characterOrigin.x;
				gf.y = 787 - gf.characterOrigin.y;
			case 'limo':
				boyfriend.x = 1217.5 - boyfriend.characterOrigin.x;
				boyfriend.y = 592 - boyfriend.characterOrigin.y;
				dad.x = 329.5 - dad.characterOrigin.x;
				dad.y = 913 - dad.characterOrigin.y;
				gf.x = 787 - gf.characterOrigin.x;
				gf.y = 779 - gf.characterOrigin.y;
			case 'mall':
				boyfriend.x = 1177.5 - boyfriend.characterOrigin.x;
				boyfriend.y = 871 - boyfriend.characterOrigin.y;
				dad.x = 42 - dad.characterOrigin.x;
				dad.y = 882 - dad.characterOrigin.y;
				gf.x = 808.5 - gf.characterOrigin.x;
				gf.y = 854 - gf.characterOrigin.y;
			case 'school':
				boyfriend.x = 1168 - boyfriend.characterOrigin.x;
				boyfriend.y = 900 - boyfriend.characterOrigin.y;
				dad.x = 306 - dad.characterOrigin.x;
				dad.y = 960 - dad.characterOrigin.y;
				gf.x = 724 - gf.characterOrigin.x;
				gf.y = 763 - gf.characterOrigin.y;
			case 'schoolEvil':
				boyfriend.x = 1168 - boyfriend.characterOrigin.x;
				boyfriend.y = 900 - boyfriend.characterOrigin.y;
				dad.x = 0 - dad.characterOrigin.x;
				dad.y = 648 - dad.characterOrigin.y;
				gf.x = 724 - gf.characterOrigin.x;
				gf.y = 823 - gf.characterOrigin.y;
			case 'tank':
				boyfriend.x = 1340.5 - boyfriend.characterOrigin.x;
				boyfriend.y = 885 - boyfriend.characterOrigin.y;
				dad.x = 230.5 - dad.characterOrigin.x;
				dad.y = 996 - dad.characterOrigin.y;
				gf.x = 800.5 - gf.characterOrigin.x;
				gf.y = 775 - gf.characterOrigin.y;
			case 'phillyStreets':
				boyfriend.x = 2151 - boyfriend.characterOrigin.x;
				boyfriend.y = 1228 - boyfriend.characterOrigin.y;
				dad.x = 920 - dad.characterOrigin.x;
				dad.y = 1310 - dad.characterOrigin.y;
				gf.x = 1520 - gf.characterOrigin.x;
				gf.y = 1080 - gf.characterOrigin.y;
		}

		boyfriend.originalPosition.set(boyfriend.x, boyfriend.y);
		dad.originalPosition.set(dad.x, dad.y);
		gf.originalPosition.set(gf.x, gf.y);

		boyfriend.x += boyfriend.globalOffsets[0];
		boyfriend.y += boyfriend.globalOffsets[1];
		dad.x += dad.globalOffsets[0];
		dad.y += dad.globalOffsets[1];
		gf.x += gf.globalOffsets[0];
		gf.y += gf.globalOffsets[1];

		boyfriend.resetCameraFocusPoint();
		dad.resetCameraFocusPoint();
		gf.resetCameraFocusPoint();

		switch (curStage)
		{
			case 'stage':
				boyfriend.cameraFocusPoint.x += -170;
				boyfriend.cameraFocusPoint.y += -140;
				dad.cameraFocusPoint.x += 270;
				dad.cameraFocusPoint.y += -100;
				gf.cameraFocusPoint.x += 0;
				gf.cameraFocusPoint.y += 0;
			case 'spooky':
				boyfriend.cameraFocusPoint.x += -100;
				boyfriend.cameraFocusPoint.y += -100;
				dad.cameraFocusPoint.x += 150;
				dad.cameraFocusPoint.y += -100;
				gf.cameraFocusPoint.x += 0;
				gf.cameraFocusPoint.y += 0;
			case 'philly':
				boyfriend.cameraFocusPoint.x += -200;
				boyfriend.cameraFocusPoint.y += -100;
				dad.cameraFocusPoint.x += 200;
				dad.cameraFocusPoint.y += -100;
				gf.cameraFocusPoint.x += 0;
				gf.cameraFocusPoint.y += 0;
			case 'limo':
				boyfriend.cameraFocusPoint.x += -300;
				boyfriend.cameraFocusPoint.y += -100;
				dad.cameraFocusPoint.x += 150;
				dad.cameraFocusPoint.y += 0;
				gf.cameraFocusPoint.x += 0;
				gf.cameraFocusPoint.y += 0;
			case 'mall':
				boyfriend.cameraFocusPoint.x += -300;
				boyfriend.cameraFocusPoint.y += -200;
				dad.cameraFocusPoint.x += 150;
				dad.cameraFocusPoint.y += -100;
				gf.cameraFocusPoint.x += 0;
				gf.cameraFocusPoint.y += 0;
			case 'school':
				boyfriend.cameraFocusPoint.x += -200;
				boyfriend.cameraFocusPoint.y += -94;
				dad.cameraFocusPoint.x += 160;
				dad.cameraFocusPoint.y += 0;
				gf.cameraFocusPoint.x += 40;
				gf.cameraFocusPoint.y += 40;
			case 'schoolEvil':
				boyfriend.cameraFocusPoint.x += -200;
				boyfriend.cameraFocusPoint.y += -94;
				dad.cameraFocusPoint.x += 440;
				dad.cameraFocusPoint.y += 270;
				gf.cameraFocusPoint.x += 40;
				gf.cameraFocusPoint.y += 40;
			case 'tank':
				boyfriend.cameraFocusPoint.x += -220;
				boyfriend.cameraFocusPoint.y += -100;
				dad.cameraFocusPoint.x += 250;
				dad.cameraFocusPoint.y += -100;
				gf.cameraFocusPoint.x += 0;
				gf.cameraFocusPoint.y += 0;
			case 'phillyStreets':
				boyfriend.cameraFocusPoint.x += -350;
				boyfriend.cameraFocusPoint.y += -100;
				dad.cameraFocusPoint.x += 500;
				dad.cameraFocusPoint.y += -100;
				gf.cameraFocusPoint.x += 0;
				gf.cameraFocusPoint.y += 0;
		}

		var camPos:FlxPoint = new FlxPoint(dad.cameraFocusPoint.x, dad.cameraFocusPoint.y);

		switch (curStage)
		{
			case 'phillyStreets':
				abot = new ABotSpeaker(gf.x, gf.y);
				abot.lookRight();
				abot.eyes.anim.curFrame = abot.eyes.anim.length - 1;
				add(abot);
		}

		if(gf.normalChar != null)
		add(gf.normalChar);
		add(gf);

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		if(dad.normalChar != null)
		add(dad.normalChar);
		add(dad);
		if(boyfriend.normalChar != null)
		add(boyfriend.normalChar);
		add(boyfriend);

		if (curStage == 'stage')
		{
		var lights:FlxSprite = new FlxSprite(-847, -245).loadGraphic(Paths.image("erect/lights", 'week1'));
		lights.antialiasing = true;
		lights.scrollFactor.set(1.2, 1.2);
		add(lights);
		
		var lightAbove:FlxSprite = new FlxSprite(804, -117).loadGraphic(Paths.image("erect/lightAbove", 'week1'));
		lightAbove.antialiasing = true;
		lightAbove.blend = BlendMode.ADD;
		add(lightAbove);

		var colorShaderBf = new AdjustColorShader();
		var colorShaderDad = new AdjustColorShader();
		var colorShaderGf = new AdjustColorShader();

		colorShaderBf.brightness = -23;
		colorShaderBf.hue = 12;
		colorShaderBf.contrast = 7;
		colorShaderBf.saturation = 0;

		colorShaderGf.brightness = -30;
		colorShaderGf.hue = -9;
		colorShaderGf.contrast = -4;
		colorShaderGf.saturation = 0;

		colorShaderDad.brightness = -33;
		colorShaderDad.hue = -32;
		colorShaderDad.contrast = -23;
		colorShaderDad.saturation = 0;

		boyfriend.shader = colorShaderBf;
		gf.shader = colorShaderGf;
		dad.shader = colorShaderDad;
		}

		if (curStage == 'spooky')
		{
		var stairsDark:FlxSprite = new FlxSprite(966, -225).loadGraphic(Paths.image("erect/stairsDark", 'week2'));
		stairsDark.antialiasing = true;
		add(stairsDark);

		stairsLight = new FlxSprite(966, -225).loadGraphic(Paths.image("erect/stairsLight", 'week2'));
		stairsLight.antialiasing = true;
		stairsLight.alpha = 0.00000001;
		add(stairsLight);
		}

		if (curStage == 'philly')
		{
		var shader = new AdjustColorShader();

		shader.hue = -26;
		shader.saturation = -16;
		shader.contrast = 0;
		shader.brightness = -5;

		boyfriend.shader = shader;
		gf.shader = shader;
		dad.shader = shader;
		}

		if (curStage == 'limo')
		{
		var colorShader = new AdjustColorShader();
		colorShader.hue = -30;
		colorShader.saturation = -20;
		colorShader.contrast = 0;
		colorShader.brightness = -30;

		boyfriend.shader = colorShader;
		gf.shader = colorShader;
		dad.shader = colorShader;

		mist1 = new FlxBackdrop(Paths.image('limo/erect/mistMid', 'week4'), X);
		mist1.setPosition(-650, -100);
		mist1.scrollFactor.set(1.1, 1.1);
		mist1.blend = ADD;
		mist1.color = 0xFFc6bfde;
		mist1.alpha = 0.4;
		mist1.velocity.x = 1700;
		add(mist1);

		mist2 = new FlxBackdrop(Paths.image('limo/erect/mistBack', 'week4'), X);
		mist2.setPosition(-650, -100);
		mist2.scrollFactor.set(1.2, 1.2);
		mist2.blend = ADD;
		mist2.color = 0xFF6a4da1;
		mist2.alpha = 1;
		mist2.velocity.x = 2100;
		mist1.scale.set(1.3, 1.3);
		add(mist2);

		resetFastCar();
		add(fastCar);
		}

		if (curStage == 'mall')
		{
		var colorShader = new AdjustColorShader();
		colorShader.hue = 5;
		colorShader.saturation = 20;

		santa.shader = colorShader;

		boyfriend.shader = colorShader;
		gf.shader = colorShader;
		dad.shader = colorShader;

		parentsShoot = new FlxAnimate();
		Paths.loadAnimateAtlas(parentsShoot, 'christmas/parents_shoot_assets');
		parentsShoot.anim.addBySymbol('shootthisbitch', 'parents whole scene', 24, false);
		parentsShoot.anim.play('shootthisbitch');
		parentsShoot.x = -516;
		parentsShoot.y = 503;
		add(parentsShoot);
		parentsShoot.antialiasing = true;
		parentsShoot.shader = santa.shader;
		parentsShoot.alpha = 0.00000001;

		santaDead = new FlxAnimate();
		Paths.loadAnimateAtlas(santaDead, 'christmas/santa_speaks_assets');
		santaDead.anim.addBySymbol('talkAnim', 'santa whole scene', 24, false);
		santaDead.anim.play('talkAnim');
		santaDead.x = -458;
		santaDead.y = 498;
		add(santaDead);
		santaDead.antialiasing = true;
		santaDead.shader = santa.shader;
		santaDead.alpha = 0.00000001;
		}

		if (curStage == 'school')
		{
		var rimBf = new DropShadowShader();
		rimBf.setAdjustColor(-66, -10, 24, -23);
		rimBf.color = 0xFF52351d;
		rimBf.antialiasAmt = 0;
		rimBf.attachedSprite = boyfriend;
		rimBf.distance = 5;

		rimBf.angle = 90;
		boyfriend.shader = rimBf;

		rimBf.loadAltMask('assets/week6/images/weeb/erect/masks/bfPixel_mask.png');
		rimBf.maskThreshold = 1;
		rimBf.useAltMask = true;

		boyfriend.animation.callback = function(name:String, frameNumber:Int, frameIndex:Int)
		{
		if (boyfriend != null)
		{
		rimBf.updateFrameInfo(boyfriend.frame);
		}
		}

		var rimGf = new DropShadowShader();
		rimGf.setAdjustColor(-66, -10, 24, -23);
		rimGf.color = 0xFF52351d;
		rimGf.antialiasAmt = 0;
		rimGf.attachedSprite = gf;
		rimGf.distance = 5;

		rimGf.setAdjustColor(-42, -10, 5, -25);
		rimGf.angle = 90;
		gf.shader = rimGf;
		rimGf.distance = 3;
		rimGf.threshold = 0.3;

		rimGf.loadAltMask('assets/week6/images/weeb/erect/masks/gfPixel_mask.png');
		rimGf.maskThreshold = 1;
		rimGf.useAltMask = true;

		gf.animation.callback = function(name:String, frameNumber:Int, frameIndex:Int)
		{
		if (gf != null)
		{
		rimGf.updateFrameInfo(gf.frame);
		}
		}

		var rimDad = new DropShadowShader();
		rimDad.setAdjustColor(-66, -10, 24, -23);
		rimDad.color = 0xFF52351d;
		rimDad.antialiasAmt = 0;
		rimDad.attachedSprite = dad;
		rimDad.distance = 5;

		rimDad.angle = 90;
		dad.shader = rimDad;

		rimDad.loadAltMask('assets/week6/images/weeb/erect/masks/senpai_mask.png');
		rimDad.maskThreshold = 1;
		rimDad.useAltMask = true;

		dad.animation.callback = function(name:String, frameNumber:Int, frameIndex:Int)
		{
		if (dad != null)
		{
		rimDad.updateFrameInfo(dad.frame);
		}
		}
		}

		if (curStage == 'tank')
		{
		var tankBricks = new FlxSprite(465, 760).loadGraphic(Paths.image('erect/bricksGround', 'week7'));
		tankBricks.antialiasing = true;
		tankBricks.flipX = true;
		tankBricks.scale.set(1.15, 1.15);
		tankBricks.updateHitbox();
		add(tankBricks);

		var rimBf = new DropShadowShader();
		rimBf.setAdjustColor(-46, -38, -25, -20);
		rimBf.color = 0xFFDFEF3C;
		boyfriend.shader = rimBf;
		rimBf.attachedSprite = boyfriend;

		rimBf.angle = 90;

		boyfriend.animation.callback = function(name:String, frameNumber:Int, frameIndex:Int)
		{
		if (boyfriend != null)
		{
		rimBf.updateFrameInfo(boyfriend.frame);
		}
		}

		var rimGf = new DropShadowShader();
		rimGf.setAdjustColor(-46, -38, -25, -20);
		rimGf.color = 0xFFDFEF3C;
		gf.shader = rimGf;
		rimGf.attachedSprite = gf;

		rimGf.angle = 90;

		gf.animation.callback = function(name:String, frameNumber:Int, frameIndex:Int)
		{
		if (gf != null)
		{
		rimGf.updateFrameInfo(gf.frame);
		}
		}

		if (gf.curCharacter == 'gf-tankmen')
		{
		rimGf.loadAltMask('assets/week7/images/erect/masks/gfTankmen_mask.png');
		rimGf.maskThreshold = 0.4;
		rimGf.useAltMask = true;
		}

		var rimDad = new DropShadowShader();
		rimDad.setAdjustColor(-46, -38, -25, -20);
		rimDad.color = 0xFFDFEF3C;
		dad.shader = rimDad;
		rimDad.attachedSprite = dad;

		rimDad.angle = 135;
		rimDad.threshold = 0.3;

		dad.animation.callback = function(name:String, frameNumber:Int, frameIndex:Int)
		{
		if (dad != null)
		{
		rimDad.updateFrameInfo(dad.frame);
		}
		}
		}

		if (curStage == 'phillyStreets')
		{
		var paper = new FlxSprite(350, 608);
		paper.frames = Paths.getSparrowAtlas('phillyStreets/erect/paper', 'weekend1');
		paper.scrollFactor.set(1.1, 1.1);
		paper.antialiasing = true;
		paper.animation.addByPrefix('paperBlow', "Paper Blowing instance 1", 24, false);
		paper.animation.play('paperBlow', true);
		paper.alpha = 0;
		add(paper);

		mist0 = new FlxBackdrop(Paths.image('phillyStreets/erect/mistMid', 'weekend1'), X);
		mist0.setPosition(-650, -100);
		mist0.scrollFactor.set(1.2, 1.2);
		mist0.blend = ADD;
		mist0.color = 0xFF5c5c5c;
		mist0.alpha = 0.6;
		mist0.velocity.x = 172;
		add(mist0);

		mist1 = new FlxBackdrop(Paths.image('phillyStreets/erect/mistMid', 'weekend1'), X);
		mist1.setPosition(-650, -100);
		mist1.scrollFactor.set(1.1, 1.1);
		mist1.blend = ADD;
		mist1.color = 0xFF5c5c5c;
		mist1.alpha = 0.6;
		mist1.velocity.x = 150;
		add(mist1);

		mist2 = new FlxBackdrop(Paths.image('phillyStreets/erect/mistBack', 'weekend1'), X);
		mist2.setPosition(-650, -100);
		mist2.scrollFactor.set(1.2, 1.2);
		mist2.blend = ADD;
		mist2.color = 0xFF5c5c5c;
		mist2.alpha = 0.8;
		mist2.velocity.x = -80;
		add(mist2);

		var colorShader = new AdjustColorShader();
		colorShader.hue = -5;
		colorShader.saturation = -40;
		colorShader.contrast = -25;
		colorShader.brightness = -20;

		boyfriend.shader = colorShader;
		gf.shader = colorShader;
		dad.shader = colorShader;
		}

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();
		
		if (FlxG.save.data.downscroll)
			strumLine.y = FlxG.height - 165;

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();

		// startCountdown();

		generateSong(SONG.song);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		cameraSpeed = 0.04 * (30 / (cast (Lib.current.getChildAt(0), Main)).getFPS());
		FlxG.camera.follow(camFollow, LOCKON, cameraSpeed);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = currentCameraZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		if (FlxG.save.data.songPosition) // I dont wanna talk about this code :(
			{
				songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar'));
				if (FlxG.save.data.downscroll)
					songPosBG.y = FlxG.height * 0.9 + 45; 
				songPosBG.screenCenter(X);
				songPosBG.scrollFactor.set();
				add(songPosBG);
				
				songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
					'songPositionBar', 0, 90000);
				songPosBar.scrollFactor.set();
				songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
				add(songPosBar);
	
				var songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - 20,songPosBG.y,0,SONG.song, 16);
				if (FlxG.save.data.downscroll)
					songName.y -= 3;
				songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
				songName.scrollFactor.set();
				add(songName);
				songName.cameras = [camHUD];
			}

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		if (FlxG.save.data.downscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		// healthBar
		add(healthBar);

		// Add Kade Engine watermark
		kadeEngineWatermark = new FlxText(4,healthBarBG.y + 50,0,SONG.song + " " + (storyDifficulty == 2 ? "Nightmare" : storyDifficulty == 1 ? "Erect" : "Easy") + (Main.watermarks ? " - KE " + MainMenuState.kadeEngineVer : ""), 16);
		kadeEngineWatermark.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		kadeEngineWatermark.scrollFactor.set();
		add(kadeEngineWatermark);

		if (FlxG.save.data.downscroll)
			kadeEngineWatermark.y = FlxG.height * 0.9 + 45;

		scoreTxt = new FlxText(FlxG.width / 2 - 235, healthBarBG.y + 50, 0, "", 20);
		if (!FlxG.save.data.accuracyDisplay)
			scoreTxt.x = healthBarBG.x + healthBarBG.width / 2;
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		if (offsetTesting)
			scoreTxt.x += 300;
		add(scoreTxt);

		replayTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (FlxG.save.data.downscroll ? 100 : -100), 0, "REPLAY", 20);
		replayTxt.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		replayTxt.scrollFactor.set();
		if (loadRep)
			{
				add(replayTxt);
			}

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		if (FlxG.save.data.songPosition)
		{
			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
		}
		kadeEngineWatermark.cameras = [camHUD];
		if (loadRep)
			replayTxt.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;
		
			switch (curSong.toLowerCase())
			{
				default:
					startCountdown();
			}

		if (!loadRep)
			rep = new Replay("na");

		super.create();
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	function startCountdown():Void
	{
		inCutscene = false;

		generateStaticArrows(0);
		generateStaticArrows(1);

		if (executeModchart) // dude I hate lua (jkjkjkjk)
			{
				trace('opening a lua state (because we are cool :))');
				lua = LuaL.newstate();
				LuaL.openlibs(lua);
				trace("Lua version: " + Lua.version());
				trace("LuaJIT version: " + Lua.versionJIT());
				Lua.init_callbacks(lua);
				
				var result = LuaL.dofile(lua, Paths.lua(PlayState.SONG.song.toLowerCase() + "/modchart")); // execute le file
	
				if (result != 0)
					trace('COMPILE ERROR\n' + getLuaErrorMessage(lua));

				// get some fukin globals up in here bois
	
				setVar("bpm", Conductor.bpm);
				setVar("fpsCap", FlxG.save.data.fpsCap);
				setVar("downscroll", FlxG.save.data.downscroll);
	
				setVar("curStep", 0);
				setVar("curBeat", 0);
	
				setVar("hudZoom", camHUD.zoom);
				setVar("cameraZoom", FlxG.camera.zoom);
	
				setVar("cameraAngle", FlxG.camera.angle);
				setVar("camHudAngle", camHUD.angle);
	
				setVar("followXOffset",0);
				setVar("followYOffset",0);
	
				setVar("showOnlyStrums", false);
				setVar("strumLine1Visible", true);
				setVar("strumLine2Visible", true);
	
				setVar("screenWidth",FlxG.width);
				setVar("screenHeight",FlxG.height);
				setVar("hudWidth", camHUD.width);
				setVar("hudHeight", camHUD.height);
	
				// callbacks
	
				// sprites
	
				trace(Lua_helper.add_callback(lua,"makeSprite", makeLuaSprite));
	
				Lua_helper.add_callback(lua,"destroySprite", function(id:String) {
					var sprite = luaSprites.get(id);
					if (sprite == null)
						return false;
					remove(sprite);
					return true;
				});
	
				// hud/camera
	
				trace(Lua_helper.add_callback(lua,"setHudPosition", function (x:Int, y:Int) {
					camHUD.x = x;
					camHUD.y = y;
				}));
	
				trace(Lua_helper.add_callback(lua,"getHudX", function () {
					return camHUD.x;
				}));
	
				trace(Lua_helper.add_callback(lua,"getHudY", function () {
					return camHUD.y;
				}));
				
				trace(Lua_helper.add_callback(lua,"setCamPosition", function (x:Int, y:Int) {
					FlxG.camera.x = x;
					FlxG.camera.y = y;
				}));
	
				trace(Lua_helper.add_callback(lua,"getCameraX", function () {
					return FlxG.camera.x;
				}));
	
				trace(Lua_helper.add_callback(lua,"getCameraY", function () {
					return FlxG.camera.y;
				}));
	
				trace(Lua_helper.add_callback(lua,"setCamZoom", function(zoomAmount:Int) {
					FlxG.camera.zoom = zoomAmount;
				}));
	
				trace(Lua_helper.add_callback(lua,"setHudZoom", function(zoomAmount:Int) {
					camHUD.zoom = zoomAmount;
				}));
	
				// actors
				
				trace(Lua_helper.add_callback(lua,"getRenderedNotes", function() {
					return notes.length;
				}));
	
				trace(Lua_helper.add_callback(lua,"getRenderedNoteX", function(id:Int) {
					return notes.members[id].x;
				}));
	
				trace(Lua_helper.add_callback(lua,"getRenderedNoteY", function(id:Int) {
					return notes.members[id].y;
				}));
	
				trace(Lua_helper.add_callback(lua,"getRenderedNoteScaleX", function(id:Int) {
					return notes.members[id].scale.x;
				}));
	
				trace(Lua_helper.add_callback(lua,"getRenderedNoteScaleY", function(id:Int) {
					return notes.members[id].scale.y;
				}));
	
				trace(Lua_helper.add_callback(lua,"getRenderedNoteAlpha", function(id:Int) {
					return notes.members[id].alpha;
				}));
	
				trace(Lua_helper.add_callback(lua,"setRenderedNotePos", function(x:Int,y:Int, id:Int) {
					notes.members[id].modifiedByLua = true;
					notes.members[id].x = x;
					notes.members[id].y = y;
				}));
	
				trace(Lua_helper.add_callback(lua,"setRenderedNoteAlpha", function(alpha:Float, id:Int) {
					notes.members[id].modifiedByLua = true;
					notes.members[id].alpha = alpha;
				}));
	
				trace(Lua_helper.add_callback(lua,"setRenderedNoteScale", function(scale:Float, id:Int) {
					notes.members[id].modifiedByLua = true;
					notes.members[id].setGraphicSize(Std.int(notes.members[id].width * scale));
				}));
	
				trace(Lua_helper.add_callback(lua,"setRenderedNoteScaleX", function(scale:Float, id:Int) {
					notes.members[id].modifiedByLua = true;
					notes.members[id].scale.x = scale;
				}));
	
				trace(Lua_helper.add_callback(lua,"setRenderedNoteScaleY", function(scale:Float, id:Int) {
					notes.members[id].modifiedByLua = true;
					notes.members[id].scale.y = scale;
				}));
	
				trace(Lua_helper.add_callback(lua,"setActorX", function(x:Int,id:String) {
					getActorByName(id).x = x;
				}));
	
				trace(Lua_helper.add_callback(lua,"setActorAlpha", function(alpha:Int,id:String) {
					getActorByName(id).alpha = alpha;
				}));
	
				trace(Lua_helper.add_callback(lua,"setActorY", function(y:Int,id:String) {
					getActorByName(id).y = y;
				}));
							
				trace(Lua_helper.add_callback(lua,"setActorAngle", function(angle:Int,id:String) {
					getActorByName(id).angle = angle;
				}));
	
				trace(Lua_helper.add_callback(lua,"setActorScale", function(scale:Float,id:String) {
					getActorByName(id).setGraphicSize(Std.int(getActorByName(id).width * scale));
				}));
	
				trace(Lua_helper.add_callback(lua,"setActorScaleX", function(scale:Float,id:String) {
					getActorByName(id).scale.x = scale;
				}));
	
				trace(Lua_helper.add_callback(lua,"setActorScaleY", function(scale:Float,id:String) {
					getActorByName(id).scale.y = scale;
				}));
	
				trace(Lua_helper.add_callback(lua,"getActorWidth", function (id:String) {
					return getActorByName(id).width;
				}));
	
				trace(Lua_helper.add_callback(lua,"getActorHeight", function (id:String) {
					return getActorByName(id).height;
				}));
	
				trace(Lua_helper.add_callback(lua,"getActorAlpha", function(id:String) {
					return getActorByName(id).alpha;
				}));
	
				trace(Lua_helper.add_callback(lua,"getActorAngle", function(id:String) {
					return getActorByName(id).angle;
				}));
	
				trace(Lua_helper.add_callback(lua,"getActorX", function (id:String) {
					return getActorByName(id).x;
				}));
	
				trace(Lua_helper.add_callback(lua,"getActorY", function (id:String) {
					return getActorByName(id).y;
				}));
	
				trace(Lua_helper.add_callback(lua,"getActorScaleX", function (id:String) {
					return getActorByName(id).scale.x;
				}));
	
				trace(Lua_helper.add_callback(lua,"getActorScaleY", function (id:String) {
					return getActorByName(id).scale.y;
				}));
	
				// tweens
				
				Lua_helper.add_callback(lua,"tweenPos", function(id:String, toX:Int, toY:Int, time:Float, onComplete:String) {
					FlxTween.tween(getActorByName(id), {x: toX, y: toY}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,[id]);}}});
				});
	
				Lua_helper.add_callback(lua,"tweenPosXAngle", function(id:String, toX:Int, toAngle:Float, time:Float, onComplete:String) {
					FlxTween.tween(getActorByName(id), {x: toX, angle: toAngle}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,[id]);}}});
				});
	
				Lua_helper.add_callback(lua,"tweenPosYAngle", function(id:String, toY:Int, toAngle:Float, time:Float, onComplete:String) {
					FlxTween.tween(getActorByName(id), {y: toY, angle: toAngle}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,[id]);}}});
				});
	
				Lua_helper.add_callback(lua,"tweenAngle", function(id:String, toAngle:Int, time:Float, onComplete:String) {
					FlxTween.tween(getActorByName(id), {angle: toAngle}, time, {ease: FlxEase.cubeIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,[id]);}}});
				});
	
				Lua_helper.add_callback(lua,"tweenFadeIn", function(id:String, toAlpha:Int, time:Float, onComplete:String) {
					FlxTween.tween(getActorByName(id), {alpha: toAlpha}, time, {ease: FlxEase.circIn, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,[id]);}}});
				});
	
				Lua_helper.add_callback(lua,"tweenFadeOut", function(id:String, toAlpha:Int, time:Float, onComplete:String) {
					FlxTween.tween(getActorByName(id), {alpha: toAlpha}, time, {ease: FlxEase.circOut, onComplete: function(flxTween:FlxTween) { if (onComplete != '' && onComplete != null) {callLua(onComplete,[id]);}}});
				});
	
				for (i in 0...strumLineNotes.length) {
					var member = strumLineNotes.members[i];
					trace(strumLineNotes.members[i].x + " " + strumLineNotes.members[i].y + " " + strumLineNotes.members[i].angle + " | strum" + i);
					//setVar("strum" + i + "X", Math.floor(member.x));
					setVar("defaultStrum" + i + "X", Math.floor(member.x));
					//setVar("strum" + i + "Y", Math.floor(member.y));
					setVar("defaultStrum" + i + "Y", Math.floor(member.y));
					//setVar("strum" + i + "Angle", Math.floor(member.angle));
					setVar("defaultStrum" + i + "Angle", Math.floor(member.angle));
					trace("Adding strum" + i);
				}
	
				trace('calling start function');
	
				trace('return: ' + Lua.tostring(lua,callLua('start', [PlayState.SONG.song])));
			}

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.dance();
			gf.dance();
			if (abot != null)
			{
			abot.speaker.anim.play('anim', true);
			abot.speaker.anim.curFrame = 1;
			}
			boyfriend.playAnim('idle');

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', [
				'weeb/pixelUI/ready-pixel',
				'weeb/pixelUI/set-pixel',
				'weeb/pixelUI/date-pixel'
			]);
			introAssets.set('schoolEvil', [
				'weeb/pixelUI/ready-pixel',
				'weeb/pixelUI/set-pixel',
				'weeb/pixelUI/date-pixel'
			]);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;


	var songStarted = false;

	function startSong():Void
	{
		startingSong = false;
		songStarted = true;
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
		{
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		}

		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		if (FlxG.save.data.songPosition)
		{
			remove(songPosBG);
			remove(songPosBar);
			remove(songName);

			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar'));
			if (FlxG.save.data.downscroll)
				songPosBG.y = FlxG.height * 0.9 + 45; 
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);

			songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, songLength - 1000);
			songPosBar.numDivisions = 1000;
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
			add(songPosBar);

			var songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - 20,songPosBG.y,0,SONG.song, 16);
			if (FlxG.save.data.downscroll)
				songName.y -= 3;
			songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
			songName.scrollFactor.set();
			add(songName);

			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
			songName.cameras = [camHUD];
		}

		allowedToHeadbang = false;

		#if windows
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " + generateRanking(), "\nAcc: " + truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC);
		#end

		if(abot != null)
		abot.snd = FlxG.sound.music;
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		// Per song offset check
		#if desktop
			var songPath = 'assets/data/' + PlayState.SONG.song.toLowerCase() + '/';
			for(file in sys.FileSystem.readDirectory(songPath))
			{
				var path = haxe.io.Path.join([songPath, file]);
				if(!sys.FileSystem.isDirectory(path))
				{
					if(path.endsWith('.offset'))
					{
						trace('Found offset file: ' + path);
						songOffset = Std.parseFloat(file.substring(0, file.indexOf('.off')));
						break;
					}else {
						trace('Offset file not found. Creating one @: ' + songPath);
						sys.io.File.saveContent(songPath + songOffset + '.offset', '');
					}
				}
			}
		#end
		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0] + FlxG.save.data.offset + songOffset;
				if (daStrumTime < 0)
					daStrumTime = 0;
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.sustainLength = songNotes[2];
				if(songNotes[3] != null)
				swagNote.noteType = songNotes[3];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;
					sustainNote.noteType = songNotes[3];

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else
				{
				}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

if(SONG.events != null && SONG.events.length > 0)
{
for (i in 0...SONG.events.length)
{
var time = SONG.events[i].t;
var eventKind = SONG.events[i].e;
var value = SONG.events[i].v;
		songEvents.push(new SongEventData(time,eventKind,value));
}
}

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);

			switch (curStage)
			{
				case 'school' | 'schoolEvil':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
					}

				default:
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.addByPrefix('static', 'arrowLEFT');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.addByPrefix('static', 'arrowDOWN');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.addByPrefix('static', 'arrowUP');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
					}
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			babyArrow.y -= 10;
			babyArrow.alpha = 0;
			FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});

			babyArrow.ID = i;

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			strumLineNotes.add(babyArrow);
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			#if windows
			DiscordClient.changePresence("PAUSED on " + SONG.song + " (" + storyDifficultyText + ") " + generateRanking(), "Acc: " + truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC);
			#end
			if (!startTimer.finished)
				startTimer.active = false;

			if (cameraFollowTween != null)
			{
			cameraFollowTween.active = false;
			}

			if (cameraZoomTween != null)
			{
			cameraZoomTween.active = false;
			}
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			if (cameraFollowTween != null)
			{
			cameraFollowTween.active = true;
			}

			if (cameraZoomTween != null)
			{
			cameraZoomTween.active = true;
			}

			if (curStage == 'phillyStreets')
			{
			resumeCars();
			}

			#if windows
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " + generateRanking(), "\nAcc: " + truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses, iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ") " + generateRanking(), iconRPC);
			}
			#end
		}

		super.closeSubState();
	}
	

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();

		#if windows
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " + generateRanking(), "\nAcc: " + truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC);
		#end
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	function truncateFloat( number : Float, precision : Int): Float {
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round( num ) / Math.pow(10, precision);
		return num;
		}


	function generateRanking():String
	{
		var ranking:String = "N/A";

		if (misses == 0 && bads == 0 && shits == 0 && goods == 0) // Marvelous (SICK) Full Combo
			ranking = "(MFC)";
		else if (misses == 0 && bads == 0 && shits == 0 && goods >= 1) // Good Full Combo (Nothing but Goods & Sicks)
			ranking = "(GFC)";
		else if (misses == 0) // Regular FC
			ranking = "(FC)";
		else if (misses < 10) // Single Digit Combo Breaks
			ranking = "(SDCB)";
		else
			ranking = "(Clear)";

		// WIFE TIME :)))) (based on Wife3)

		var wifeConditions:Array<Bool> = [
			accuracy >= 99.9935, // AAAAA
			accuracy >= 99.980, // AAAA:
			accuracy >= 99.970, // AAAA.
			accuracy >= 99.955, // AAAA
			accuracy >= 99.90, // AAA:
			accuracy >= 99.80, // AAA.
			accuracy >= 99.70, // AAA
			accuracy >= 99, // AA:
			accuracy >= 96.50, // AA.
			accuracy >= 93, // AA
			accuracy >= 90, // A:
			accuracy >= 85, // A.
			accuracy >= 80, // A
			accuracy >= 70, // B
			accuracy >= 60, // C
			accuracy < 60 // D
		];

		for(i in 0...wifeConditions.length)
		{
			var b = wifeConditions[i];
			if (b)
			{
				switch(i)
				{
					case 0:
						ranking += " AAAAA";
					case 1:
						ranking += " AAAA:";
					case 2:
						ranking += " AAAA.";
					case 3:
						ranking += " AAAA";
					case 4:
						ranking += " AAA:";
					case 5:
						ranking += " AAA.";
					case 6:
						ranking += " AAA";
					case 7:
						ranking += " AA:";
					case 8:
						ranking += " AA.";
					case 9:
						ranking += " AA";
					case 10:
						ranking += " A:";
					case 11:
						ranking += " A.";
					case 12:
						ranking += " A";
					case 13:
						ranking += " B";
					case 14:
						ranking += " C";
					case 15:
						ranking += " D";
				}
				break;
			}
		}

		if (accuracy == 0)
			ranking = "N/A";

		return ranking;
	}

	public static var songRate = 1.5;

	override public function update(elapsed:Float)
	{
		if(gf.curCharacter == 'nene')
		{
		transitionState();

		if(gf.animation.curAnim.finished)
		onAnimationFinished(gf.animation.curAnim.name);

		if(gf.animation.curAnim != null)
		onAnimationFrame(gf.animation.curAnim.name, gf.animation.curAnim.curFrame);
		}

		#if !debug
		perfectMode = false;
		#end

		if(lightShader != null)
		{
		var shaderInput:Float = (Conductor.crochet / 1000) * elapsed * 1.5;
		lightShader.update(shaderInput);
		}

		if (wiggleSchool != null) {
		wiggleSchool.update(elapsed);
		}

		if (wiggleGround != null) {
		wiggleGround.update(elapsed);
		}

		if (wiggleBack != null) {
		wiggleBack.update(elapsed);
		}

		if (wiggleSpike != null) {
		wiggleSpike.update(elapsed);
		}

		if (executeModchart && lua != null && songStarted)
		{
			setVar('songPos',Conductor.songPosition);
			setVar('hudZoom', camHUD.zoom);
			setVar('cameraZoom',FlxG.camera.zoom);
			callLua('update', [elapsed]);

			/*for (i in 0...strumLineNotes.length) {
				var member = strumLineNotes.members[i];
				member.x = getVar("strum" + i + "X", "float");
				member.y = getVar("strum" + i + "Y", "float");
				member.angle = getVar("strum" + i + "Angle", "float");
			}*/

			FlxG.camera.angle = getVar('cameraAngle', 'float');
			camHUD.angle = getVar('camHudAngle','float');

			if (getVar("showOnlyStrums",'bool'))
			{
				healthBarBG.visible = false;
				kadeEngineWatermark.visible = false;
				healthBar.visible = false;
				iconP1.visible = false;
				iconP2.visible = false;
				scoreTxt.visible = false;
			}
			else
			{
				healthBarBG.visible = true;
				kadeEngineWatermark.visible = true;
				healthBar.visible = true;
				iconP1.visible = true;
				iconP2.visible = true;
				scoreTxt.visible = true;
			}

			var p1 = getVar("strumLine1Visible",'bool');
			var p2 = getVar("strumLine2Visible",'bool');

			for (i in 0...4)
			{
				strumLineNotes.members[i].visible = p1;
				if (i <= playerStrums.length)
					playerStrums.members[i].visible = p2;
			}
		}

		if (currentFrames == FlxG.save.data.fpsCap)
		{
			for(i in 0...notesHitArray.length)
			{
				var cock:Date = notesHitArray[i];
				if (cock != null)
					if (cock.getTime() + 2000 < Date.now().getTime())
						notesHitArray.remove(cock);
			}
			nps = Math.floor(notesHitArray.length / 2);
			currentFrames = 0;
		}
		else
			currentFrames++;

		if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');
		}

		switch (curStage)
		{
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
			case 'limo':
			_timer += elapsed;
			mist1.y = 100 + (Math.sin(_timer)*200);
			mist2.y = 0 + (Math.sin(_timer*0.8)*100);
			mist3.y = -20 + (Math.sin(_timer*0.5)*200);
			mist4.y = -180 + (Math.sin(_timer*0.4)*300);
			mist5.y = -450 + (Math.sin(_timer*0.2)*150);
			case 'phillyStreets':
			_timer += elapsed;
			mist0.y = 660 + (Math.sin(_timer * 0.35) * 70);
			mist1.y = 500 + (Math.sin(_timer * 0.3) * 80);
			mist2.y = 540 + (Math.sin(_timer * 0.4) * 60);
			mist3.y = 230 + (Math.sin(_timer * 0.3) * 70);
			mist4.y = 170 + (Math.sin(_timer * 0.35) * 50);
			mist5.y = -80 + (Math.sin(_timer * 0.08) * 100);

		if(scrollingSky != null) scrollingSky.scrollX -= FlxG.elapsed * 22;

		if(rainShader != null)
		{
			if (FlxG.sound.music != null)
			{
			var remappedIntensityValue:Float = FlxMath.remapToRange(Conductor.songPosition, 0, FlxG.sound.music.length, rainShaderStartIntensity, rainShaderEndIntensity);
			rainShader.intensity = remappedIntensityValue;
			rainShader.updateViewInfo(FlxG.width, FlxG.height, FlxG.camera);
			}
			else
			{
			rainShader.intensity = rainShaderStartIntensity;
			rainShader.updateViewInfo(FlxG.width, FlxG.height, FlxG.camera);
			}
		}
		}

		if(rainShader != null)
		{
		rainShader.update(elapsed);
		}

		super.update(elapsed);

		if (!offsetTesting)
		{
			if (FlxG.save.data.accuracyDisplay)
			{
				scoreTxt.text = (FlxG.save.data.npsDisplay ? "NPS: " + nps + " | " : "") + "Score:" + (Conductor.safeFrames != 10 ? songScore + " (" + songScoreDef + ")" : "" + songScore) + " | Combo Breaks:" + misses + " | Accuracy:" + truncateFloat(accuracy, 2) + "% | " + generateRanking();
			}
			else
			{
				scoreTxt.text = (FlxG.save.data.npsDisplay ? "NPS: " + nps + " | " : "") + "Score:" + songScore;
			}
		}
		else
		{
			scoreTxt.text = "Suggested Offset: " + offsetTest;

		}
		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;
			if (curStage == 'phillyStreets')
			{
			pauseCars();
			}

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				// gitaroo man easter egg
				FlxG.switchState(new GitarooPause());
			}
			else
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			#if windows
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
			FlxG.switchState(new ChartingState());
			if (lua != null)
			{
				Lua.close(lua);
				lua = null;
			}
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		#if debug
		if (FlxG.keys.justPressed.EIGHT)
		{
			FlxG.switchState(new AnimationDebug(SONG.player2));
			if (lua != null)
			{
				Lua.close(lua);
				lua = null;
			}
		}
		
		#end

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;
			/*@:privateAccess
			{
				FlxG.sound.music._channel.
			}*/
			songPositionBar = Conductor.songPosition;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if(SONG.events == null)
			{
			if (camFollow.x != dad.cameraFocusPoint.x && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				if(abot != null)
				abot.lookLeft();
				camFollow.setPosition(dad.cameraFocusPoint.x, dad.cameraFocusPoint.y);
				// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

				if (dad.curCharacter == 'mom')
					vocals.volume = 1;
			}

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != boyfriend.cameraFocusPoint.x)
			{
				if(abot != null)
				abot.lookRight();
				camFollow.setPosition(boyfriend.cameraFocusPoint.x, boyfriend.cameraFocusPoint.y);
			}
			}
		}

		// Apply camera zoom + multipliers.
		if (subState == null && cameraZoomRate > 0.0) // && !inCutscene)
		{
			cameraBopMultiplier = FlxMath.lerp(1.0, cameraBopMultiplier, 0.95); // Lerp bop multiplier back to 1.0x
			var zoomPlusBop = currentCameraZoom * cameraBopMultiplier; // Apply camera bop multiplier.
			FlxG.camera.zoom = zoomPlusBop; // Actually apply the zoom to the camera.

			camHUD.zoom = FlxMath.lerp(defaultHUDCameraZoom, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);
		if (loadRep) // rep debug
			{
				FlxG.watch.addQuick('rep rpesses',repPresses);
				FlxG.watch.addQuick('rep releases',repReleases);
				// FlxG.watch.addQuick('Queued',inputsQueued);
			}

		if (health <= 0)
		{
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			openSubState(new GameOverSubstate(boyfriend.x, boyfriend.y));

			#if windows
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("GAME OVER -- " + SONG.song + " (" + storyDifficultyText + ") " + generateRanking(),"\nAcc: " + truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC);
			#end

			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
			{
				notes.forEachAlive(function(daNote:Note)
				{	
					if (daNote.y > FlxG.height)
					{
						daNote.active = false;
						daNote.visible = false;
					}
					else
					{
						daNote.visible = true;
						daNote.active = true;
					}
	
					if (!daNote.mustPress && daNote.wasGoodHit)
					{
						var altAnim:String = "";
	
						if (SONG.notes[Math.floor(curStep / 16)] != null)
						{
							if (SONG.notes[Math.floor(curStep / 16)].altAnim)
								altAnim = '-alt';
						}

						if(daNote.noteType == "mom" && dad.curCharacter == 'parents-christmas')
						altAnim = '-alt';

						dad.canPlayOtherAnims = true;
	
						switch (Math.abs(daNote.noteData))
						{
							case 2:
								dad.playAnim('singUP' + altAnim, true);
							case 3:
								dad.playAnim('singRIGHT' + altAnim, true);
							case 1:
								dad.playAnim('singDOWN' + altAnim, true);
							case 0:
								dad.playAnim('singLEFT' + altAnim, true);
						}
	
						dad.holdTimer = 0;
	
						if (SONG.needsVoices)
							vocals.volume = 1;
	
						daNote.active = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
	
					if (FlxG.save.data.downscroll)
						daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (-0.45 * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2)));
					else
						daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2)));

					if (daNote.mustPress && !daNote.modifiedByLua)
					{
						daNote.visible = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].visible;
						daNote.x = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x;
						if (!daNote.isSustainNote)
							daNote.angle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
						daNote.alpha = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					}
					else if (!daNote.wasGoodHit && !daNote.modifiedByLua)
					{
						daNote.visible = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].visible;
						daNote.x = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].x;
						if (!daNote.isSustainNote)
							daNote.angle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].angle;
						daNote.alpha = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					}

					if (daNote.isSustainNote)
						daNote.x += daNote.width / 2 + 17;
					

					//trace(daNote.y);
					// WIP interpolation shit? Need to fix the pause issue
					// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));
	
					if ((daNote.y < -daNote.height && !FlxG.save.data.downscroll || daNote.y >= strumLine.y + 106 && FlxG.save.data.downscroll) && daNote.mustPress)
					{
						if (daNote.isSustainNote && daNote.wasGoodHit)
						{
							daNote.kill();
							notes.remove(daNote, true);
							daNote.destroy();
						}
						else
						{
							health -= 0.075;
							vocals.volume = 0;
							if (theFunne)
								noteMiss(daNote.noteData, daNote);
						}
	
						daNote.active = false;
						daNote.visible = false;
	
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});
			}

		if (!inCutscene)
			keyShit();

		processSongEvents();

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
	}

	var hasPlayedCutscene:Bool = false;

	function endSong():Void
	{
		if(abot != null)
		abot.dumpSound();

		trainMoving = false;
		if(trainSound != null)
		{
		trainSound.stop();
		trainSound = null;
		}

		if (!hasPlayedCutscene && SONG.song.toLowerCase() == 'eggnog')
		{
		FlxG.sound.music.stop();
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		startCutscene();
		return;
		}

		if (!loadRep)
			rep.SaveReplay();

		if (executeModchart)
		{
			Lua.close(lua);
			lua = null;
		}

		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		if (SONG.validScore)
		{
			#if !switch
			Highscore.saveScore(SONG.song, Math.round(songScore), storyDifficulty);
			#end
		}

		if (offsetTesting)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			offsetTesting = false;
			LoadingState.loadAndSwitchState(new OptionsMenu());
			FlxG.save.data.offset = offsetTest;
		}
		else
		{
				trace('WENT BACK TO FREEPLAY??');
				FlxG.switchState(new FreeplayState());
		}
	}

  function startCutscene()
  {
    santa.visible = false;

    santaDead.alpha = 1;

    santaDead.anim.play('talkAnim');

    dad.visible = false;

    parentsShoot.alpha = 1;

    parentsShoot.anim.play('shootthisbitch');

    inCutscene = true;
    hasPlayedCutscene = true;

    tweenCameraToPosition(santaDead.x + 300, santaDead.y, 2.8, FlxEase.expoOut);
    tweenCameraZoom(0.73, 2, true, FlxEase.quadInOut);

    FlxG.sound.play(Paths.sound('santa_emotion'));

    new FlxTimer().start(2.8, function(tmr) {
      tweenCameraToPosition(santaDead.x + 150, santaDead.y, 9, FlxEase.quartInOut);
      tweenCameraZoom(0.79, 9, true, FlxEase.quadInOut);
    });

    new FlxTimer().start(11.375, function(tmr) {
      FlxG.sound.play(Paths.sound('santa_shot_n_falls'));
    });

    new FlxTimer().start(12.83, function(tmr) {
      tweenCameraToPosition(santaDead.x + 160, santaDead.y + 80, 5, FlxEase.expoOut);
    });

    new FlxTimer().start(15, function(tmr) {
      camHUD.fade(0xFF000000, 1, false, null, true);
    });

    new FlxTimer().start(16, function(tmr) {
        camHUD.fade(0xFF000000, 0.5, true, null, true);
        endSong();
    });
  }

	var endingSong:Bool = false;

	var hits:Array<Float> = [];
	var offsetTest:Float = 0;

	var timeShown = 0;
	var currentTimingShown:FlxText = null;

	private function popUpScore(daNote:Note):Void
		{
			var noteDiff:Float = Math.abs(Conductor.songPosition - daNote.strumTime);
			var wife:Float = EtternaFunctions.wife3(noteDiff, Conductor.timeScale);
			// boyfriend.playAnim('hey');
			vocals.volume = 1;
	
			var placement:String = Std.string(combo);
	
			var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
			coolText.screenCenter();
			coolText.x = FlxG.width * 0.55;
			coolText.y -= 350;
			coolText.cameras = [camHUD];
			//
	
			var rating:FlxSprite = new FlxSprite();
			var score:Float = 350;

			if (FlxG.save.data.accuracyMod == 1)
				totalNotesHit += wife;

			var daRating = daNote.rating;

			switch(daRating)
			{
				case 'shit':
					score = -300;
					if (combo > 70 && gf.animOffsets.exists('drop70'))
					{
					gf.canPlayOtherAnims = true;
					gf.playAnim('drop70', true);
					gf.canPlayOtherAnims = false;
					}
					combo = 0;
					misses++;
					health -= 0.2;
					ss = false;
					shits++;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 0.25;
				case 'bad':
					daRating = 'bad';
					score = 0;
					health -= 0.06;
					ss = false;
					bads++;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 0.50;
				case 'good':
					daRating = 'good';
					score = 200;
					ss = false;
					goods++;
					if (health < 2)
						health += 0.04;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 0.75;
				case 'sick':
					if (health < 2)
						health += 0.1;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit += 1;
					sicks++;
			}

			// trace('Wife accuracy loss: ' + wife + ' | Rating: ' + daRating + ' | Score: ' + score + ' | Weight: ' + (1 - wife));

			if (daRating != 'shit' || daRating != 'bad')
				{
	
	
			songScore += Math.round(score);
			songScoreDef += Math.round(ConvertScore.convertScore(noteDiff));
	
			/* if (combo > 60)
					daRating = 'sick';
				else if (combo > 12)
					daRating = 'good'
				else if (combo > 4)
					daRating = 'bad';
			 */
	
			var pixelShitPart1:String = "";
			var pixelShitPart2:String = '';
	
			if (curStage.startsWith('school'))
			{
				pixelShitPart1 = 'weeb/pixelUI/';
				pixelShitPart2 = '-pixel';
			}
	
			rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
			rating.screenCenter();
			rating.y -= 50;
			rating.x = coolText.x - 125;
			
			if (FlxG.save.data.changedHit)
			{
				rating.x = FlxG.save.data.changedHitX;
				rating.y = FlxG.save.data.changedHitY;
			}
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);
	
			
			var msTiming = truncateFloat(noteDiff, 3);

			if (currentTimingShown != null)
				remove(currentTimingShown);

			currentTimingShown = new FlxText(0,0,0,"0ms");
			timeShown = 0;
			switch(daRating)
			{
				case 'shit' | 'bad':
					currentTimingShown.color = FlxColor.RED;
				case 'good':
					currentTimingShown.color = FlxColor.GREEN;
				case 'sick':
					currentTimingShown.color = FlxColor.CYAN;
			}
			currentTimingShown.borderStyle = OUTLINE;
			currentTimingShown.borderSize = 1;
			currentTimingShown.borderColor = FlxColor.BLACK;
			currentTimingShown.text = msTiming + "ms";
			currentTimingShown.size = 20;

			if (msTiming >= 0.03 && offsetTesting)
			{
				//Remove Outliers
				hits.shift();
				hits.shift();
				hits.shift();
				hits.pop();
				hits.pop();
				hits.pop();
				hits.push(msTiming);

				var total = 0.0;

				for(i in hits)
					total += i;
				

				
				offsetTest = truncateFloat(total / hits.length,2);
			}

			if (currentTimingShown.alpha != 1)
				currentTimingShown.alpha = 1;

			add(currentTimingShown);
			


			var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
			comboSpr.screenCenter();
			comboSpr.x = rating.x;
			comboSpr.y = rating.y + 100;
			comboSpr.acceleration.y = 600;
			comboSpr.velocity.y -= 150;

			currentTimingShown.screenCenter();
			currentTimingShown.x = comboSpr.x + 100;
			currentTimingShown.y = rating.y + 100;
			currentTimingShown.acceleration.y = 600;
			currentTimingShown.velocity.y -= 150;
	
			comboSpr.velocity.x += FlxG.random.int(1, 10);
			currentTimingShown.velocity.x += comboSpr.velocity.x;
			add(rating);
	
			if (!curStage.startsWith('school'))
			{
				rating.setGraphicSize(Std.int(rating.width * 0.7));
				rating.antialiasing = true;
				comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
				comboSpr.antialiasing = true;
			}
			else
			{
				rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
				comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
			}
	
			currentTimingShown.updateHitbox();
			comboSpr.updateHitbox();
			rating.updateHitbox();
	
			currentTimingShown.cameras = [camHUD];
			comboSpr.cameras = [camHUD];
			rating.cameras = [camHUD];

			var seperatedScore:Array<Int> = [];
	
			var comboSplit:Array<String> = (combo + "").split('');

			if (comboSplit.length == 2)
				seperatedScore.push(0); // make sure theres a 0 in front or it looks weird lol!

			for(i in 0...comboSplit.length)
			{
				var str:String = comboSplit[i];
				seperatedScore.push(Std.parseInt(str));
			}
	
			var daLoop:Int = 0;
			for (i in seperatedScore)
			{
				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
				numScore.screenCenter();
				numScore.x = rating.x + (43 * daLoop) - 50;
				numScore.y = rating.y + 100;
				numScore.cameras = [camHUD];

				if (!curStage.startsWith('school'))
				{
					numScore.antialiasing = true;
					numScore.setGraphicSize(Std.int(numScore.width * 0.5));
				}
				else
				{
					numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
				}
				numScore.updateHitbox();
	
				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);
	
				if (combo >= 10 || combo == 0)
					add(numScore);
	
				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						numScore.destroy();
					},
					startDelay: Conductor.crochet * 0.002
				});
	
				daLoop++;
			}
			/* 
				trace(combo);
				trace(seperatedScore);
			 */
	
			coolText.text = Std.string(seperatedScore);
			// add(coolText);
	
			FlxTween.tween(rating, {alpha: 0}, 0.2, {
				startDelay: Conductor.crochet * 0.001,
				onUpdate: function(tween:FlxTween)
				{
					if (currentTimingShown != null)
						currentTimingShown.alpha -= 0.02;
					timeShown++;
				}
			});

			FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					coolText.destroy();
					comboSpr.destroy();
					if (currentTimingShown != null && timeShown >= 20)
					{
						remove(currentTimingShown);
						currentTimingShown = null;
					}
					rating.destroy();
				},
				startDelay: Conductor.crochet * 0.001
			});
	
			curSection += 1;
			}
		}

	public function NearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool
		{
			return Math.abs(FlxMath.roundDecimal(value1, 1) - FlxMath.roundDecimal(value2, 1)) < unimportantDifference;
		}

		var upHold:Bool = false;
		var downHold:Bool = false;
		var rightHold:Bool = false;
		var leftHold:Bool = false;	

	private function keyShit():Void
	{
		// HOLDING
		var up = controls.UP;
		var right = controls.RIGHT;
		var down = controls.DOWN;
		var left = controls.LEFT;

		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		var upR = controls.UP_R;
		var rightR = controls.RIGHT_R;
		var downR = controls.DOWN_R;
		var leftR = controls.LEFT_R;

		if (loadRep) // replay code
		{
			// disable input
			up = false;
			down = false;
			right = false;
			left = false;

			// new input


			//if (rep.replay.keys[repPresses].time == Conductor.songPosition)
			//	trace('DO IT!!!!!');

			//timeCurrently = Math.abs(rep.replay.keyPresses[repPresses].time - Conductor.songPosition);
			//timeCurrentlyR = Math.abs(rep.replay.keyReleases[repReleases].time - Conductor.songPosition);

			
			if (repPresses < rep.replay.keyPresses.length && repReleases < rep.replay.keyReleases.length)
			{
				upP = rep.replay.keyPresses[repPresses].time + 1 <= Conductor.songPosition  && rep.replay.keyPresses[repPresses].key == "up";
				rightP = rep.replay.keyPresses[repPresses].time + 1 <= Conductor.songPosition && rep.replay.keyPresses[repPresses].key == "right";
				downP = rep.replay.keyPresses[repPresses].time + 1 <= Conductor.songPosition && rep.replay.keyPresses[repPresses].key == "down";
				leftP = rep.replay.keyPresses[repPresses].time + 1 <= Conductor.songPosition  && rep.replay.keyPresses[repPresses].key == "left";	

				upR = rep.replay.keyPresses[repReleases].time - 1 <= Conductor.songPosition && rep.replay.keyReleases[repReleases].key == "up";
				rightR = rep.replay.keyPresses[repReleases].time - 1 <= Conductor.songPosition  && rep.replay.keyReleases[repReleases].key == "right";
				downR = rep.replay.keyPresses[repReleases].time - 1<= Conductor.songPosition && rep.replay.keyReleases[repReleases].key == "down";
				leftR = rep.replay.keyPresses[repReleases].time - 1<= Conductor.songPosition && rep.replay.keyReleases[repReleases].key == "left";

				upHold = upP ? true : upR ? false : true;
				rightHold = rightP ? true : rightR ? false : true;
				downHold = downP ? true : downR ? false : true;
				leftHold = leftP ? true : leftR ? false : true;
			}
		}
		else if (!loadRep) // record replay code
		{
			if (upP)
				rep.replay.keyPresses.push({time: Conductor.songPosition, key: "up"});
			if (rightP)
				rep.replay.keyPresses.push({time: Conductor.songPosition, key: "right"});
			if (downP)
				rep.replay.keyPresses.push({time: Conductor.songPosition, key: "down"});
			if (leftP)
				rep.replay.keyPresses.push({time: Conductor.songPosition, key: "left"});

			if (upR)
				rep.replay.keyReleases.push({time: Conductor.songPosition, key: "up"});
			if (rightR)
				rep.replay.keyReleases.push({time: Conductor.songPosition, key: "right"});
			if (downR)
				rep.replay.keyReleases.push({time: Conductor.songPosition, key: "down"});
			if (leftR)
				rep.replay.keyReleases.push({time: Conductor.songPosition, key: "left"});
		}
		var controlArray:Array<Bool> = [leftP, downP, upP, rightP];

		// FlxG.watch.addQuick('asdfa', upP);
		if ((upP || rightP || downP || leftP) && !boyfriend.stunned && generatedMusic)
			{
				repPresses++;
				boyfriend.holdTimer = 0;
	
				var possibleNotes:Array<Note> = [];
	
				var ignoreList:Array<Int> = [];
	
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
					{
						// the sorting probably doesn't need to be in here? who cares lol
						possibleNotes.push(daNote);
						possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
	
						ignoreList.push(daNote.noteData);
					}
				});
	
				
				if (possibleNotes.length > 0)
				{
					var daNote = possibleNotes[0];
	
					// Jump notes
					if (possibleNotes.length >= 2)
					{
						if (possibleNotes[0].strumTime == possibleNotes[1].strumTime)
						{
							for (coolNote in possibleNotes)
							{

								if (controlArray[coolNote.noteData])
									goodNoteHit(coolNote);
								else
								{
									var inIgnoreList:Bool = false;
									for (shit in 0...ignoreList.length)
									{
										if (controlArray[ignoreList[shit]])
											inIgnoreList = true;
									}
								}
							}
						}
						else if (possibleNotes[0].noteData == possibleNotes[1].noteData)
						{
							if (loadRep)
							{
								var noteDiff:Float = Math.abs(daNote.strumTime - Conductor.songPosition);

								daNote.rating = Ratings.CalculateRating(noteDiff);

								if (NearlyEquals(daNote.strumTime,rep.replay.keyPresses[repPresses].time, 30))
								{
									goodNoteHit(daNote);
									trace('force note hit');
								}
								else
									noteCheck(controlArray, daNote);
							}
							else
								noteCheck(controlArray, daNote);
						}
						else
						{
							for (coolNote in possibleNotes)
							{
								if (loadRep)
									{
										if (NearlyEquals(coolNote.strumTime,rep.replay.keyPresses[repPresses].time, 30))
										{
											var noteDiff:Float = Math.abs(coolNote.strumTime - Conductor.songPosition);

											if (noteDiff > Conductor.safeZoneOffset * 0.70 || noteDiff < Conductor.safeZoneOffset * -0.70)
												coolNote.rating = "shit";
											else if (noteDiff > Conductor.safeZoneOffset * 0.50 || noteDiff < Conductor.safeZoneOffset * -0.50)
												coolNote.rating = "bad";
											else if (noteDiff > Conductor.safeZoneOffset * 0.45 || noteDiff < Conductor.safeZoneOffset * -0.45)
												coolNote.rating = "good";
											else if (noteDiff < Conductor.safeZoneOffset * 0.44 && noteDiff > Conductor.safeZoneOffset * -0.44)
												coolNote.rating = "sick";
											goodNoteHit(coolNote);
											trace('force note hit');
										}
										else
											noteCheck(controlArray, daNote);
									}
								else
									noteCheck(controlArray, coolNote);
							}
						}
					}
					else // regular notes?
					{	
						if (loadRep)
						{
							if (NearlyEquals(daNote.strumTime,rep.replay.keyPresses[repPresses].time, 30))
							{
								var noteDiff:Float = Math.abs(daNote.strumTime - Conductor.songPosition);

								daNote.rating = Ratings.CalculateRating(noteDiff);

								goodNoteHit(daNote);
								trace('force note hit');
							}
							else
								noteCheck(controlArray, daNote);
						}
						else
							noteCheck(controlArray, daNote);
					}
					/* 
						if (controlArray[daNote.noteData])
							goodNoteHit(daNote);
					 */
					// trace(daNote.noteData);
					/* 
						switch (daNote.noteData)
						{
							case 2: // NOTES YOU JUST PRESSED
								if (upP || rightP || downP || leftP)
									noteCheck(upP, daNote);
							case 3:
								if (upP || rightP || downP || leftP)
									noteCheck(rightP, daNote);
							case 1:
								if (upP || rightP || downP || leftP)
									noteCheck(downP, daNote);
							case 0:
								if (upP || rightP || downP || leftP)
									noteCheck(leftP, daNote);
						}
					 */
					if (daNote.wasGoodHit)
					{
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				}
			}
	
			if ((up || right || down || left) && generatedMusic || (upHold || downHold || leftHold || rightHold) && loadRep && generatedMusic)
			{
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && daNote.isSustainNote)
					{
						switch (daNote.noteData)
						{
							// NOTES YOU ARE HOLDING
							case 2:
								if (up || upHold)
									goodNoteHit(daNote);
							case 3:
								if (right || rightHold)
									goodNoteHit(daNote);
							case 1:
								if (down || downHold)
									goodNoteHit(daNote);
							case 0:
								if (left || leftHold)
									goodNoteHit(daNote);
						}
					}
				});
			}
	
			if (boyfriend.holdTimer > Conductor.stepCrochet * 8.0 * 0.001 && !up && !down && !right && !left)
			{
				if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
				{
					boyfriend.playAnim('idle');
				}
			}
	
				playerStrums.forEach(function(spr:FlxSprite)
				{
					switch (spr.ID)
					{
						case 2:
							if (loadRep)
							{
							}
							else
							{
								if (upP && spr.animation.curAnim.name != 'confirm' && !loadRep)
								{
									spr.animation.play('pressed');
									trace('play');
								}
								if (upR)
								{
									spr.animation.play('static');
									repReleases++;
								}
							}
						case 3:
							if (loadRep)
								{
								}
							else
							{
								if (rightP && spr.animation.curAnim.name != 'confirm' && !loadRep)
									spr.animation.play('pressed');
								if (rightR)
								{
									spr.animation.play('static');
									repReleases++;
								}
							}	
						case 1:
							if (loadRep)
								{
								}
							else
							{
								if (downP && spr.animation.curAnim.name != 'confirm' && !loadRep)
									spr.animation.play('pressed');
								if (downR)
								{
									spr.animation.play('static');
									repReleases++;
								}
							}
						case 0:
							if (loadRep)
								{
								}
							else
							{
								if (leftP && spr.animation.curAnim.name != 'confirm' && !loadRep)
									spr.animation.play('pressed');
								if (leftR)
								{
									spr.animation.play('static');
									repReleases++;
								}
							}
					}
					
					if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
					{
						spr.centerOffsets();
						spr.offset.x -= 13;
						spr.offset.y -= 13;
					}
					else
						spr.centerOffsets();
				});
	}

	function noteMiss(direction:Int = 1, daNote:Note):Void
	{
		if (!boyfriend.stunned)
		{
			health -= 0.04;
			if (combo > 70 && gf.animOffsets.exists('drop70'))
			{
				gf.canPlayOtherAnims = true;
				gf.playAnim('drop70', true);
				gf.canPlayOtherAnims = false;
			}
			combo = 0;
			misses++;

			var noteDiff:Float = Math.abs(daNote.strumTime - Conductor.songPosition);
			var wife:Float = EtternaFunctions.wife3(noteDiff, FlxG.save.data.etternaMode ? 1 : 1.7);

			if (FlxG.save.data.accuracyMod == 1)
				totalNotesHit += wife;

			songScore -= 10;

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			boyfriend.canPlayOtherAnims = true;
			switch (direction)
			{
				case 0:
					boyfriend.playAnim('singLEFTmiss', true);
				case 1:
					boyfriend.playAnim('singDOWNmiss', true);
				case 2:
					boyfriend.playAnim('singUPmiss', true);
				case 3:
					boyfriend.playAnim('singRIGHTmiss', true);
			}

			updateAccuracy();
		}
	}

	/*function badNoteCheck()
		{
			// just double pasting this shit cuz fuk u
			// REDO THIS SYSTEM!
			var upP = controls.UP_P;
			var rightP = controls.RIGHT_P;
			var downP = controls.DOWN_P;
			var leftP = controls.LEFT_P;
	
			if (leftP)
				noteMiss(0);
			if (upP)
				noteMiss(2);
			if (rightP)
				noteMiss(3);
			if (downP)
				noteMiss(1);
			updateAccuracy();
		}
	*/
	function updateAccuracy() 
		{
			totalPlayed += 1;
			accuracy = Math.max(0,totalNotesHit / totalPlayed * 100);
			accuracyDefault = Math.max(0, totalNotesHitDefault / totalPlayed * 100);
		}


	function getKeyPresses(note:Note):Int
	{
		var possibleNotes:Array<Note> = []; // copypasted but you already know that

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
			{
				possibleNotes.push(daNote);
				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
			}
		});
		if (possibleNotes.length == 1)
			return possibleNotes.length + 1;
		return possibleNotes.length;
	}
	
	var mashing:Int = 0;
	var mashViolations:Int = 0;

	var etternaModeScore:Int = 0;

	function noteCheck(controlArray:Array<Bool>, note:Note):Void // sorry lol
		{
			var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);

			if (noteDiff > Conductor.safeZoneOffset * 0.70 || noteDiff < Conductor.safeZoneOffset * -0.70)
				note.rating = "shit";
			else if (noteDiff > Conductor.safeZoneOffset * 0.50 || noteDiff < Conductor.safeZoneOffset * -0.50)
				note.rating = "bad";
			else if (noteDiff > Conductor.safeZoneOffset * 0.45 || noteDiff < Conductor.safeZoneOffset * -0.45)
				note.rating = "good";
			else if (noteDiff < Conductor.safeZoneOffset * 0.44 && noteDiff > Conductor.safeZoneOffset * -0.44)
				note.rating = "sick";

			if (loadRep)
			{
				if (controlArray[note.noteData])
					goodNoteHit(note);
				else if (rep.replay.keyPresses.length > repPresses && !controlArray[note.noteData])
				{
					if (NearlyEquals(note.strumTime,rep.replay.keyPresses[repPresses].time, 4))
					{
						goodNoteHit(note);
					}
				}
			}
			else if (controlArray[note.noteData])
				{
					for (b in controlArray) {
						if (b)
							mashing++;
					}

					// ANTI MASH CODE FOR THE BOYS

					if (mashing <= getKeyPresses(note) && mashViolations < 2)
					{
						mashViolations++;
						
						goodNoteHit(note, (mashing <= getKeyPresses(note)));
					}
					else
					{
						// this is bad but fuck you
						playerStrums.members[0].animation.play('static');
						playerStrums.members[1].animation.play('static');
						playerStrums.members[2].animation.play('static');
						playerStrums.members[3].animation.play('static');
						health -= 0.2;
						trace('mash ' + mashing);
					}

					if (mashing != 0)
						mashing = 0;
				}
		}

		var nps:Int = 0;

		function goodNoteHit(note:Note, resetMashViolation = true):Void
			{

				var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);

				note.rating = Ratings.CalculateRating(noteDiff);

				if (!note.isSustainNote)
					notesHitArray.push(Date.now());

				if (resetMashViolation)
					mashViolations--;

				if (!note.wasGoodHit)
				{
					if (!note.isSustainNote)
					{
						if(combo == 50 && gf.animOffsets.exists('combo50'))
						{
						gf.canPlayOtherAnims = true;
						gf.playAnim('combo50', true);
						gf.canPlayOtherAnims = false;
						}
						popUpScore(note);
						combo += 1;
					}
					else
						totalNotesHit += 1;

					var altAnim:String = "";

					if(note.noteType == "censor" && boyfriend.curCharacter == 'bf-christmas')
					altAnim = '-censor';

					boyfriend.canPlayOtherAnims = true;

					switch (note.noteData)
					{
						case 2:
							boyfriend.playAnim('singUP' + altAnim, true);
						case 3:
							boyfriend.playAnim('singRIGHT' + altAnim, true);
						case 1:
							boyfriend.playAnim('singDOWN' + altAnim, true);
						case 0:
							boyfriend.playAnim('singLEFT' + altAnim, true);
					}
		
					if (!loadRep)
						playerStrums.forEach(function(spr:FlxSprite)
						{
							if (Math.abs(note.noteData) == spr.ID)
							{
								spr.animation.play('confirm', true);
							}
						});
		
					note.wasGoodHit = true;
					vocals.volume = 1;
		
					note.kill();
					notes.remove(note, true);
					note.destroy();
					
					updateAccuracy();
				}
			}
		

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function fastCarDrive()
	{
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
		});
	}

	function doShootingStar(beat:Int):Void{
		shootingStar.visible = true;
		shootingStar.x = FlxG.random.int(50,900);
		shootingStar.y = FlxG.random.int(-10,20);
		shootingStar.flipX = FlxG.random.bool(50);
		shootingStar.animation.play('star', true);

		shootingStarBeat = beat;
		shootingStarOffset = FlxG.random.int(4, 8);
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
		}

		if (startedMoving)
		{
			train.x -= 400;

			if (train.x < -2000 && !trainFinishing)
			{
				train.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (train.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		gf.playAnim('hairFall');
		train.x = FlxG.width + 200;
		trainMoving = false;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		if (executeModchart && lua != null)
		{
			setVar('curStep',curStep);
			callLua('stepHit',[curStep]);
		}

		// yes this updates every step.
		// yes this is bad
		// but i'm doing it to update misses and accuracy
		#if windows
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") " + generateRanking(), "Acc: " + truncateFloat(accuracy, 2) + "% | Score: " + songScore + " | Misses: " + misses  , iconRPC,true,  songLength - Conductor.songPosition);
		#end

	}

	var lightningStrikeBeat:Int = 0;
	var lightningStrikeOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);
		}

		if (executeModchart && lua != null)
		{
			setVar('curBeat',curBeat);
			callLua('beatHit',[curBeat]);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			// else
			// Conductor.changeBPM(SONG.bpm);
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);

		if (!dad.animation.curAnim.name.startsWith("sing"))
		{
			dad.dance();
		}

		// Only bop camera if zoom level is below 135%
		if (FlxG.camera.zoom < (1.35 * FlxCamera.defaultZoom) && cameraZoomRate > 0 && curBeat % cameraZoomRate == 0)
		{
			// Set zoom multiplier for camera bop.
			cameraBopMultiplier = cameraBopIntensity;
			// HUD camera zoom still uses old system. To change. (+3%)
			camHUD.zoom += hudCameraZoomIntensity * defaultHUDCameraZoom;
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0)
		{
			gf.dance();
			if (abot != null)
			{
			abot.speaker.anim.play('anim', true);
			abot.speaker.anim.curFrame = 1;
			}
		}

		if (!boyfriend.animation.curAnim.name.startsWith("sing"))
		{
			boyfriend.playAnim('idle');
		}

		if (curBeat == 284 && SONG.song == 'Eggnog')
		{
				Conductor.changeBPM(80);
		}

		switch (curStage)
		{
			case 'mall':
				upperBoppers.animation.play('bop', true);
				bottomBoppers.animation.play('bop', true);
				santa.animation.play('idle', true);

			case 'limo':
				grpLimoDancers.forEach(function(dancer:BackgroundDancer)
				{
					dancer.dance();
				});

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();

				if (FlxG.random.bool(10) && curBeat > (shootingStarBeat + shootingStarOffset)){
					doShootingStar(curBeat);
				}
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				// Update lights
				if (curBeat % 4 == 0)
				{
				// Reset opacity
				lightShader.reset();

				// Switch to a different light
				curLight = FlxG.random.int(0, LIGHT_COUNT - 1);
				for (i in 0...LIGHT_COUNT)
				{
				phillyCityLights.members[i].visible = (i == curLight);
				}
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}

			case 'tank':
				if (curBeat % 2 == 0)
				{
				if(sniper.animation.name != 'sip' || sniper.animation.name == 'sip' && sniper.animation.finished)
				sniper.animation.play('idle');
				if (FlxG.random.bool(2))
				sniper.animation.play('sip');
				}
				if (curBeat % 2 == 0)
				{
				guy.animation.play('idle');
				}
			case "phillyStreets":
		if (FlxG.random.bool(10) && curBeat != (lastChange + changeInterval) && carInterruptable == true){
			if(lightsStop == false){
				driveCar(phillyCars);
			}
			else{
				driveCarLights(phillyCars);
			}
		}
	
		if(FlxG.random.bool(10) && curBeat != (lastChange + changeInterval) && car2Interruptable == true && lightsStop == false) driveCarBack(phillyCars2);
	
		if (curBeat == (lastChange + changeInterval)) changeLights(curBeat);
		}

		if (isHalloween && curBeat == 4 && SONG.song.toLowerCase() == "spookeez")
		{
			doLightningStrike(false, curBeat);
		}

		if (isHalloween && FlxG.random.bool(10) && curBeat > (lightningStrikeBeat + lightningStrikeOffset))
		{
			doLightningStrike(true, curBeat);
		}
	}

	var curLight:Int = 0;

  	function changeLights(beat:Int):Void{

		lastChange = beat;
		lightsStop = !lightsStop;

		if(lightsStop){
			phillyTraffic.animation.play('tored');
			changeInterval = 20;
		} else {
			phillyTraffic.animation.play('togreen');
			changeInterval = 30;

			if(carWaiting == true) finishCarLights(phillyCars);
		}
	}

	function resetCar(left:Bool, right:Bool){
		if(left){
			carWaiting = false;
			carInterruptable = true;
			if (phillyCars != null) {
				FlxTween.cancelTweensOf(phillyCars);
				phillyCars.x = 1200;
				phillyCars.y = 818;
				phillyCars.angle = 0;
			}
		}

		if(right){
			car2Interruptable = true;
			if (phillyCars2 != null) {
				FlxTween.cancelTweensOf(phillyCars2);
				phillyCars2.x = 1200;
				phillyCars2.y = 818;
				phillyCars2.angle = 0;
			}
		}
	}

	function finishCarLights(sprite:FlxSprite):Void{
		carWaiting = false;
		var duration:Float = FlxG.random.float(1.8, 3);
		var rotations:Array<Int> = [-5, 18];
		var offset:Array<Float> = [306.6, 168.3];
		var startdelay:Float = FlxG.random.float(0.2, 1.2);

		var path:Array<FlxPoint> = [
			FlxPoint.get(1950 - offset[0] - 80, 980 - offset[1] + 15),
			FlxPoint.get(2400 - offset[0], 980 - offset[1] - 50),
			FlxPoint.get(3102 - offset[0], 1127 - offset[1] + 40)
		];

		FlxTween.angle(sprite, rotations[0], rotations[1], duration, {ease: FlxEase.sineIn, startDelay: startdelay} );
		FlxTween.quadPath(sprite, path, duration, true,
		{
			ease: FlxEase.sineIn,
			startDelay: startdelay,
			onComplete: function(_) {
				carInterruptable = true;
			}
		});
	}

	function driveCarLights(sprite:FlxSprite):Void{
		carInterruptable = false;
		FlxTween.cancelTweensOf(sprite);
		var variant:Int = FlxG.random.int(1,4);
		sprite.animation.play('car' + variant);
		var extraOffset = [0, 0];
		var duration:Float = 2;

		switch(variant){
			case 1:
				duration = FlxG.random.float(1, 1.7);
			case 2:
				extraOffset = [20, -15];
				duration = FlxG.random.float(0.9, 1.5);
			case 3:
				extraOffset = [30, 50];
				duration = FlxG.random.float(1.5, 2.5);
			case 4:
				extraOffset = [10, 60];
				duration = FlxG.random.float(1.5, 2.5);
		}
		
		var rotations:Array<Int> = [-7, -5];
		var offset:Array<Float> = [306.6, 168.3];
		sprite.offset.set(extraOffset[0], extraOffset[1]);

		var path:Array<FlxPoint> = [
			FlxPoint.get(1500 - offset[0] - 20, 1049 - offset[1] - 20),
			FlxPoint.get(1770 - offset[0] - 80, 994 - offset[1] + 10),
			FlxPoint.get(1950 - offset[0] - 80, 980 - offset[1] + 15)
		];
		FlxTween.angle(sprite, rotations[0], rotations[1], duration, {ease: FlxEase.cubeOut} );
		FlxTween.quadPath(sprite, path, duration, true,
		{
			ease: FlxEase.cubeOut,
			onComplete: function(_) {
				carWaiting = true;
				if(lightsStop == false) finishCarLights(phillyCars);
			}
		});
	}

	function driveCar(sprite:FlxSprite):Void{
		carInterruptable = false;
		FlxTween.cancelTweensOf(sprite);
		var variant:Int = FlxG.random.int(1,4);
		sprite.animation.play('car' + variant);
		var extraOffset = [0, 0];
		var duration:Float = 2;
		switch(variant){
			case 1:
				duration = FlxG.random.float(1, 1.7);
			case 2:
				extraOffset = [20, -15];
				duration = FlxG.random.float(0.6, 1.2);
			case 3:
				extraOffset = [30, 50];
				duration = FlxG.random.float(1.5, 2.5);
			case 4:
				extraOffset = [10, 60];
				duration = FlxG.random.float(1.5, 2.5);
		}
		var offset:Array<Float> = [306.6, 168.3];
		sprite.offset.set(extraOffset[0], extraOffset[1]);
		var rotations:Array<Int> = [-8, 18];
		var path:Array<FlxPoint> = [
			FlxPoint.get(1570 - offset[0], 1049 - offset[1] - 30),
			FlxPoint.get(2400 - offset[0], 980 - offset[1] - 50),
			FlxPoint.get(3102 - offset[0], 1127 - offset[1] + 40)
		];

		FlxTween.angle(sprite, rotations[0], rotations[1], duration, null );
		FlxTween.quadPath(sprite, path, duration, true,
		{
			ease: null,
			onComplete: function(_) {
				carInterruptable = true;
			}
		});
	}

	function driveCarBack(sprite:FlxSprite):Void{
		car2Interruptable = false;
		FlxTween.cancelTweensOf(sprite);
		var variant:Int = FlxG.random.int(1,4);
		sprite.animation.play('car' + variant);
		var extraOffset = [0, 0];
		var duration:Float = 2;
		switch(variant){
			case 1:
				duration = FlxG.random.float(1, 1.7);
			case 2:
				extraOffset = [20, -15];
				duration = FlxG.random.float(0.6, 1.2);
			case 3:
				extraOffset = [30, 50];
				duration = FlxG.random.float(1.5, 2.5);
			case 4:
				extraOffset = [10, 60];
				duration = FlxG.random.float(1.5, 2.5);
		}
		var offset:Array<Float> = [306.6, 168.3];
		sprite.offset.set(extraOffset[0], extraOffset[1]);
		var rotations:Array<Int> = [18, -8];
		var path:Array<FlxPoint> = [
				FlxPoint.get(3102 - offset[0], 1127 - offset[1] + 60),
				FlxPoint.get(2400 - offset[0], 980 - offset[1] - 30),
				FlxPoint.get(1570 - offset[0], 1049 - offset[1] - 10)

		];

		FlxTween.angle(sprite, rotations[0], rotations[1], duration, null );
		FlxTween.quadPath(sprite, path, duration, true,
		{
			ease: null,
			onComplete: function(_) {
				car2Interruptable = true;
			}
		});
	}

	function setupRainShader()
	{
		rainShader = new RainShader();
		rainShader.scale = FlxG.height / 200;
		switch (SONG.song.toLowerCase())
		{
			case 'darnell':
				rainShaderStartIntensity = 0;
				rainShaderEndIntensity = 0.01;
		}
		rainShader.intensity = rainShaderStartIntensity;
		FlxG.camera.setFilters([new ShaderFilter(rainShader)]);
	}

	function pauseCars():Void {
		if (phillyCars != null) {
			FlxTweenUtil.pauseTweensOf(phillyCars);
		}

		if (phillyCars2 != null) {
			FlxTweenUtil.pauseTweensOf(phillyCars2);
		}
	}

	function resumeCars():Void {
		if (phillyCars != null) {
			FlxTweenUtil.resumeTweensOf(phillyCars);
		}

		if (phillyCars2 != null) {
			FlxTweenUtil.resumeTweensOf(phillyCars2);
		}
	}

	function transitionState() {
		switch (gf.currentState) {
			case 0:
				if (health <= gf.VULTURE_THRESHOLD) {
					gf.currentState = 1;
				} else {
					gf.currentState = 0;
				}
			case 1:
				if (health > gf.VULTURE_THRESHOLD) {
					gf.currentState = 0;
				} else if (gf.animationFinished) {
					gf.currentState = 2;
					gf.playAnim('raiseKnife');
					gf.animationFinished = false;
				}
			case 2:
				if (gf.animationFinished) {
					gf.currentState = 3;
					gf.animationFinished = false;
				}
			case 3:
				if (health > gf.VULTURE_THRESHOLD) {
					gf.currentState = 4;
				}
			case 4:
				if (gf.animationFinished) {
					gf.currentState = 0;
					gf.animationFinished = false;
				}
			default:
				gf.currentState = 0;
		}
	}

	function onAnimationFinished(name:String) {
		switch(gf.currentState) {
			case 2:
				if (name == "raiseKnife") {
					gf.animationFinished = true;
					transitionState();
				}
			case 4:
				if (name == "lowerKnife") {
					gf.animationFinished = true;
					transitionState();
				}
			default:
		}
	}

	function onAnimationFrame(name:String, frameNumber:Int) {
		switch(gf.currentState) {
			case 1:
				if (name == "danceLeft" && frameNumber == 13) {
					gf.animationFinished = true;
					transitionState();
				}
			default:
		}
	}

	function doLightningStrike(playSound:Bool, beat:Int):Void
	{
		if (playSound)
		{
			FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2), 1.0);
		}

		bgLight.alpha = 1;
		stairsLight.alpha = 1;
		boyfriend.alpha = 0;
		dad.alpha = 0;
		boyfriend.alpha = 0;

		new FlxTimer().start(0.06, function(_) {
			bgLight.alpha = 0;
			stairsLight.alpha = 0;
			boyfriend.alpha = 1;
			dad.alpha = 1;
			boyfriend.alpha = 1;
		});

		new FlxTimer().start(0.12, function(_) {
			bgLight.alpha = 1;
			stairsLight.alpha = 1;
			boyfriend.alpha = 0;
			dad.alpha = 0;
			gf.alpha = 0;
			FlxTween.tween(bgLight, {alpha: 0}, 1.5);
			FlxTween.tween(stairsLight, {alpha: 0}, 1.5);
			FlxTween.tween(boyfriend, {alpha: 1}, 1.5);
			FlxTween.tween(dad, {alpha: 1}, 1.5);
			FlxTween.tween(gf, {alpha: 1}, 1.5);
		});

		lightningStrikeBeat = beat;
		lightningStrikeOffset = FlxG.random.int(8, 24);

		if (boyfriend.animOffsets.exists('scared') && boyfriend.animation.name != 'cheer') {
			boyfriend.playAnim('scared', true);
		}

		if (gf.animOffsets.exists('scared')) {
			gf.playAnim('scared', true);
		}
	}

  function processSongEvents():Void
  {
		if (songEvents != null && songEvents.length > 0) {
		while(songEvents.length > 0) {
			var leStrumTime:Float = songEvents[0].time;
			if(Conductor.songPosition < leStrumTime) {
				break;
			}
			songEvents[0].activated = true;
			if(songEvents[0].eventKind == 'FocusCamera')
			FocusCameraSongEvent(songEvents[0]);
			if(songEvents[0].eventKind == 'ZoomCamera')
			ZoomCameraSongEvent(songEvents[0]);
			if(songEvents[0].eventKind == 'SetCameraBop')
			SetCameraBopSongEvent(songEvents[0]);
			if(songEvents[0].eventKind == 'PlayAnimation')
			PlayAnimationSongEvent(songEvents[0]);
			songEvents.shift();
		}
		}
  }

  function FocusCameraSongEvent(data:SongEventData)
  {
    var posX:Null<Float> = data.getFloat('x');
    if (posX == null) posX = 0.0;
    var posY:Null<Float> = data.getFloat('y');
    if (posY == null) posY = 0.0;

    var char:Null<Int> = data.getInt('char');

    if (char == null) char = cast data.value;

    var duration:Null<Float> = data.getFloat('duration');
    if (duration == null) duration = 4.0;
    var ease:Null<String> = data.getString('ease');
    if (ease == null) ease = 'CLASSIC';

    // Get target position based on char.
    var targetX:Float = posX;
    var targetY:Float = posY;

    switch (char)
    {
      case -1: // Position ("focus" on origin)
        trace('Focusing camera on static position.');

      case 0: // Boyfriend (focus on player)
        trace('Focusing camera on player.');
        var bfPoint = boyfriend.cameraFocusPoint;
        targetX += bfPoint.x;
        targetY += bfPoint.y;

	if(abot != null)
	abot.lookRight();

      case 1: // Dad (focus on opponent)
        trace('Focusing camera on opponent.');
        var dadPoint = dad.cameraFocusPoint;
        targetX += dadPoint.x;
        targetY += dadPoint.y;

	if(abot != null)
	abot.lookLeft();

      case 2: // Girlfriend (focus on girlfriend)
        trace('Focusing camera on girlfriend.');
        var gfPoint = gf.cameraFocusPoint;
        targetX += gfPoint.x;
        targetY += gfPoint.y;

      default:
        trace('Unknown camera focus: ' + data);
    }

    // Apply tween based on ease.
    switch (ease)
    {
      case 'CLASSIC': // Old-school. No ease. Just set follow point.
        resetCamera(false, false, false);
        cancelCameraFollowTween();
        camFollow.setPosition(targetX, targetY);
      case 'INSTANT': // Instant ease. Duration is automatically 0.
        tweenCameraToPosition(targetX, targetY, 0);
      default:
        var durSeconds = Conductor.stepCrochet * duration / 1000;
        var easeFunction:Null<Float->Float> = Reflect.field(FlxEase, ease);
        if (easeFunction == null)
        {
          trace('Invalid ease function: $ease');
          return;
        }
        tweenCameraToPosition(targetX, targetY, durSeconds, easeFunction);
    }
  }

  function tweenCameraToPosition(?x:Float, ?y:Float, ?duration:Float, ?ease:Null<Float->Float>):Void
  {
    camFollow.setPosition(x, y);
    tweenCameraToFollowPoint(duration, ease);
  }

  function tweenCameraToFollowPoint(?duration:Float, ?ease:Null<Float->Float>):Void
  {
    // Cancel the current tween if it's active.
    cancelCameraFollowTween();

    if (duration == 0)
    {
      // Instant movement. Just reset the camera to force it to the follow point.
      resetCamera(false, false);
    }
    else
    {
      // Disable camera following for the duration of the tween.
      FlxG.camera.target = null;

      // Follow tween! Caching it so we can cancel/pause it later if needed.
      var followPos = new FlxPoint(
      camFollow.x - FlxG.camera.width * 0.5,
      camFollow.y - FlxG.camera.height * 0.5
      );
      cameraFollowTween = FlxTween.tween(FlxG.camera.scroll, {x: followPos.x, y: followPos.y}, duration,
        {
          ease: ease,
          onComplete: function(_) {
            resetCamera(false, false); // Re-enable camera following when the tween is complete.
          }
        });
    }
  }

  function cancelCameraFollowTween()
  {
    if (cameraFollowTween != null)
    {
      cameraFollowTween.cancel();
    }
  }

  var DEFAULT_ZOOM:Float = 1.0;
  var DEFAULT_DURATION:Float = 4.0;
  var DEFAULT_MODE:String = 'direct';
  var DEFAULT_EASE:String = 'linear';

  function ZoomCameraSongEvent(data:SongEventData)
  {
    var zoom:Float = data.getFloat('zoom');
    if(Math.isNaN(zoom)) zoom = DEFAULT_ZOOM;

    var duration:Float = data.getFloat('duration');
    if(Math.isNaN(duration)) duration = DEFAULT_DURATION;

    var mode:String = data.getString('mode');
    if(mode == null) mode = DEFAULT_MODE;
    var isDirectMode:Bool = mode == 'direct';

    var ease:String = data.getString('ease');
    if(ease == null) ease = DEFAULT_EASE;

    // If it's a string, check the value.
    switch (ease)
    {
      case 'INSTANT':
        tweenCameraZoom(zoom, 0, isDirectMode);
      default:
        var durSeconds = Conductor.stepCrochet * duration / 1000;
        var easeFunction:Null<Float->Float> = Reflect.field(FlxEase, ease);
        if (easeFunction == null)
        {
          trace('Invalid ease function: $ease');
          return;
        }

        tweenCameraZoom(zoom, durSeconds, isDirectMode, easeFunction);
    }
  }

  function tweenCameraZoom(?zoom:Float, ?duration:Float, ?direct:Bool, ?ease:Null<Float->Float>):Void
  {
    // Cancel the current tween if it's active.
    cancelCameraZoomTween();

    // Direct mode: Set zoom directly.
    // Stage mode: Set zoom as a multiplier of the current stage's default zoom.
    var targetZoom = zoom * (direct ? FlxCamera.defaultZoom : stageZoom);

    if (duration == 0)
    {
      // Instant zoom. No tween needed.
      currentCameraZoom = targetZoom;
    }
    else
    {
      // Zoom tween! Caching it so we can cancel/pause it later if needed.
      cameraZoomTween = FlxTween.tween(this, {currentCameraZoom: targetZoom}, duration, {ease: ease});
    }
  }

  function cancelCameraZoomTween()
  {
    if (cameraZoomTween != null)
    {
      cameraZoomTween.cancel();
    }
  }

  function SetCameraBopSongEvent(data:SongEventData)
  {
    var rate:Null<Int> = data.getInt('rate');
    if (rate == null) rate = 4;
    var intensity:Null<Float> = data.getFloat('intensity');
    if (intensity == null) intensity = 1.0;

    cameraBopIntensity = (1.015 - 1.0) * intensity + 1.0;
    hudCameraZoomIntensity = (1.015 - 1.0) * intensity * 2.0;
    cameraZoomRate = rate;
    trace('Set camera zoom rate to ${cameraZoomRate}');
  }

  function resetCamera(?resetZoom:Bool = true, ?cancelTweens:Bool = true, ?snap:Bool = true):Void
  {
    // Cancel camera tweens if any are active.
    if (cancelTweens)
    {
      cancelAllCameraTweens();
    }

    FlxG.camera.follow(camFollow, LOCKON, cameraSpeed);

    if (resetZoom)
    {
      resetCameraZoom();
    }

    // Snap the camera to the follow point immediately.
    if (snap) FlxG.camera.focusOn(camFollow.getPosition());
  }

  function cancelAllCameraTweens()
  {
    cancelCameraFollowTween();
    cancelCameraZoomTween();
  }

  function resetCameraZoom():Void
  {
    currentCameraZoom = stageZoom;
    FlxG.camera.zoom = currentCameraZoom;

    // Reset bop multiplier.
    cameraBopMultiplier = 1.0;
  }

  function PlayAnimationSongEvent(data:SongEventData)
  {
    var targetName = data.getString('target');
    var anim = data.getString('anim');
    var force = data.getBool('force');
    if (force == null) force = false;

    var target:FlxSprite = null;

    switch (targetName)
    {
      case 'boyfriend' | 'bf' | 'player':
        trace('Playing animation $anim on boyfriend.');
        target = boyfriend;
      case 'dad' | 'opponent':
        trace('Playing animation $anim on dad.');
        target = dad;
      case 'girlfriend' | 'gf':
        trace('Playing animation $anim on girlfriend.');
        target = gf;
    }

    if (target != null)
    {
      if (Std.isOfType(target, Character))
      {
        var targetChar:Character = cast target;
        if (targetChar.animOffsets.exists(anim))
        {
        targetChar.canPlayOtherAnims = true;
        targetChar.playAnim(anim, force);
        targetChar.canPlayOtherAnims = false;
        }
      }
    }
  }
}
