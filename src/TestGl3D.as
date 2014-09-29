package  
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.utils.getTimer;
	import gl3d.Drawable3D;
	import gl3d.Material;
	import gl3d.Meshs;
	import gl3d.Node3D;
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
		public function TestGl3D() 
		{
			view = new View3D;
			addChild(view);
			
			view.camera.z = -10;
			view.light.z = -450;
			
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
			aui.bind(view.light, "specularPower", AttribSeter.TYPE_NUM);
			aui.bind(view.light, "color", AttribSeter.TYPE_VEC_COLOR);
			aui.bind(view.light, "ambient", AttribSeter.TYPE_VEC_COLOR);
			aui.bind(material, "color", AttribSeter.TYPE_VEC_COLOR);
		}
		
		private function stage_resize(e:Event=null):void 
		{
			view.invalid = true;
			var w:Number = stage.stageWidth;
			var h:Number = stage.stageHeight;
			view.camera.perspective.perspectiveLH(w/400, h/400, 3.3, 1000);
		}
		
		private function enterFrame(e:Event):void 
		{
			teapot.rotationY=sphere.rotationY= cube.rotationY += Math.PI / 180;
			teapot.rotationX = sphere.rotationX = cube.rotationX += 2 * Math.PI / 180;
			
			view.light.x = mouseX - stage.stageWidth / 2
			view.light.y=stage.stageHeight/2-mouseY, -400
			view.render();
			
			aui.update();
		}
		
	}

}