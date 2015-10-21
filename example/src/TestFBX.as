package 
{
	import flash.display.Sprite;
	import flash.geom.Matrix3D;
	import flash.system.System;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import gl3d.core.Node3D;
	import gl3d.parser.fbx.FbxBinDecoder;
	import gl3d.parser.fbx.FbxTextDecoder;
	import gl3d.parser.fbx.FbxParser;
	import gl3d.parser.fbx.FbxTools;
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
			//[Embed(source = "assets/cubebin.fbx", mimeType = "application/octet-stream")]var c:Class;
			//[Embed(source = "assets/test4bin.fbx", mimeType = "application/octet-stream")]var c:Class;
			//[Embed(source = "assets/test4.FBX", mimeType = "application/octet-stream")]var c:Class;
			//[Embed(source = "assets/cubetext.FBX", mimeType = "application/octet-stream")]var c:Class;
			[Embed(source = "assets/aoying.FBX", mimeType = "application/octet-stream")]var c:Class;
			//[Embed(source = "assets/yurenxuanfeng.FBX", mimeType = "application/octet-stream")]var c:Class;
			//[Embed(source = "assets/aoying gongji.FBX", mimeType = "application/octet-stream")]var c:Class;
			//[Embed(source = "assets/blender.FBX", mimeType = "application/octet-stream")]var c:Class;
			var fbx:FbxParser = new FbxParser(new c);
			view.scene.addChild(fbx.rootNode);
			fbx.rootNode.scaleX=
			fbx.rootNode.scaleY=
			fbx.rootNode.scaleZ = 0.01;
			fbx.rootNode.rotationX = -90;
			fbx.rootNode.rotationY = 180;
			//fbx.rootNode.scaleZ *= -1;
			Utils.traceNode(fbx.rootNode);
			
		}
		
	}

}