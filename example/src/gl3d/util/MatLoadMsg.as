package gl3d.util 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import gl3d.core.Material;
	import gl3d.core.TextureSet;
	/**
	 * ...
	 * @author lizhi
	 */
	public class MatLoadMsg 
	{
		private var mat:Material;
		private var loader:Loader;
		private var url:String;
		public function MatLoadMsg(url:String,mat:Material) 
		{
			url = url.substring( url.lastIndexOf("\\") + 1, url.lastIndexOf(".")) + ".png";
			this.url = url;
			trace(url);
			this.mat = mat;
			loader = new Loader;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_complete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loader_ioError);
			loader.load(new URLRequest(url));
		}
		
		private function loader_ioError(e:IOErrorEvent):void 
		{
			trace(url, e);
		}
		
		private function loader_complete(e:Event):void 
		{
			var bmd:BitmapData = (loader.content as Bitmap).bitmapData;
			mat.diffTexture = new TextureSet(bmd);
			mat.invalid = true;
		}
	}

}