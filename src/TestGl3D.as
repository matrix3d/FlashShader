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
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestGl3D extends Sprite
	{
		private var view:View3D;
		private var material:Material = new Material;
		private var cube:Node3D;
		private var sphere:Node3D;
		
		public function TestGl3D() 
		{
			view = new View3D;
			addChild(view);
			
			view.camera.z = -10;
			view.light.z = -450;
			
			cube = new Node3D;
			cube.material = material;
			cube.drawable = Meshs.teapot(6);
			view.scene.addChild(cube);
			cube.scaleX = cube.scaleY = cube.scaleZ = .3;
			
			sphere = new Node3D;
			sphere.material = material;
			sphere.drawable = Meshs.sphere(20,20);
			//view.scene.addChild(sphere);
			
			addEventListener(Event.ENTER_FRAME, enterFrame);
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(Event.RESIZE, stage_resize);
			stage_resize();
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
			cube.x = -1;
			cube.rotationY += Math.PI / 180;
			cube.rotationX += 2*Math.PI / 180;
			
			sphere.x = 1;
			//sphere.scaleX = sphere.scaleY = sphere.scaleZ = .3;
			sphere.rotationY += Math.PI / 180;
			sphere.rotationX += 2*Math.PI / 180;
			
			//material.color[0] = Math.sin(getTimer()/400)/2+.5;
			//material.color[1] = Math.sin(getTimer()/500)/2+.5;
			//material.color[2] = Math.sin(getTimer()/600)/2+.5;
			view.light.x = mouseX - stage.stageWidth / 2
			view.light.y=stage.stageHeight/2-mouseY, -400
			
			view.render();
		}
		
	}

}