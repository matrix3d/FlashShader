package 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PNGEncoderOptions;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Matrix3D;
	import flash.geom.Orientation3D;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.system.System;
	import flash.utils.ByteArray;
	import flash.utils.CompressionAlgorithm;
	import gl3d.core.Drawable;
	import gl3d.core.DrawableSource;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.core.TextureSet;
	import gl3d.parser.fbx.FbxBinDecoder;
	import gl3d.parser.obj.OBJParser;
	import gl3d.util.Utils;
	import mx.utils.LoaderUtil;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Test extends Sprite
	{
		private var s:Sprite;
		
		public function Test() 
		{
			var a:uint = 0xff000000;
			var b:uint = 0xffffff;
			var c:uint = a | b;
			trace(uint(c >> 24));
		}
		
		private function s_mouseMove(e:MouseEvent):void 
		{
			trace(e.localX, e.localY);
		}
	}

}