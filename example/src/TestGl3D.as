package  
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.utils.getTimer;
	import gl3d.Drawable3D;
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
	public class TestGl3D extends Sprite
	{
		private var view:View3D;
		private var material:Material = new Material;
		
		private var teapot:Node3D
		private var cube:Node3D;
		private var sphere:Node3D;
		
		private var aui:AttribSeter = new AttribSeter;
		private var _useTexture:Boolean = true;
		private var texture:TextureSet;
		public function TestGl3D() 
		{
			view = new View3D;
			addChild(view);
			
			view.camera.z = -10;
			view.light.z = -450;
			view.light.lightPower = 2;
			
			//view.light.lightAble = false;
			//view.light.lightPowerAble = false;
			
			var bmd:BitmapData = new BitmapData(128, 128, false, 0xff0000);
			bmd.perlinNoise(30, 30, 2, 1, true, true);
			texture=new TextureSet(bmd);
			material.textureSets = Vector.<TextureSet>([texture]);
			material.color = Vector.<Number>([.6,.6,.6,1]);
			
			teapot = new Node3D;
			teapot.material = material;
			teapot.drawable = Meshs.teapot(6);
			view.scene.addChild(teapot);
			teapot.scaleX = teapot.scaleY = teapot.scaleZ = .3;
			
			cube = new Node3D;
			cube.material = material;
			cube.drawable = Meshs.cube();
			view.scene.addChild(cube);
			cube.scaleX = cube.scaleY = cube.scaleZ = .8;
			cube.x = -2;
			
			sphere = new Node3D;
			sphere.material = material;
			sphere.drawable = Meshs.sphere(20, 20);
			view.scene.addChild(sphere);
			sphere.scaleX = sphere.scaleY = sphere.scaleZ = .5;
			sphere.x = 2;
			
			addEventListener(Event.ENTER_FRAME, enterFrame);
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(Event.RESIZE, stage_resize);
			stage_resize();
			
			addChild(aui);
			aui.bind(view.light, "specularPower", AttribSeter.TYPE_NUM,new Point(1,100));
			aui.bind(view.light, "lightPower", AttribSeter.TYPE_NUM,new Point(.5,5));
			aui.bind(view.light, "color", AttribSeter.TYPE_VEC_COLOR);
			aui.bind(view.light, "ambient", AttribSeter.TYPE_VEC_COLOR);
			aui.bind(material, "color", AttribSeter.TYPE_VEC_COLOR);
			aui.bind(material, "alpha", AttribSeter.TYPE_NUM,new Point(.1,1));
			aui.bind(this, "useTexture", AttribSeter.TYPE_BOOL);
			
			
			stage.addEventListener(MouseEvent.CLICK, stage_click);
		}
		
		private function stage_click(e:MouseEvent):void 
		{
			var rayOrigin:Vector3D = new Vector3D;
			var rayDirection:Vector3D = new Vector3D;
			var pixelPos:Vector3D = new Vector3D;
			
			
			view.camera.computePickRayDirectionMouse(mouseX,mouseY,stage.stageWidth,stage.stageHeight,rayOrigin, rayDirection, pixelPos);
			for each(var node:Node3D in view.collects) {
				trace(node,node.rayMeshTest(rayOrigin, rayDirection));
			}
		}
		
		private function stage_resize(e:Event=null):void 
		{
			view.invalid = true;
			var w:Number = stage.stageWidth;
			var h:Number = stage.stageHeight;
			view.camera.perspective.perspectiveFieldOfViewLH(Math.PI / 4, stage.stageWidth / stage.stageHeight, 1, 4000);
		}
		
		private function enterFrame(e:Event):void 
		{
			if(view.context)
			view.context.enableErrorChecking = true;
			teapot.rotationY=sphere.rotationY= cube.rotationY += Math.PI / 180;
			teapot.rotationX = sphere.rotationX = cube.rotationX += 2 * Math.PI / 180;
			
			view.light.x = mouseX - stage.stageWidth / 2
			view.light.y = stage.stageHeight / 2 - mouseY ;
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
			if (value != _useTexture) {
				_useTexture = value;
				material.invalid = true;
				material.textureSets = value?Vector.<TextureSet>([texture]):new Vector.<TextureSet>;
			}
		}
		
	}

}