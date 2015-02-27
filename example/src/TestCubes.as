package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import gl3d.core.Drawable3D;
	import gl3d.core.InstanceMaterial;
	import gl3d.core.Node3D;
	import gl3d.meshs.Meshs;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestCubes extends BaseExample
	{
		
		public function TestCubes() 
		{
			
		}
		
		override public function initNode():void 
		{
			var cubed:Drawable3D = Meshs.cube();
			var c:int = 4000;
			view.antiAlias = 0;
			material.lightAble = false;
			var cube:Node3D = new Node3D;
			cube.scaleX = cube.scaleY = cube.scaleZ = .1;
			cube.material = material;
			view.scene.addChild(cube);
			cube.drawable = cubed;
			while (c-->0) {
				var clone:Node3D = cube.clone();
				clone.material = new InstanceMaterial;
				clone.x = Math.random()-.5;
				clone.y = Math.random()-.5;
				clone.z = Math.random()-.5;
				view.scene.addChild(clone);
			}
		}
		
		override public function enterFrame(e:Event):void 
		{
			var r:Vector3D = new Vector3D;
			for each(var cube:Node3D in view.scene.children) {
				//r = cube.getRotation(true,r);
				//cube.setRotation(r.x, r.y + 1, r.z);
				/*cube.x = cube.x;
				cube.x = cube.x;
				cube.x = cube.x;
				cube.x = cube.x;
				cube.x = cube.x;*/
			}
			super.enterFrame(e);
		}
	}

}