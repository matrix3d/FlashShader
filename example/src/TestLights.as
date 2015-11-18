package 
{
	import flash.events.Event;
	import flash.geom.Vector3D;
	import gl3d.core.Light;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.meshs.Meshs;
	import gl3d.meshs.Teapot;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestLights extends BaseExample
	{
		private var node:Node3D;
		
		public function TestLights() 
		{
			
		}
		
		override public function initNode():void 
		{
			node = new Node3D;
			view.scene.addChild(node);
			node.drawable = Teapot.teapot();
			node.material = new Material;
			
			var plane:Node3D = new Node3D;
			view.scene.addChild(plane);
			plane.drawable = Meshs.cube(20, 20, 20);
			plane.drawable.index.data.reverse();
			plane.material = new Material;
		}
		
		override public function initLight():void 
		{
			view.lights.length = 0;
			var light1:Light = new Light();
			view.lights.push(light1);
			var light2:Light = new Light();
			view.lights.push(light2);
			var light3:Light = new Light();
			view.lights.push(light3);
			var light4:Light = new Light();
			view.lights.push(light4);
			
			light1.x = 10;
			light1.lightType = Light.POINT;
			light1.color.setTo(2, 0, 0);
			light2.x = -10;
			light2.lightType = Light.POINT;
			light2.color.setTo(0, 2, 0);
			light3.z = 10;
			light3.lightType = Light.POINT;
			light3.color.setTo(0, 0, 2);
			light4.z = -10;
			light4.lightType = Light.POINT;
			light4.color.setTo(2, 2, 0);
		}
		
		override public function enterFrame(e:Event):void 
		{
			node.matrix.appendRotation(1, Vector3D.Y_AXIS);
			//node.matrix.appendRotation(2, Vector3D.X_AXIS);
			node.updateTransforms();
			super.enterFrame(e);
		}
		
	}

}