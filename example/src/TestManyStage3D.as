package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.core.View3D;
	import gl3d.meshs.Meshs;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestManyStage3D extends Sprite
	{
		private var view1:View3D;
		private var view2:View3D;
		private var n1:Node3D;
		private var n2:Node3D;
		
		public function TestManyStage3D() 
		{
			view1 = new View3D(1);
			view2 = new View3D(0);
			view1.x = 210;
			view1.y = 30;
			addChild(view1);
			addChild(view2);
			addEventListener(Event.ENTER_FRAME, enterFrame);
			
			n1 = new Node3D;
			n1.drawable = Meshs.cube(1,1,1);
			n1.material = new Material;
			view1.scene.addChild(n1);
			view1.camera.perspective.perspectiveFieldOfViewLH(Math.PI / 4, view1.stage3dWidth/ view1.stage3dHeight, .1, 4000);
			view1.camera.z = -10;
			view1.lights[0].z = -1000;
			view1.scene.addChild(n1);
			
			view2.camera.z = -10;
			view2.camera.perspective.perspectiveFieldOfViewLH(Math.PI / 4, view1.stage3dWidth/ view1.stage3dHeight, .1, 4000);
			view2.lights[0].z = -10;
			n2 = new Node3D;
			n2.drawable = Meshs.cube(1,1,1);
			n2.material = new Material;
			view2.scene.addChild(n2);
		}
		
		private function enterFrame(e:Event):void 
		{
			n1.matrix.appendRotation(1, Vector3D.Z_AXIS);
			n1.matrix.appendRotation(1, Vector3D.X_AXIS);
			n1.updateTransforms();
			view1.render();
			view2.render();
		}
		
	}

}