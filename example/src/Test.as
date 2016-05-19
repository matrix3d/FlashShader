package 
{
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Proxy;
	import flash.utils.getTimer;
	import gl3d.core.Light;
	import gl3d.core.Material;
	import gl3d.core.View3D;
	import gl3d.core.shaders.GLAS3Shader;
	import gl3d.shaders.PhongGLShader;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Test extends Sprite
	{
		private var loader:Loader;
		public function Test() 
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			[Embed(source = "tex.bin", mimeType = "application/octet-stream")]var c:Class;
			var b:ByteArray = new c as ByteArray;
			loader = new Loader;
			addChild(loader);
			loader.loadBytes(b);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_complete);
			stage.addEventListener(MouseEvent.CLICK, stage_click);
		}
		
		private function loader_complete(e:Event):void 
		{
			trace(1);
			graphics.lineStyle(10);
			graphics.drawRect(0, 0, loader.content.width, loader.content.height);
		}
		
		private function stage_click(e:MouseEvent):void 
		{
			var t:int = getTimer();
			var pg:PhongGLShader= new PhongGLShader();
			var m:Material = new Material(pg);
			m.view = new View3D;
			//m.view.lights.push(new Light);
			var vs:GLAS3Shader=pg.vs = pg.getVertexShader(m);
			var fs:GLAS3Shader = pg.getFragmentShader(m);
			vs.code;
			fs.code;
			trace(getTimer() - t);
			
		}
	}

}
import flash.utils.Proxy;
import flash.utils.flash_proxy;

dynamic class MyVar extends Proxy{
	override flash_proxy function getProperty(name:*):* 
	{
		trace(1);
		return null;
	}
	
	public function ddd():void{
		
	}
}