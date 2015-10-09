package 
{
	import flash.display.Sprite;
	import gl3d.core.Node3D;
	import gl3d.parser.ColladaDecoder;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestCollada extends BaseExample
	{
		
		public function TestCollada() 
		{
		}
		
		
		override public function initNode():void 
		{
			addSky();
			//[Embed(source = "assets/astroBoy_walk_Max.dae", mimeType = "application/octet-stream")]
			//[Embed(source = "assets/yuren.dae", mimeType = "application/octet-stream")]
			[Embed(source = "assets/yurengongji.dae", mimeType = "application/octet-stream")]
			//[Embed(source = "assets/untitled.dae", mimeType = "application/octet-stream")]
			//[Embed(source = "assets/duck.dae", mimeType = "application/octet-stream")]
			var c:Class;
			var decoder:ColladaDecoder = new ColladaDecoder(new c + "");
			decoder.scenes[0].scaleX=
			decoder.scenes[0].scaleY=
			decoder.scenes[0].scaleZ = 1 / 30;
			traceNode(decoder.scenes[0],0);
			view.scene.addChild(decoder.scenes[0]);
			//decoder.scenes[0].rotationX = -90;
			//decoder.scenes[0].rotationY = 180;
		}
		
		private function traceNode(node:Node3D,depth:int):void {
			var tab:String = "";
			for (var i:int = 0; i < depth;i++ ) {
				tab += "\t";
			}
			trace(tab+node.name+":"+node.type);
			for each(var c:Node3D in node.children) {
				traceNode(c, depth + 1);
			}
		}
	}

}