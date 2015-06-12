package 
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import gl3d.parser.OBJParser;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestOBJ extends BaseExample
	{
		
		public function TestOBJ() 
		{
		}
		
		override public function initNode():void 
		{
			//[Embed(source = "assets/untitled.obj", mimeType = "application/octet-stream")]var c:Class;
			[Embed(source = "assets/test3.obj", mimeType = "application/octet-stream")]var c:Class;
			var p:OBJParser = new OBJParser((new c) + "");
			view.scene.addChild(p.target);
		}
		
	}

}