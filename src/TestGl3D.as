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
			
			view.camera.matrix.appendTranslation(0, 0, -10);
			view.light.matrix.appendTranslation(0, 0, -1);
			
			cube = new Node3D;
			cube.material = material;
			cube.drawable = Meshs.cube(.5,.5,.5);
			view.scene.addChild(cube);
			
			sphere = new Node3D;
			sphere.material = material;
			sphere.drawable = Meshs.sphere(14,14);
			view.scene.addChild(sphere);
			
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
			cube.matrix.identity();
			//cube.matrix.appendRotation(1, Vector3D.Y_AXIS);
			//cube.matrix.appendRotation(.7, Vector3D.X_AXIS);
			cube.matrix.appendTranslation( -1.6, 0, 0);
			
			sphere.matrix.identity();
			sphere.matrix.appendScale(.3, .3, .3);
			sphere.matrix.appendRotation(1, Vector3D.Y_AXIS);
			sphere.matrix.appendRotation(.7, Vector3D.X_AXIS);
			sphere.matrix.appendTranslation( 0, 0, 0);
			
			
			material.color[0] = Math.sin(getTimer()/400)/2+.5;
			material.color[1] = Math.sin(getTimer()/500)/2+.5;
			material.color[2] = Math.sin(getTimer()/600)/2+.5;
			view.light.matrix.identity();
			view.light.matrix.appendTranslation(mouseX-stage.stageWidth/2, stage.stageHeight/2-mouseY, -400);
			
			view.render();
		}
		
	}

}