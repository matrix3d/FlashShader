package 
{
	import flash.display.Sprite;
	import gl3d.parser.mmd.PMX;
	import gl3d.parser.mmd.MMD;
	import gl3d.parser.mmd.VMD;
	import gl3d.util.Utils;
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
			
			[Embed(source = "assets/melt.vmd", mimeType = "application/octet-stream")]var c2:Class;
			var p:MMD = new MMD(new c );
			p.node.scaleX=
			p.node.scaleY=
			p.node.scaleZ = .1;
			view.scene.addChild(p.node);
			
			var vmd:VMD = new VMD(new c2);
			p.bind(vmd);
		}
		
	}

}