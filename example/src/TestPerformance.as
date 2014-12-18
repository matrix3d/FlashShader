package  
{
	import flash.events.Event;
	import gl3d.core.InstanceMaterial;
	import gl3d.core.Node3D;
	import gl3d.meshs.Meshs;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestPerformance extends BaseExample
	{
		private var materialInstance:InstanceMaterial;
		
		public function TestPerformance() 
		{
			
		}
		
		override public function initNode():void 
		{
			super.initNode();
			teapot.scaleX = teapot.scaleY = teapot.scaleZ = .1;
			//teapot.drawable = Meshs.cube();
			//teapot.material.lightAble = false;
			materialInstance= new InstanceMaterial;
		}
		
		private function addNode(num:int):void {
			while(num-->0){
				var d:int = 3;
				var clone:Node3D = teapot.clone();
				clone.x = (Math.random() - .5) * d;
				clone.y=(Math.random()-.5) * d;
				clone.z = (Math.random() - .5) * d;
				clone.rotationX = Math.random() * 2 * Math.PI;
				clone.rotationY = Math.random() * 2 * Math.PI;
				clone.rotationZ = Math.random() * 2 * Math.PI;
				clone.material = materialInstance;
				view.scene.addChild(clone);
			}
		}
		
		override public function enterFrame(e:Event):void 
		{
			if (stats.fps>30) {
				addNode((stats.fps-30)*2);
			}
			super.enterFrame(e);
		}
		
		override public function initUI():void {
			super.initUI();
			if (aui.parent) {
				aui.parent.removeChild(aui);
			}
		}
		
	}

}