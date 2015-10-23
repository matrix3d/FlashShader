package 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DTriangleFace;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.text.TextField;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import gl3d.core.Fog;
	import gl3d.core.Light;
	import gl3d.ctrl.ArcBallCtrl;
	import gl3d.ctrl.FirstPersonCtrl;
	import gl3d.core.Material;
	import gl3d.parser.hlbsp.Bsp;
	import gl3d.parser.hlbsp.BspRender;
	import gl3d.parser.hlbsp.console;
	import gl3d.parser.hlbsp.Wad;
	import gl3d.meshs.Meshs;
	import gl3d.core.Node3D;
	import gl3d.pick.AS3Picking;
	import gl3d.post.PostEffect;
	import gl3d.shaders.posts.AsciiArtShader;
	import gl3d.shaders.posts.FlowerShader;
	import gl3d.shaders.posts.HdrShader;
	import gl3d.shaders.posts.HeartShader;
	import gl3d.shaders.posts.PostGLShader;
	import gl3d.shaders.posts.BlurShader;
	import gl3d.shaders.posts.PulseShader;
	import gl3d.shaders.posts.RedScreenShader;
	import gl3d.shaders.posts.ShapeShader;
	import gl3d.shaders.posts.SinWaterShader;
	import gl3d.shaders.posts.TileableWaterCausticShader;
	import gl3d.core.TextureSet;
	import gl3d.core.View3D;
	import gl3d.shaders.SkyBoxGLShader;
	import gl3d.util.Stats;
	import gl3d.util.Utils;
	import ui.AttribSeter;
	import ui.Color;
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
		public var aui:AttribSeter = new AttribSeter;
		private var _useTexture:Boolean = true;
		private var texture:TextureSet;
		private var normalMapTexture:TextureSet;
		public var skyBoxTexture:TextureSet;
		private var debug:TextField;
		private var bmd:BitmapData;
		public var skybox:Node3D;
		public var stats:Stats;
		public var teapot:Node3D;
		public var material:Material = new Material;
		public var _post:String;
		public var gamepad:Gamepad=new Gamepad;
		public var fc:FirstPersonCtrl;
		public function BaseExample() 
		{
			if (Multitouch.supportsTouchEvents) {
				Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
				debug = new TextField;
				debug.mouseEnabled = debug.mouseWheelEnabled = false;
				addChild(debug);
				debug.width = stage.stageWidth;
				debug.height = stage.stageHeight;
				//console.textfield = debug;
			}
			view = new View3D(0);
			addChild(view);
			view.camera.z = -10;
			
			[Embed(source = "assets/skybox/px.jpg")]var pxc:Class;
			[Embed(source = "assets/skybox/nx.jpg")]var nxc:Class;
			[Embed(source = "assets/skybox/py.jpg")]var pyc:Class;
			[Embed(source = "assets/skybox/ny.jpg")]var nyc:Class;
			[Embed(source = "assets/skybox/pz.jpg")]var pzc:Class;
			[Embed(source = "assets/skybox/nz.jpg")]var nzc:Class;
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
			skyBoxTexture = new TextureSet(bmds, false, true,true);
			
			bmd = new BitmapData(128, 128, false, 0xff0000);
			bmd.perlinNoise(30, 30, 2, 1, true, true);
			
			//atf
			//[Embed(source = "assets/leaf.atf", mimeType = "application/octet-stream")]var leafc:Class;
			//texture = new TextureSet((new leafc as ByteArray),false,false,true,false);
			
			
			//[Embed(source = "assets/leaf.png")]var leafp:Class;
			//texture = new TextureSet((new leafp as Bitmap).bitmapData, false, false, true, false);
			
			normalMapTexture = createNormalMap();
			material.culling =  Context3DTriangleFace.NONE;
			//material.blendModel = BlendMode.ADD;
			material.normalMapAble = true;
			material.specularPower = 10;
			material.specularAble = true;
			material.lightAble = true;
			material.wireframeAble = false;
			material.toonAble = false;
			material.alphaThreshold = .7;
			material.diffTexture = texture;
			if (material.normalMapAble) {
				material.normalmapTexture= normalMapTexture;
			}
			material.reflectTexture = skyBoxTexture;
			
			initLight();
			initNode();
			initUI();
			initCtrl();
			
			addEventListener(Event.ENTER_FRAME, enterFrame);
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(Event.RESIZE, stage_resize);
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
			stats = new Stats(view);
			addChild(stats);
		}
		
		public function createNormalMap():TextureSet {
			var bmd:BitmapData = new BitmapData(512, 512, false, 0);
			bmd.perlinNoise(100, 100, 4, 1, true, true);
			return new TextureSet(Utils.createNormalMap(bmd));
		}
		
		public function initLight():void {
			view.lights[0].z = -450;
			//view.lights[1] = new Light;
			//view.lights[1].z = 450;
			//view.lights[1].color = new <Number>[1,0,0,1];
			//view.lights[0].color = new <Number>[0,1,0,1];
			//view.scene.addChild(view.lights[1]);
		}
		
		public function addSky():void {
			//skybox
			skybox = new Node3D;
			skybox.material = new Material(new SkyBoxGLShader);
			skybox.material.diffTexture = skyBoxTexture
			skybox.material.specularPower = 10;
			skybox.material.color = new <Number>[.5,.5,.5,.5];
			skybox.material.culling = Context3DTriangleFace.BACK;
			skybox.drawable = Meshs.cube(2000,2000,2000);
			view.scene.addChild(skybox);
		}
		
		public function initNode():void {
			addSky();
			
			teapot = new Node3D;
			teapot.material = material;
			teapot.drawable = Meshs.teapot(10);
			//teapot.drawable = Meshs.cube();
			view.scene.addChild(teapot);
			teapot.scaleX = teapot.scaleY = teapot.scaleZ = 1;
			view.background = 0//xffffff;
			teapot.picking = new AS3Picking();
			stage.addEventListener(MouseEvent.MOUSE_DOWN, stage_mouseDown);
		}
		
		private function stage_mouseDown(e:MouseEvent):void 
		{
			var rayOrigin:Vector3D = new Vector3D;
			var rayDirection:Vector3D = new Vector3D;
			var pix:Vector3D = new Vector3D;
			view.camera.computePickRayDirectionMouse(mouseX, mouseY, stage.stageWidth, stage.stageHeight, rayOrigin, rayDirection);
			if (teapot.rayMeshTest(rayOrigin, rayDirection,pix)) {
				trace("test");
			}
		}
		
		public function initUI():void {
			//addChild(aui);
			aui.bind(material, "specularPower", AttribSeter.TYPE_NUM, new Point(1, 100));
			aui.bind(material, "shininess", AttribSeter.TYPE_NUM, new Point(.5, 5));
			aui.bind(material, "toonAble", AttribSeter.TYPE_BOOL);
			aui.bind(view, "antiAlias", AttribSeter.TYPE_NUM, new Point(0, 16));
			//aui.bind(view.light, "color", AttribSeter.TYPE_VEC_COLOR);
			aui.bind(material, "ambient", AttribSeter.TYPE_VEC_COLOR);
			aui.bind(material, "color", AttribSeter.TYPE_VEC_COLOR);
			aui.bind(material, "alpha", AttribSeter.TYPE_NUM, new Point(.1, 1));
			aui.bind(material, "wireframeAble", AttribSeter.TYPE_BOOL);
			aui.bind(this, "useTexture", AttribSeter.TYPE_BOOL);
			aui.bind(this, "post", AttribSeter.TYPE_LIST_STR, null, ["null", "blur", "water", "bend", "heart", "flower", "sinwater", "hdr", "shape","asciiart","red"]);
			
			if(Multitouch.supportsTouchEvents)
			addChild(gamepad);
			gamepad.x = 200;
			gamepad.y = 200;
		}
		public function initCtrl():void {
			fc = new FirstPersonCtrl(view.camera, stage);
			fc.speed = speed;
			fc.movementFunc = movementFunc;
			
			var ac:ArcBallCtrl = new ArcBallCtrl(view.camera, stage);
			view.ctrls.push(ac);
		}
		
		protected function stage_resize(e:Event = null):void
		{
			view.invalid = true;
			view.stage3dWidth = stage.stageWidth;
			view.stage3dHeight = stage.stageHeight;
			view.camera.perspective.perspectiveFieldOfViewLH(Math.PI / 4, view.stage3dWidth/ view.stage3dHeight, .1, 4000);
			if (debug) {
				debug.width = view.stage3dWidth;
				debug.height = view.stage3dHeight;
			}
		}
		
		public function enterFrame(e:Event):void
		{
			if(teapot){
				//teapot.rotationX+=.01;
				//var r:Vector3D = teapot.getRotation();
				//teapot.matrix.appendRotation(1, Vector3D.Y_AXIS);// .setRotation(r.x, r.y + 1, r.z);// += .01;
				//teapot.updateTransforms(true);
			}
			view.updateCtrl();
			view.render(getTimer());
			
			aui.update();
			if (gamepad&&fc) {
				fc.inputSpeed = gamepad.speed;
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
					view.posts.push(new PostEffect(new PostGLShader(null,new BlurShader(blurSize))));
					view.posts.push(new PostEffect(new PostGLShader(null,new BlurShader(blurSize,false))));
					break;
				case "water":
					view.posts.push(new PostEffect(new PostGLShader(null, new TileableWaterCausticShader), 0));
					break;
				case "bend":
					view.posts.push(new PostEffect(new PostGLShader(null, new PulseShader)));
					break;
				case "heart":
					view.posts.push(new PostEffect(new PostGLShader(null, new HeartShader),0));
					break;
				case "flower":
					view.posts.push(new PostEffect(new PostGLShader(null, new FlowerShader),0));
					break;
				case "sinwater":
					view.posts.push(new PostEffect(new PostGLShader(null, new SinWaterShader)));
					break
				case "hdr":
					view.posts.push(new PostEffect(new PostGLShader(null, new HdrShader)));
					break;
				case "shape":
					view.posts.push(new PostEffect(new PostGLShader(null, new ShapeShader), 0));
					break;
				case "asciiart":
					view.posts.push(new PostEffect(new PostGLShader(null, new AsciiArtShader)));
					break;
				case "red":
					view.posts.push(new PostEffect(new PostGLShader(null, new RedScreenShader),0));
					break;
				case "def":
					view.posts.push(new PostEffect(new PostGLShader()));
			}
		}
	}

}