package 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Matrix3D;
	import flash.geom.Orientation3D;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.system.System;
	import flash.utils.ByteArray;
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
	public class Test extends BaseExample
	{
		
		public function Test() 
		{
			try{
			Security.allowDomain("*");
			}catch (err2:Error) {
				
			}
			var urlloader:URLLoader = new URLLoader;
			urlloader.addEventListener(IOErrorEvent.IO_ERROR, urlloader_Error);
			urlloader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, urlloader_Error);
			try{
				urlloader.load(new URLRequest("C://Users/aaaa/Desktop/test2.fbx"));
				//urlloader.load(new URLRequest("http://matrix3d.github.io/"));
			}catch (err:Error) {
				if (ExternalInterface.available) {
					ExternalInterface.call("alert","error:"+err.name);
				}
			}
			
		}
		
		private function urlloader_Error(e:Event):void 
		{
			if (ExternalInterface.available) {
				ExternalInterface.call("alert",e.type);
			}
		}
		
		override public function initNode():void 
		{

		}
	}

}