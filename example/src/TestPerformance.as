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
			teapot.scaleX = teapot.scaleY = teapot.scaleZ = .4;
			//teapot.drawable = Meshs.cube();
			/*teapot.material.lightAble = false;
			teapot.material.textureSets.length = 1;*/
			materialInstance = new InstanceMaterial;
			materialInstance.wireframeAble = teapot.material.wireframeAble;
			materialInstance.normalMapAble = material.normalMapAble;
		}
		
		private function addNode(num:int):void {
			while(num-->0){
				var d:int = 3;
				var clone:Node3D = teapot.clone();
				clone.x = (Math.random() - .5) * d;
				clone.y=(Math.random()-.5) * d;
				clone.z = (Math.random() - .5) * d;
				clone.material = materialInstance;
				view.scene.addChild(clone);
			}
		}
		
		override public function enterFrame(e:Event):void 
		{
			if (stats.fps > 30) {
				var base:int = stats.fps - 30;
				addNode(base);
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