package 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import gl3d.ctrl.FirstPersonCtrl;
	import gl3d.core.Material;
	import gl3d.meshs.Meshs;
	import gl3d.core.Node3D;
	import gl3d.parser.DAEParser;
	import gl3d.post.PostEffect;
	import gl3d.shaders.posts.FlowerShader;
	import gl3d.shaders.posts.HeartShader;
	import gl3d.shaders.posts.PostGLShader;
	import gl3d.shaders.posts.BlurShader;
	import gl3d.shaders.posts.PulseShader;
	import gl3d.shaders.posts.SinWaterShader;
	import gl3d.shaders.posts.TileableWaterCausticShader;
	import gl3d.core.TextureSet;
	import gl3d.core.View3D;
	import ui.AttribSeter;
	import ui.Color;
	/**
	 * ...
	 * @author lizhi
	 */
	[SWF(frameRate='60', backgroundColor='0x000000', width='800', height='600')]
	public class BaseExample extends Sprite
	{
		public var view:View3D;
		private var aui:AttribSeter = new AttribSeter;
		private var _useTexture:Boolean = true;
		private var texture:TextureSet;
		private var normalMapTexture:TextureSet;
		private var teapot:Node3D;
		public var material:Material = new Material;
		public var _post:String;
		public function BaseExample() 
		{
			view = new View3D;
			addChild(view);
			view.camera.z = -10;
			
			var bmd:BitmapData = new BitmapData(128, 128, false, 0xff0000);
			bmd.perlinNoise(30, 30, 2, 1, true, true);
			texture = new TextureSet(bmd);
			
			normalMapTexture = createNormalMap();
			
			//material.normalMapAble = true;
			material.textureSets = Vector.<TextureSet>([texture]);
			if (material.normalMapAble) {
				material.textureSets.push( normalMapTexture);
			}
			
			material.color = Vector.<Number>([.6, .6, .6, 1]);
			
			initLight();
			initNode();
			initUI();
			initCtrl();
			
			addEventListener(Event.ENTER_FRAME, enterFrame);
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(Event.RESIZE, stage_resize);
			stage_resize();
			//post = "water";
			//post = "heart";
			//post = "flower";
			//post="sinwater"
		}
		
		public function createNormalMap():TextureSet {
			var bmd:BitmapData = new BitmapData(512, 512, false, 0);
			bmd.perlinNoise(50, 50, 4, 1,true,true);
			//[Embed(source = "mandelbrot.png")]var c:Class;
			//bmd = (new c as Bitmap).bitmapData;
			var bmd2:BitmapData = bmd.clone();
			var valuePX:Color = new Color;
			var valueNX:Color = new Color;
			var valuePY:Color = new Color;
			var valueNY:Color = new Color;
			var neighbors:Color = new Color;
			var slope:Color = new Color;
			var scale:Number = 4.5;
			var kUseTwoMaps:Boolean = true;
			for (var x:int = 0; x < bmd.width;x++ ) {
				for (var y:int = 0; y < bmd.height; y++ ) {
					valuePX.fromHex(bmd.getPixel(x+1,y));
					valueNX.fromHex(bmd.getPixel(x-1,y));
					valuePY.fromHex(bmd.getPixel(x,y+1));
					valueNY.fromHex(bmd.getPixel(x,y-1));
					valuePX.scale(1 / 0xff);
					valueNX.scale(1 / 0xff);
					valuePY.scale(1 / 0xff);
					valueNY.scale(1 / 0xff);
					
					if (kUseTwoMaps) {
						var factor:Number = 1.0 / (2.0 * 255.0); // 255.0 * 2.0
						// Reconstruct the high-precision values from the low precision values
						valuePX.r += 255.0 * (valuePX.b - 0.5);
						valueNX.r += 255.0 * (valueNX.b - 0.5);
						valuePY.r += 255.0 * (valuePY.b - 0.5);
						valueNY.r += 255.0 * (valueNY.b - 0.5);
					}else {
						factor = 1.0 / 2.0;
					}
					// Take into account the boundary conditions in the pool
					
					neighbors.r = valuePX.r * (valuePX.g) + (1.0 - valuePX.g) * valueNX.r; // Enforce the boundary conditions as mirror reflections
					neighbors.g = valuePY.r * (valuePY.g) + (1.0 - valuePY.g) * valueNY.r; // Enforce the boundary conditions as mirror reflections
					neighbors.b = valueNX.r * (valueNX.g) + (1.0 - valueNX.g) * valuePX.r; // Enforce the boundary conditions as mirror reflections
					var w:Number = valueNY.r * (valueNY.g) + (1.0 - valueNY.g) * valuePY.r; // Enforce the boundary conditions as mirror reflections
					 
					slope.fromRGB(scale * (neighbors.b - neighbors.r) * factor, 
										   scale * (w - neighbors.g) * factor, 1.0);
					
					slope.r *= 5.0;
					slope.g *= 5.0;
					slope.r += .5;
					slope.g += .5;
					slope.scale(0xff);
					bmd2.setPixel(x,y,slope.toHex() );
				}
			}
			//addChild(new Bitmap(bmd2));
			return new TextureSet(bmd2);
		}
		
		public function initLight():void {
			view.light.z = -450;
			view.light.lightPower = 2;
		}
		public function initNode():void {
			teapot = new Node3D;
			teapot.material = material;
			teapot.drawable = Meshs.teapot(4);
			view.scene.addChild(teapot);
			teapot.scaleX = teapot.scaleY = teapot.scaleZ = .5;
			
			//[Embed(source = "assets/monster.dae", mimeType = "application/octet-stream")]var c:Class;
			/*[Embed(source = "assets/astroBoy_walk_Max.dae", mimeType = "application/octet-stream")]var c:Class;
			var b:ByteArray = new c as ByteArray;
			var p:DAEParser = new DAEParser;
			p.load(null, b);
			view.scene.addChild(p.root);
			p.target.scaleX = p.target.scaleY = p.target.scaleZ = .5// / 500;
			p.target.rotationX = -Math.PI / 2;
			p.target.rotationY = Math.PI;*/
		}
		
		public function initUI():void {
			addChild(aui);
			aui.bind(view.light, "specularPower", AttribSeter.TYPE_NUM, new Point(1, 100));
			aui.bind(view.light, "lightPower", AttribSeter.TYPE_NUM, new Point(.5, 5));
			aui.bind(view.light, "color", AttribSeter.TYPE_VEC_COLOR);
			aui.bind(view.light, "ambient", AttribSeter.TYPE_VEC_COLOR);
			aui.bind(material, "color", AttribSeter.TYPE_VEC_COLOR);
			aui.bind(material, "alpha", AttribSeter.TYPE_NUM, new Point(.1, 1));
			aui.bind(material, "wireframeAble", AttribSeter.TYPE_BOOL);
			aui.bind(this, "useTexture", AttribSeter.TYPE_BOOL);
			aui.bind(this, "post", AttribSeter.TYPE_LIST_STR,null,["null","blur","water","bend","heart","flower","sinwater"]);
		}
		public function initCtrl():void {
			view.ctrls.push(new FirstPersonCtrl(view.camera,stage));
		}
		
		private function stage_resize(e:Event = null):void
		{
			view.invalid = true;
			var w:Number = stage.stageWidth;
			var h:Number = stage.stageHeight;
			view.camera.perspective.perspectiveFieldOfViewLH(Math.PI / 4, stage.stageWidth / stage.stageHeight, 1, 4000);
		}
		
		public function enterFrame(e:Event):void
		{
			if (view.context)
				view.context.enableErrorChecking = true;
			if(teapot){
				//teapot.rotationX+=.01;
				//teapot.rotationY += .01;
			}
			view.updateCtrl();
			view.render(getTimer());
			
			aui.update();
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
				material.textureSets = value ? Vector.<TextureSet>([texture/*,normalMapTexture*/]) : new Vector.<TextureSet>;
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
					var blurSize:Number = 1 / 400;
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
			}
		}
	}

}