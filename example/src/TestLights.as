package 
{
	import gl3d.core.Light;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.meshs.Meshs;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestLights extends BaseExample
	{
		
		public function TestLights() 
		{
			
		}
		
		override public function initNode():void 
		{
			var node:Node3D = new Node3D;
			view.scene.addChild(node);
			node.drawable = Meshs.cube();
			node.material = new Material;
			
			var plane:Node3D = new Node3D;
			plane.z = 5;
			view.scene.addChild(plane);
			plane.drawable = Meshs.plane(100);
			plane.material = new Material;
			//plane.rotationX = 90;
			
			//view.camera.y = -2;
		}
		
		override public function initLight():void 
		{
			view.lights.length = 0;
			var light1:Light = new Light();
			view.lights.push(light1);
			var light2:Light = new Light();
			//view.lights.push(light2);
			var light3:Light = new Light();
			//view.lights.push(light3);
			var light4:Light = new Light();
			//view.lights.push(light4);
			
			light1.x = 10;
			//light1.lightType = Light.SPOT;
			light1.color.setTo(1, 0, 0);
			light2.x = -10;
			light2.lightType = Light.SPOT;
			light2.color.setTo(0, 1, 0);
			light3.z = 10;
			light3.lightType = Light.SPOT;
			light3.color.setTo(0, 0, 1);
			light4.z = -10;
			light4.lightType = Light.SPOT;
			light4.color.setTo(1, 1, 0);
		}
		
	}

}