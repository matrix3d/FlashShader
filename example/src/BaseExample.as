package 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DTriangleFace;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.media.Camera;
	import flash.media.StageVideo;
	import flash.media.Video;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import gl3d.core.Fog;
	import gl3d.core.Light;
	import gl3d.core.shaders.GLAS3Shader;
	import gl3d.core.shaders.GLShader;
	import gl3d.ctrl.ArcBallCtrl;
	import gl3d.ctrl.FirstPersonCtrl;
	import gl3d.core.Material;
	import gl3d.meshs.Teapot;
	import gl3d.parser.hlbsp.Bsp;
	import gl3d.parser.hlbsp.BspRender;
	import gl3d.parser.hlbsp.console;
	import gl3d.parser.hlbsp.Wad;
	import gl3d.meshs.Meshs;
	import gl3d.core.Node3D;
	import gl3d.pick.AS3Picking;
	import gl3d.post.PostEffect;
	import gl3d.shaders.SkyBoxFragmentShader;
	import gl3d.shaders.SkyBoxVertexShader;
	import gl3d.shaders.posts.AsciiArtShader;
	import gl3d.shaders.posts.FlowerShader;
	import gl3d.shaders.posts.FxaaShader;
	import gl3d.shaders.posts.HdrShader;
	import gl3d.shaders.posts.HeartShader;
	import gl3d.shaders.posts.PostFragmentShader;
	import gl3d.shaders.posts.BlurShader;
	import gl3d.shaders.posts.PostVertexShader;
	import gl3d.shaders.posts.PulseShader;
	import gl3d.shaders.posts.RedScreenShader;
	import gl3d.shaders.posts.ShapeShader;
	import gl3d.shaders.posts.SinWaterShader;
	import gl3d.shaders.posts.TileableWaterCausticShader;
	import gl3d.core.TextureSet;
	import gl3d.core.View3D;
	import gl3d.util.Stats;
	import gl3d.util.Utils;
	import ui.Gamepad;
	/**
	 * ...
	 * @author lizhi
	 */
	[SWF(frameRate='60', backgroundColor='0x000000', width='800', height='600')]
	public class BaseExample extends Sprite
	{
		public var speed:Number = .03;
		public var movementFunc:Function;
		public var view:View3D;
		private var _useTexture:Boolean = true;
		protected var texture:TextureSet;
		private var normalMapTexture:TextureSet;
		public var skyBoxTexture:TextureSet;
		private var debug:TextField;
		private var bmd:BitmapData;
		private var ac:ArcBallCtrl;
		public var skybox:Node3D;
		public var stats:Stats;
		public var teapot:Node3D;
		public var material:Material = new Material;
		public var _post:String;
		public var gamepad:Gamepad=new Gamepad;
		public var fc:FirstPersonCtrl;
		public var lights:Array = [];
		public function BaseExample() 
		{
			if (stage){
				init();
			}else{
				addEventListener(Event.ADDED_TO_STAGE, addedToStage);
			}
		}
		
		private function addedToStage(e:Event=null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			init();
		}
		
		private function init():void 
		{
			
			if (Multitouch.supportsTouchEvents&&Multitouch.maxTouchPoints) {
				Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
				debug = new TextField;
				debug.mouseEnabled = debug.mouseWheelEnabled = false;
				addChild(debug);
				debug.width = stage.stageWidth;
				debug.height = stage.stageHeight;
				//console.textfield = debug;
			}
			view = new View3D(0);
			//view.scene.scissorRectangle = new Rectangle(100, 100, 400, 400);
			//view.renderer.visible = false;
			//view.visible = false;
			view.antiAlias = 2;
			//view.enableErrorChecking = true;
			//view.renderer.agalVersion = 1;
			addChild(view);
			view.camera.z = -10;
			
			[Embed(source = "assets/skybox/px.jpg")]var pxc:Class;
			[Embed(source = "assets/skybox/nx.jpg")]var nxc:Class;
			[Embed(source = "assets/skybox/py.jpg")]var pyc:Class;
			[Embed(source = "assets/skybox/ny.jpg")]var nyc:Class;
			[Embed(source = "assets/skybox/pz.jpg")]var pzc:Class;
			[Embed(source = "assets/skybox/nz.jpg")]var nzc:Class;
			
			/*[Embed(source = "assets/skybox/mp_petesoasis/petesoasis_ft.jpg")]var pxc:Class;
			[Embed(source = "assets/skybox/mp_petesoasis/petesoasis_bk.jpg")]var nxc:Class;
			[Embed(source = "assets/skybox/mp_petesoasis/petesoasis_up.jpg")]var pyc:Class;
			[Embed(source = "assets/skybox/mp_petesoasis/petesoasis_dn.jpg")]var nyc:Class;
			[Embed(source = "assets/skybox/mp_petesoasis/petesoasis_rt.jpg")]var pzc:Class;
			[Embed(source = "assets/skybox/mp_petesoasis/petesoasis_lf.jpg")]var nzc:Class;*/
			var bmds:Array = [
			(new pxc as Bitmap).bitmapData,
			(new nxc as Bitmap).bitmapData,
			(new pyc as Bitmap).bitmapData,
			(new nyc as Bitmap).bitmapData,
			(new pzc as Bitmap).bitmapData,
			(new nzc as Bitmap).bitmapData
			/*new BitmapData(256,256,false,0xff0000),
			new BitmapData(256,256,false,0xff00),
			new BitmapData(256,256,false,0xff),
			new BitmapData(256,256,false,0xffff00),
			new BitmapData(256,256,false,0xff00ff),
			new BitmapData(256,256,false,0xffff)*/
			];
			/*for each(var bmd2:BitmapData in bmds) {
				Utils.createXorMap(bmd2);
			}*/
			skyBoxTexture = new TextureSet(bmds, false,false, false,true);
			
			bmd = new BitmapData(256, 256, false, 0xff0000);
			bmd.perlinNoise(30, 30, 2, 1, true, true);
			
			//atf
			//[Embed(source = "assets/leaf.atf", mimeType = "application/octet-stream")]var texc:Class;
			//[Embed(source = "idle.atf", mimeType = "application/octet-stream")]var texc:Class;
			//texture = new TextureSet((new texc as ByteArray),false,false,false,false);
			
			
			//[Embed(source = "assets/leaf.png")]var leafp:Class;
			//texture = new TextureSet((new leafp as Bitmap).bitmapData,false,false, false, false, false);
			
			/*var camera:Camera = Camera.getCamera();
			if (Context3D.supportsVideoTexture&& camera){
				texture = new TextureSet(camera);
			}*/
			//texture = new TextureSet(bmd);
			//material.culling =  Context3DTriangleFace.NONE;
			//material.blendModel = BlendMode.ADD;
			
//			[Embed(source = "assets/1234.png")]var tt:Class;
	//		texture = new TextureSet((new tt as Bitmap).bitmapData);
			
			material.normalMapAble = false;
			material.color.setTo(1, 1, 1);
			//material.alpha = .5;
			material.blendMode = BlendMode.LAYER;
			material.culling = Context3DTriangleFace.NONE;
			material.ambient.setTo(.5, .5, .5);
			material.specularPower = 10;
			material.reflectTexture
			material.specularAble = true;
			material.lightAble = true;
			material.wireframeAble = true;
			material.toonAble = false;
			material.alphaThreshold = .1;
			material.blurSize = 2;
			material.diffTexture = texture;
			if (material.normalMapAble) {
				material.normalmapTexture= normalMapTexture;
			}
			material.reflectTexture = skyBoxTexture;
			
			stats = new Stats(view);
			initLight();
			initNode();
			initUI();
			initCtrl();
			
			addEventListener(Event.ENTER_FRAME, enterFrame);
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(Event.RESIZE, stage_resize);
			stage.addEventListener(MouseEvent.CLICK, stage_mouseDown);
			stage_resize();
			//post = "def";
			//post = "water";
			//post = "heart";
			//post = "flower";
			//post="sinwater"
			//post="hdr"
			//post="shape"
			//post="asciiart"
			//post = "blur";
			//post = "bend";
			//post = "red";
			//post = "fxaa";
			//post = "fxaa2x";
		}
		
		public function initLight():void {
			lights.push(new Light);
			view.scene.addChild(lights[0]);
			lights[0].z = -4500;
			lights[0].y = 4500;
			//view.lights[0].color.setTo(.5, .5, .5);
			//view.lights[1] = new Light;
			//view.lights[1].z = 450;
			//view.lights[1].color = new <Number>[1,0,0,1];
			//view.lights[0].color = new <Number>[0,1,0,1];
			//view.scene.addChild(view.lights[1]);
		}
		
		public function addSky():void {
			//skybox
			skybox = new Node3D("sky");
			var m:Material = new Material(new GLShader(new SkyBoxVertexShader,new SkyBoxFragmentShader));
			skybox.material = m;
			m.uvMuler = [10,10,10,10];
			m.castShadow = false;
			m.diffTexture = skyBoxTexture
			m.specularPower = 10;
			m.color.setTo(.5,.5,.5);
			m.culling = Context3DTriangleFace.BACK;
			skybox.drawable = Meshs.cube(500,500,500);
			view.scene.addChild(skybox);
		}
		
		public function initNode():void {
			addSky();
			teapot = new Node3D;
			//teapot.lifeTimeRange.x = 1000;
			teapot.material = material;
			teapot.drawable = 
			//Meshs.cube();
			//Meshs.sphere();
			Teapot.teapot().unpackedDrawable;
			view.scene.addChild(teapot);
			//teapot.scaleX = teapot.scaleY = teapot.scaleZ = .1;
			for (var i:int = 0; i < 0;i++ ){
				var t:Node3D = teapot.clone();
				t.startTime = 1000 * Math.random();
				//t.setRotation(360 * Math.random(), 360 * Math.random(), 360 * Math.random());
				view.scene.addChild(t);
				t.x+=6*(Math.random()-.5)
				t.y+=6*(Math.random()-.5)
				t.z+=6*(Math.random()-.5)
			}
			view.background = 0//xffffff;
			teapot.picking = new AS3Picking();
		}
		
		private function stage_mouseDown(e:MouseEvent):void 
		{
			var rayOrigin:Vector3D = new Vector3D;
			var rayDirection:Vector3D = new Vector3D;
			var pix:Vector3D = new Vector3D;
			view.camera.computePickRayDirectionMouse(mouseX, mouseY, stage.stageWidth, stage.stageHeight, rayOrigin, rayDirection);
			if (teapot&&teapot.rayMeshTest(rayOrigin, rayDirection,pix)) {
				trace("test");
				//teapot.scaleX *=-1;
			}
		}
		
		public function initUI():void {
			if(Multitouch.supportsTouchEvents&&Multitouch.maxTouchPoints)
			addChild(gamepad);
			gamepad.x = 200;
			gamepad.y = 200;
			addChild(stats);
		}
		
		public function initCtrl():void {
			fc = new FirstPersonCtrl(view.camera, stage);
			fc.speed = speed;
			fc.movementFunc = movementFunc;
			//view.ctrls.push(fc);
			
			ac = new ArcBallCtrl(view.camera, stage);
			view.ctrls.push(ac);
		}
		
		protected function stage_resize(e:Event = null):void
		{
			view.invalid = true;
			view.stage3dWidth = stage.stageWidth;
			view.stage3dHeight = stage.stageHeight;
			view.camera.perspectiveFieldOfViewLH(Math.PI / 4, view.stage3dWidth/ view.stage3dHeight, .1, 4000);
			if (debug) {
				debug.width = view.stage3dWidth;
				debug.height = view.stage3dHeight;
			}
		}
		
		public function enterFrame(e:Event):void
		{
			if (teapot) {
				//teapot.rotationX = teapot.rotationX;// .rotationY ++;
				//trace(teapot.scaleX,teapot.scaleY,teapot.scaleZ);
				//trace(teapot.getRotation());
				//teapot.x = Math.sin(getTimer() / 1000);
				//teapot.y = Math.sin(getTimer() / 700);
				//teapot.z = Math.sin(getTimer() / 400);
				//teapot.rotationY+=2;
				//teapot.rotationX+=2;
				//teapot.matrix.appendRotation(1, Vector3D.Y_AXIS);
				//teapot.updateTransforms(true);
				//teapot.rotationX+=.01;
				//var r:Vector3D = teapot.getRotation();
				//teapot.matrix.appendRotation(1, Vector3D.Y_AXIS);// .setRotation(r.x, r.y + 1, r.z);// += .01;
				//teapot.updateTransforms(true);
			}
			view.updateCtrl();
			view.render(getTimer());
			if (gamepad) {
				if(fc)fc.inputSpeed = gamepad.speed;
				if(ac)ac.inputSpeed = gamepad.speed;
			}
		}
		
		public function get useTexture():Boolean
		{
			return _useTexture;
		}
		
		public function set useTexture(value:Boolean):void
		{
			if (value != _useTexture)
			{
				_useTexture = value;
				material.invalid = true;
				material.diffTexture=  value ? texture:null;
			}
		}
		
		public function get post():String
		{
			return _post;
		}
		
		public function set post(txt:String):void
		{
			_post = txt;
			view.posts.length = 0;
			switch(txt) {
				case "blur":
					var blurSize:Number = 2;
					view.posts.push(new PostEffect(new GLShader(new PostVertexShader,new BlurShader(blurSize))));
					view.posts.push(new PostEffect(new GLShader(new PostVertexShader,new BlurShader(blurSize,false))));
					break;
				case "fxaa":
					view.posts.push(new PostEffect(new GLShader(new PostVertexShader,new FxaaShader)));
					break;
				case "fxaa2x":
					view.posts.push(new PostEffect(new GLShader(new PostVertexShader,new FxaaShader)));
					view.posts.push(new PostEffect(new GLShader(new PostVertexShader,new FxaaShader)));
					break;
				case "water":
					view.posts.push(new PostEffect(new GLShader(new PostVertexShader, new TileableWaterCausticShader), 0));
					break;
				case "bend":
					view.posts.push(new PostEffect(new GLShader(new PostVertexShader, new PulseShader)));
					break;
				case "heart":
					view.posts.push(new PostEffect(new GLShader(new PostVertexShader, new HeartShader),0));
					break;
				case "flower":
					view.posts.push(new PostEffect(new GLShader(new PostVertexShader, new FlowerShader),0));
					break;
				case "sinwater":
					view.posts.push(new PostEffect(new GLShader(new PostVertexShader, new SinWaterShader)));
					break
				case "hdr":
					view.posts.push(new PostEffect(new GLShader(new PostVertexShader, new HdrShader)));
					break;
				case "shape":
					view.posts.push(new PostEffect(new GLShader(new PostVertexShader, new ShapeShader), 0));
					break;
				case "asciiart":
					view.posts.push(new PostEffect(new GLShader(new PostVertexShader, new AsciiArtShader)));
					break;
				case "red":
					view.posts.push(new PostEffect(new GLShader(new PostVertexShader, new RedScreenShader),0));
					break;
				case "def":
					view.posts.push(new PostEffect(new GLShader(new PostVertexShader,new PostFragmentShader)));
			}
		}
	}

}