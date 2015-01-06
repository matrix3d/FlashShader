package  
{
	import flash.events.Event;
	import flash.utils.ByteArray;
	import gl3d.core.InstanceMaterial;
	import gl3d.core.Node3D;
	import gl3d.parser.DAEParser;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestAnimation extends BaseExample
	{
		private var p:DAEParser;
		private var materialInstance:InstanceMaterial;
		
		public function TestAnimation() 
		{
			
		}
		
		override public function initNode():void 
		{
			//[Embed(source = "assets/monster.dae", mimeType = "application/octet-stream")]var c:Class;
			[Embed(source = "assets/astroBoy_walk_Max.dae", mimeType = "application/octet-stream")]var c:Class;
			var b:ByteArray = new c as ByteArray;
			p = new DAEParser;
			p.load(null, b);
			view.scene.addChild(p.root);
			p.root.scaleX = p.root.scaleY = p.root.scaleZ = .15;
			p.root.rotationX = -Math.PI/2 ;
			p.root.rotationY = Math.PI/2;
			p.addEventListener(Event.COMPLETE, p_complete);
			
			materialInstance = new InstanceMaterial;
		}
		
		private function p_complete(e:Event):void 
		{
			addNode(200);
		}
		
		private function addNode(num:int):void {
			while(num-->0){
				var d:int = 3;
				var clone:Node3D = p.root.clone();
				clone.x = (Math.random() - .5) * d;
				clone.y=(Math.random()-.5) * d;
				clone.z = (Math.random() - .5) * d;
				clone.rotationX = Math.random() * 2 * Math.PI;
				clone.rotationY = Math.random() * 2 * Math.PI;
				clone.rotationZ = Math.random() * 2 * Math.PI;
				changeMaterial(clone);
				view.scene.addChild(clone);
			}
		}
		
		private function changeMaterial(node:Node3D):void {
			if (node.material) {
				node.material = materialInstance;
			}
			for each(var child:Node3D in node.children) {
				changeMaterial(child);
			}
		}
	}

}