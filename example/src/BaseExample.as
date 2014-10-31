package 
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Point;
	import gl3d.ctrl.FirstPersonCtrl;
	import gl3d.Material;
	import gl3d.meshs.Meshs;
	import gl3d.Node3D;
	import gl3d.TextureSet;
	import gl3d.View3D;
	import ui.AttribSeter;
	/**
	 * ...
	 * @author lizhi
	 */
	public class BaseExample extends Sprite
	{
		public var view:View3D;
		private var aui:AttribSeter = new AttribSeter;
		private var _useTexture:Boolean = true;
		private var texture:TextureSet;
		public var material:Material = new Material;
		public function BaseExample() 
		{
			view = new View3D;
			addChild(view);
			
			view.camera.z = -10;
			
			var bmd:BitmapData = new BitmapData(128, 128, false, 0xff0000);
			bmd.perlinNoise(30, 30, 2, 1, true, true);
			texture = new TextureSet(bmd);
			material.textureSets = Vector.<TextureSet>([texture]);
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
		}
		
		public function initLight():void {
			view.light.z = -450;
			view.light.lightPower = 2;
		}
		public function initNode():void {
			var teapot:Node3D = new Node3D;
			teapot.material = material;
			teapot.drawable = Meshs.teapot(6);
			view.scene.addChild(teapot);
			teapot.scaleX = teapot.scaleY = teapot.scaleZ = .3;
		}
		
		public function initUI():void {
			addChild(aui);
			aui.bind(view.light, "specularPower", AttribSeter.TYPE_NUM, new Point(1, 100));
			aui.bind(view.light, "lightPower", AttribSeter.TYPE_NUM, new Point(.5, 5));
			aui.bind(view.light, "color", AttribSeter.TYPE_VEC_COLOR);
			aui.bind(view.light, "ambient", AttribSeter.TYPE_VEC_COLOR);
			aui.bind(material, "color", AttribSeter.TYPE_VEC_COLOR);
			aui.bind(material, "alpha", AttribSeter.TYPE_NUM, new Point(.1, 1));
			aui.bind(this, "useTexture", AttribSeter.TYPE_BOOL);
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
			view.updateCtrl();
			view.render();
			
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
				material.textureSets = value ? Vector.<TextureSet>([texture]) : new Vector.<TextureSet>;
			}
		}
		
	}

}