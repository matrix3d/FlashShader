package gl3d.util 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import gl3d.core.Material;
	import gl3d.core.MaterialBase;
	import gl3d.core.TextureSet;
	import gl3d.core.shaders.GLShader;
	import gl3d.shaders.PhongFragmentShader;
	import gl3d.shaders.PhongVertexShader;
	/**
	 * ...
	 * @author lizhi
	 */
	public class MatLoadMsg extends EventDispatcher
	{
		public static var baseurl:String = "";
		private static var fullurl2mat:Object = {};
		private var mat:MaterialBase;
		private var diff:TextureSet;
		private var loader:Loader;
		private var url:String;
		private var sourceURL:String;
		public function MatLoadMsg(url:String,byte:ByteArray,mat:MaterialBase) 
		{
			sourceURL = url;
			var url = url.substring(url.lastIndexOf("\\") + 1);
			url=url.substring(url.lastIndexOf("/") + 1);
			if (url.toLocaleLowerCase().indexOf(".jpg")==-1){
				url = url.substring(0, url.lastIndexOf(".")) + ".png";
			}
			this.url = url;
			trace(url);
			this.mat = mat;
			
			mat.diffTexture = new SharedTextureSet();
			mat.diffTexture.name = sourceURL;
			
			var fullurl:String = baseurl + url;
			var smat:MatLoadMsg = fullurl2mat[fullurl];
			if (smat){
				if (smat.diff){
					mat.diffTexture = smat.diff;
				}else{
					smat.addEventListener(Event.COMPLETE, smat_complete);
					smat.addEventListener(IOErrorEvent.IO_ERROR, smat_ioError);
				}
			}else{
				fullurl2mat[fullurl] = this;
				loader = new Loader;
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_complete);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loader_ioError);
				addEventListener(IOErrorEvent.IO_ERROR, ioError);
				if(byte){
					loader.loadBytes(byte);
				}else{
					loader.load(new URLRequest(fullurl));
				}
			}
			
		}
		
		private function ioError(e:IOErrorEvent):void 
		{
			
		}
		
		private function smat_ioError(e:IOErrorEvent):void 
		{
			
		}
		
		private function smat_complete(e:Event):void 
		{
			mat.diffTexture = (e.currentTarget as MatLoadMsg).diff;
		}
		
		private function loader_ioError(e:IOErrorEvent):void 
		{
			trace(url, e);
			dispatchEvent(e);
		}
		
		private function loader_complete(e:Event):void 
		{
			var bmd:BitmapData = (loader.content as Bitmap).bitmapData;
			if (mat){
				diff=new TextureSet(bmd);
				mat.diffTexture = diff;
				mat.diffTexture.name = sourceURL;
				(mat as Material).shader=new GLShader(new PhongVertexShader,new PhongFragmentShader)
				mat.invalid = true;
			}
			dispatchEvent(e);
		}
	}

}
import flash.display.BitmapData;
import gl3d.core.TextureSet;
import gl3d.core.View3D;
import gl3d.core.renders.GL;

class SharedTextureSet extends TextureSet{
	private static var bmd:BitmapData = new BitmapData(128, 128); {
		bmd.perlinNoise(100, 100, 3, 1, true, true);
	}
	private static var sharedTextureSet:TextureSet=new TextureSet(bmd);
	public function SharedTextureSet() 
	{
		super();
	}
	
	override public function update(view:View3D):void {
			sharedTextureSet.update(view);
		}
		
	override	public function bind(context:GL, i:int):void {
			sharedTextureSet.bind(context, i);
		}
		
	override	public function get flags():Array {
			return sharedTextureSet.flags;
		}
}