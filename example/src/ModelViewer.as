package 
{
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import gl3d.core.Node3D;
	import gl3d.core.View3D;
	import gl3d.parser.dae.ColladaDecoder;
	import gl3d.parser.fbx.FbxParser;
	import gl3d.parser.md5.MD5AnimParser;
	import gl3d.parser.md5.MD5MeshParser;
	import gl3d.parser.mmd.MMD;
	import gl3d.parser.mmd.VMD;
	import gl3d.parser.obj.OBJParser;
	import gl3d.util.Utils;
	import ui.Button;
	/**
	 * ...
	 * @author lizhi
	 */
	public class ModelViewer extends BaseExample
	{
		private var file:FileReference;
		private var mmd:MMD;
		private var vmd:VMD;
		private var loader2url:Dictionary = new Dictionary;
		private var md5mesh:MD5MeshParser;
		private var node:Node3D;
		public function ModelViewer() 
		{
		}
		
		override public function initNode():void 
		{
			addSky();
			for each(var v:String in loaderInfo.parameters) {
				load(v);
			}
			//load("C:/Users/aaaa/Desktop/woman22.FBX");
			//load("../src/assets/test4.FBX");
		}
		
		private function load(v:String):void {
			var loader:URLLoader = new URLLoader;
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE, loader_complete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, loader_ioError);
			loader2url[loader] = v;
			loader.load(new URLRequest(v));
		}
		
		private function loader_ioError(e:IOErrorEvent):void 
		{
			
		}
		
		private function loader_complete(e:Event):void 
		{
			var loader:URLLoader = e.currentTarget as URLLoader;
			tryAdd(loader2url[loader], loader.data as ByteArray);
		}
		
		override public function initUI():void 
		{
			var btn:Button = new Button("browse");
			btn.x = btn.y = 5;
			addChild(btn);
			btn.addEventListener(MouseEvent.CLICK, btn_click);
		}
		
		private function btn_click(e:MouseEvent):void 
		{
			file = new FileReference;
			file.addEventListener(Event.SELECT, file_select);
			file.browse();
		}
		
		private function file_select(e:Event):void 
		{
			file.addEventListener(Event.COMPLETE, file_complete);
			file.load();
		}
		
		private function file_complete(e:Event):void 
		{
			tryAdd(file.name, file.data);
		}
		
		private function tryAdd(url:String, byte:ByteArray):void {
			var type:String = url.substr(url.lastIndexOf(".") + 1).toLowerCase();
			var defScale:Number = 1;
			var lastNode:Node3D = node;
			switch(type) {
				case "pmx":
					mmd = new MMD(byte );
					node = mmd.node;
					defScale = .1;
					if (vmd) {
						mmd.bind(vmd);
					}
					break;
				case "vmd":
					vmd = new VMD(byte);
					if(mmd)
					mmd.bind(vmd);
					break;
				case "obj":
					var obj:OBJParser = new OBJParser(byte +"", false);
					node = obj.target;
					break;
				case "md5mesh":
					md5mesh = new MD5MeshParser(byte+"");
					node = md5mesh.target;
					break;
				case "md5anim":
					if (md5mesh) {
						new MD5AnimParser(byte+"",md5mesh);
					}
					break;
				case "dae":
				case "collada":
					var dae:ColladaDecoder = new ColladaDecoder(byte+"");
					node = dae.scenes[0];
					break;
				case "fbx":
					var fbx:FbxParser = new FbxParser(byte);
					node = fbx.rootNode;
					defScale = 0.01;
					break;
			}
			if (node) {
				if (lastNode&&lastNode.parent) {
					lastNode.parent.removeChild(lastNode);
				}
				node.scaleX=
				node.scaleY=
				node.scaleZ = defScale;
				view.scene.addChild(node);
			}
			
			//Utils.traceNode(node);
		}
		
	}

}