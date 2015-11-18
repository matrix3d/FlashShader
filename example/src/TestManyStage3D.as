package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.core.View3D;
	import gl3d.meshs.Meshs;
	import gl3d.meshs.Teapot;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestManyStage3D extends Sprite
	{
		private var view1:View3D;
		private var view2:View3D;
		private var view3:View3D;
		private var n1:Node3D;
		private var n2:Node3D;
		
		public function TestManyStage3D() 
		{
			addEventListener(Event.ENTER_FRAME, enterFrame);
			
			view1 = new View3D(0);
			addChild(view1);
			n1 = new Node3D;
			n1.drawable = Meshs.cube(1,1,1);
			n1.material = new Material;
			view1.scene.addChild(n1);
			view1.camera.perspective.perspectiveFieldOfViewLH(Math.PI / 4, view1.stage3dWidth/ view1.stage3dHeight, .1, 4000);
			view1.camera.z = -10;
			view1.lights[0].z = -1000;
			view1.scene.addChild(n1);
			
			view2 = new View3D(1);
			view2.x = 210;
			view2.y = 30;
			addChild(view2);
			view2.camera.z = -10;
			view2.camera.perspective.perspectiveFieldOfViewLH(Math.PI / 4, view1.stage3dWidth/ view1.stage3dHeight, .1, 4000);
			view2.lights[0].z = -10;
			n2 = new Node3D;
			n2.drawable = Teapot.teapot();
			n2.material = new Material;
			view2.scene.addChild(n2);
			
			
			view3 = new View3D(2);
			view3.scene = view1.scene;
			view3.y = 220;
			addChild(view3);
			view3.camera.perspective.orthoLH(view3.stage3dWidth/50, view3.stage3dHeight/50, .1, 4000);
			view3.camera.z = -10;
			view3.lights=view1.lights;
		}
		
		private function enterFrame(e:Event):void 
		{
			n1.matrix.appendRotation(1, Vector3D.Z_AXIS);
			n1.matrix.appendRotation(1, Vector3D.X_AXIS);
			n1.updateTransforms();
			view1.render();
			view2.render();
			view3.render();
		}
		
	}

}