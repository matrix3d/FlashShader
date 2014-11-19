package 
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import gl3d.ctrl.FirstPersonCtrl;
	import gl3d.Material;
	import gl3d.meshs.Meshs;
	import gl3d.Node3D;
	import gl3d.post.PostEffect;
	import gl3d.shaders.posts.FlowerShader;
	import gl3d.shaders.posts.HeartShader;
	import gl3d.shaders.posts.PostGLShader;
	import gl3d.shaders.posts.BlurShader;
	import gl3d.shaders.posts.PulseShader;
	import gl3d.shaders.posts.TileableWaterCausticShader;
	import gl3d.TextureSet;
	import gl3d.View3D;
	import ui.AttribSeter;
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
			
			material.textureSets = Vector.<TextureSet>([texture/*,normalMapTexture*/]);
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
		}
		
		public function createNormalMap():TextureSet {
			var bmd:BitmapData = new BitmapData(512, 512, false, 0);
			bmd.perlinNoise(5, 5, 4, 1,true,true);
			var byte:ByteArray = bmd.getPixels(bmd.rect);
			for (var i:int = 0; i < byte.length;i+=4 ) {
				var r:Number = byte[i + 1]/0xff;
				var g:Number = byte[i + 2]/0xff;
				var b:Number = byte[i + 3]/0xff;
				r = r * 2 - 1;
				g = g * 2 -1;
				b = (b+1);
				var msg:Number = Math.sqrt(r * r + g * g + b * b);
				r /= msg;
				g /= msg;
				b /= msg;
				
				r = (r+1)/2;
				g = (g+1)/2
				b = (b + 1) / 2;
				
				r = .5;
				g = .5;
				b = 1;
				byte[i + 1] = r * 0xff;
				byte[i + 2] = g * 0xff;
				byte[i + 3] = b * 0xff;
			}
			byte.position = 0;
			bmd.setPixels(bmd.rect, byte);
			return new TextureSet(bmd);
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
			teapot.scaleX = teapot.scaleY = teapot.scaleZ = 0.3;
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
			aui.bind(this, "post", AttribSeter.TYPE_LIST_STR,null,["null","blur","water","bend","heart","flower"]);
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
				teapot.rotationX+=.01;
				teapot.rotationY += .01;
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
			}
		}
	}

}