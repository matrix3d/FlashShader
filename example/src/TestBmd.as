package 
{
	import flash.display.Sprite;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestSMD extends BaseExample
	{
		
		public function TestSMD() 
		{
			
		}
		
		override public function initNode():void 
		{
			[Embed(source = "assets/smd/arctic.smd", mimeType = "application/octet-stream")]var c:Class;
			var smd:SMDParser = new SMDParser(new c + "");
			view.scene.addChild(smd.target);
			smd.target.rotationX = 90;
			smd.target.scaleX=
			smd.target.scaleY=
			smd.target.scaleZ = .05;
			smd.target.rotationZ = 180;
			[Embed(source = "assets/smd/jump.smd", mimeType = "application/octet-stream")]var c2:Class;
			var smd2:SMDParser = new SMDParser(new c2 + "", smd);
			//view.scene.addChild(smd2.target);
			smd2.target.rotationX = 90;
			smd2
			.target.scaleX=
			smd2.target.scaleY=
			smd2.target.scaleZ = .05;
			smd2.target.rotationZ = 180;
		}
		
	}

}