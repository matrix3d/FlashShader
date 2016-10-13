package 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Vector3D;
	import gl3d.core.InstanceMaterial;
	import gl3d.core.Light;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.core.View3D;
	import gl3d.ctrl.ArcBallCtrl;
	import gl3d.meshs.Meshs;
	import flash.events.Event;
	import gl3d.meshs.Teapot;
	import gl3d.util.Stats;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Test extends Sprite
	{
		private var view:View3D;
		private var n1:Node3D;
		public function Test() 
		{
			view = new View3D(0);
			view.stage3dWidth = 800;
			view.stage3dHeight = 600;
			addChild(view);
			addEventListener(Event.ENTER_FRAME, enterFrame);
			
			var light:Light = new Light;
			view.scene.addChild(light);
			light.z = -4500;
			light.y = 4500;
			
			n1 = new Node3D;
			n1.drawable = Meshs.cube(.1, .1, .1);
			n1.material = new Material;
			n1.material.lightAble = true;
			for (var i:int = 0; i < 5000;i++ ){
				var n2:Node3D = n1.clone();
				//n2.material = new InstanceMaterial();
				n2.x=3*(Math.random()-.5)
				n2.y=3*(Math.random()-.5)
				n2.z=3*(Math.random()-.5)
				view.scene.addChild(n2);
			}
			view.camera.perspectiveFieldOfViewLH(Math.PI / 4, view.stage3dWidth/ view.stage3dHeight, .1, 4000);
			view.camera.z = -10;
			view.scene.addChild(n1);
			
			addChild(new Stats(view));
			var ct:ArcBallCtrl = new ArcBallCtrl(view.camera, stage);
			view.ctrls.push(ct);
		}
		
		private function enterFrame(e:Event):void 
		{
			/*n1.matrix.appendRotation(1, Vector3D.X_AXIS);
			n1.matrix.appendRotation(2, Vector3D.Y_AXIS);
			n1.updateTransforms();*/
			view.updateCtrl();
			view.render();
		}
		
	}

}