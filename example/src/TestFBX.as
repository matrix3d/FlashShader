package 
{
	import flash.display.Sprite;
	import flash.utils.ByteArray;
	import gl3d.parser.fbx.FbxDecoder;
	import gl3d.parser.fbx.FBXParser;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestFBX extends Sprite
	{
		
		public function TestFBX() 
		{
			[Embed(source = "assets/test4.FBX", mimeType = "application/octet-stream")]var c:Class;
			var fbx:FBXParser = new FBXParser(new c + "");
		}
		
		
		
	}

}