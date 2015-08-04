package gl3d.core {
	import flash.display.Sprite;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProfile;
	import flash.display3D.Context3DRenderMode;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DTriangleFace;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import gl3d.core.renders.Render;
	import gl3d.core.renders.Stage3DRender;
	import gl3d.ctrl.Ctrl;
	import gl3d.post.PostEffect;
	import gl3d.util.Utils;
	/**
	 * ...
	 * @author lizhi
	 */
	public class View3D extends Sprite
	{
		public var scene:Node3D = new Node3D("scene");
		public var camera:Camera3D = new Camera3D;
		public var renderer:Render;
		public var lights:Vector.<Light> = new <Light>[new Light];
		public var fog:Fog;
		public var ctrls:Vector.<Ctrl> = new Vector.<Ctrl>;
		public var posts:Vector.<PostEffect> = new Vector.<PostEffect>;
		public var postRTTs:Vector.<TextureSet> = Vector.<TextureSet>([new TextureSet(null,true), new TextureSet(null,true)]);
		private var _antiAlias:int = 2;
		public var stage3dWidth:Number = 0;
		public var stage3dHeight:Number = 0;
		public var time:Number = 0;
		public var drawTriangleCounter:int = 0;
		public var drawCounter:int = 0;
		public var driverInfo:String;
		public var profile:String;
		public var background:uint = 0;
		public var invalid:Boolean = true;
		public function View3D() 
		{
			scene.addChild(camera);
			renderer = new Stage3DRender(this);
			for each(var light:Light in lights) {
				scene.addChild(light);
			}
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			renderer.init();
		}
		
		
		
		public function updateCtrl():void {
			for each(var ctrl:Ctrl in ctrls) {
				ctrl.update();
			}
		}
		
		public function render(time:Number=0):void {
			this.time = time;
			renderer.render(camera, scene);
		}
		
		public function get antiAlias():int 
		{
			return _antiAlias;
		}
		
		public function set antiAlias(value:int):void 
		{
			_antiAlias = value;
			invalid = true;
		}
	}

}