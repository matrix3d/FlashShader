package 
{
	import flash.display.Sprite;
	import gl3d.parser.MMD;
	import gl3d.parser.PmxParser;
	//import gl3d.parser.Pmx;
	/**
	 * ...
	 * @author ...
	 */
	public class TestPMX extends BaseExample
	{
		
		public function TestPMX() 
		{
			
		}
		
		override public function initNode():void 
		{
			[Embed(source = "assets/miku.pmx", mimeType = "application/octet-stream")]var c:Class;
			//[Embed(source = "assets/haku.pmx", mimeType = "application/octet-stream")]var c:Class;
			//var mmd:MMD = new MMD(new c);
			//trace(JSON.stringify(new MMD(new c),null,4))
			var p:PmxParser = new PmxParser(new c );
			p.node.scaleX=
			p.node.scaleY=
			p.node.scaleZ = .1;
			view.scene.addChild(p.node);
		}
		
	}

}