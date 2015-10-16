package 
{
	import flash.display.Sprite;
	import flash.utils.ByteArray;
	import gl3d.parser.fbx.FbxDecoder;
	import gl3d.parser.fbx.FBXParser;
	import gl3d.util.Utils;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestFBX extends BaseExample
	{
		
		public function TestFBX() 
		{
			
		}
		
		override public function initNode():void 
		{
			/*var test:Object=( new FbxDecoder("test:  test2:2")).obj.childs;
			trace(JSON.stringify(test, null, 4));
			return;*/
			//[Embed(source = "assets/test4.FBX", mimeType = "application/octet-stream")]var c:Class;
			[Embed(source = "assets/aoying.FBX", mimeType = "application/octet-stream")]var c:Class;
			//[Embed(source = "assets/blender.FBX", mimeType = "application/octet-stream")]var c:Class;
			var fbx:FBXParser = new FBXParser(new c + "");
			view.scene.addChild(fbx.rootNode);
			fbx.rootNode.scaleX=
			fbx.rootNode.scaleY=
			fbx.rootNode.scaleZ = .01;
			fbx.rootNode.rotationX = -90;
			fbx.rootNode.rotationY = 180;
			//fbx.rootNode.scaleZ *= -1;
		}
		
	}

}