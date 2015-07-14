package  
{
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import gl3d.core.InstanceMaterial;
	import gl3d.core.Node3D;
	import gl3d.parser.DAEParser;
	import gl3d.util.Utils;
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
			//[Embed(source = "assets/test.dae", mimeType = "application/octet-stream")]var c:Class;
			var b:ByteArray = new c as ByteArray;
			p = new DAEParser;
			p.load(null, b);
			view.scene.addChild(p.root);
			p.root.setRotation(-90,180,0);
			p.root.scaleX = p.root.scaleY = p.root.scaleZ = 0.3;
			materialInstance = new InstanceMaterial;
			addEventListener(Event.ENTER_FRAME, enterFrame2);
		}
		
		private function enterFrame2(e:Event):void 
		{
			if (stats.fps > 30) {
				var base:int = stats.fps - 30;
				//addNode(base);
			}
		}
		
		private function addNode(num:int):void {
			while(num-->0){
				var d:int = 3;
				var clone:Node3D = p.root.clone();
				clone.x = (Math.random() - .5) * d;
				clone.y=(Math.random()-.5) * d;
				clone.z = (Math.random() - .5) * d;
				var rotation:Vector3D = new Vector3D;
				var random:Vector3D = Utils.randomSphere(null,rotation);
				clone.x = random.x * d;
				clone.y = random.y * d;
				clone.z = random.z * d;
				changeMaterial(clone);
				view.scene.addChild(clone);
			}
		}
		
		private function changeMaterial(node:Node3D):void {
			if (node.material) {
				materialInstance.wireframeAble = node.material.wireframeAble;
				node.material = materialInstance;
			}
			for each(var child:Node3D in node.children) {
				changeMaterial(child);
			}
		}
	}

}