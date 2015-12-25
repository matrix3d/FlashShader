package 
{
	import com.bit101.components.CheckBox;
	import com.bit101.components.ComboBox;
	import com.bit101.components.HUISlider;
	import com.bit101.components.PushButton;
	import com.bit101.components.VBox;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Matrix3D;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.System;
	import flash.utils.ByteArray;
	import flash.utils.CompressionAlgorithm;
	import flash.utils.Dictionary;
	import gl3d.core.Node3D;
	import gl3d.core.skin.SkinAnimation;
	import gl3d.core.View3D;
	import gl3d.parser.dae.ColladaDecoder;
	import gl3d.parser.fbx.FbxParser;
	import gl3d.parser.md5.MD5AnimParser;
	import gl3d.parser.md5.MD5MeshParser;
	import gl3d.parser.mmd.MMD;
	import gl3d.parser.mmd.VMD;
	import gl3d.parser.obj.OBJParser;
	import gl3d.parser.object.ObjectDecoder;
	import gl3d.parser.object.ObjectEncoder;
	import gl3d.util.Utils;
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
		private var scaleUI:HUISlider;
		private var timeUI:HUISlider;
		private var pauseUI:CheckBox;
		private var anim:SkinAnimation;
		private var mtl:String;
		private var rotUI:HUISlider;
		private var fmtUI:ComboBox;
		public function ModelViewer() 
		{
		}
		
		override public function initNode():void 
		{
			addSky();
			for each(var v:String in loaderInfo.parameters) {
				load(v);
			}
			for each(v in Utils.getParameters()) {
				load(v);
			}
			//load("C:/Users/aaaa/Desktop/test2.fbx");
			//load("C:/Users/aaaa/Desktop/mesh.amf");
			//load("C:/Users/aaaa/Desktop/mesh.json");
			//load("C:/Users/aaaa/Desktop/aoying gongji.FBX");
			//load("C:/Users/aaaa/Desktop/Beta.fbx");
			//load("C:/Users/aaaa/Desktop/Betau3d.fbx");
			//load("C:/Users/aaaa/Desktop/Beta@running.fbx");
			//load("C:/Users/aaaa/Desktop/runningmax.fbx");
			//load("C:/Users/aaaa/Desktop/running.fbx");
			//load("../src/assets/test4.FBX");
			//load("../src/assets/miku.mtl");
			//load("../src/assets/miku.obj");
			//load("../src/assets/astroBoy_walk_Max.dae");
			//load("../src/assets/miku.pmx");
			//load("../src/assets/melt.vmd");
		}
		
		private function load(v:String):void {
			var loader:URLLoader = new URLLoader;
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE, loader_complete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, loader_ioError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loader_securityError);
			loader2url[loader] = v;
			loader.load(new URLRequest(v));
		}
		
		private function loader_securityError(e:SecurityErrorEvent):void 
		{
			
		}
		
		private function loader_ioError(e:IOErrorEvent):void 
		{
			
		}
		
		private function loader_complete(e:Event):void 
		{
			var loader:URLLoader = e.currentTarget as URLLoader;
			tryAdd(loader2url[loader], loader.data as ByteArray);
			
			//view.enableErrorChecking = true;
		}
		
		override public function initUI():void 
		{
			var vbox:VBox = new VBox(this, 5, 5);
			var btn:PushButton = new PushButton(vbox,0,0,"browse");
			btn.addEventListener(MouseEvent.CLICK, btn_click);
			scaleUI = new HUISlider(vbox, 0, 0, "scale", onScale);
			scaleUI.setSliderParams(0.01, 10, 0);
			pauseUI = new CheckBox(vbox, 0, 0, "pause", onPause);
			timeUI = new HUISlider(vbox, 0, 0, "time", onTime);
			timeUI.setSliderParams(0, 1, 0);
			rotUI = new HUISlider(vbox, 0, 0, "rotY", onRot);
			rotUI.setSliderParams(0, 360,0);
			rotUI.tick = 1;
			var formats:Array = ["json","amf"];
			fmtUI = new ComboBox(vbox, 0, 0, formats[0], formats);
			fmtUI.selectedIndex = 0;
			new PushButton(vbox, 0, 0, "export", onExp);
			
			addChild(stats);
			stats.y = vbox.y + vbox.height + 5;
		}
		
		private function onExp(e:Event):void 
		{
			if (node) {
				var io:ObjectEncoder = new ObjectEncoder;
				var bak:Matrix3D = node.matrix;
				node.matrix = new Matrix3D;
				var obj:Object = io.exportNode(node);
				node.matrix = bak;
				var out:Object;
				switch(fmtUI.selectedItem) {
					case "json":
						out = JSON.stringify(obj);
						break;
					case "amf":
						var byte:ByteArray = new ByteArray;
						byte.writeObject(obj);
						byte.compress(CompressionAlgorithm.LZMA);
						out = byte;
						break;
				}
				if (out) {
					var file:FileReference = new FileReference;
					file.save(out, "mesh." + fmtUI.selectedItem);
				}
			}
		}
		
		private function onPause(e:Event):void 
		{
			if (anim) {
				anim.playing = !pauseUI.selected;
			}
		}
		
		private function onScale(e:Event):void 
		{
			if (node) {
				node.scaleX=
				node.scaleY=
				node.scaleZ = scaleUI.value;
			}
		}
		private function onRot(e:Event):void 
		{
			if (node) {
				node.rotationY = rotUI.value;
			}
		}
		private function onTime(e:Event):void 
		{
			if (anim) {
				anim.time = anim.maxTime * timeUI.value*1000;
			}
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
			anim = null;
			switch(type) {
				case "pmx":
					mmd = new MMD(byte );
					var curnode:Node3D = mmd.node;
					defScale = .1;
					if (vmd) {
						anim = mmd.bind(vmd);
					}
					break;
				case "vmd":
					vmd = new VMD(byte);
					if(mmd)
					anim = mmd.bind(vmd);
					break;
				case "obj":
					var obj:OBJParser = new OBJParser(byte +"",true,mtl);
					curnode = obj.target;
					break;
				case "mtl":
					mtl = byte+"";
					break;
				case "md5mesh":
					md5mesh = new MD5MeshParser(byte+"");
					curnode = md5mesh.target;
					break;
				case "md5anim":
					if (md5mesh) {
						var md5a:MD5AnimParser = new MD5AnimParser(byte+"", md5mesh);
						anim = md5a.anim;
					}
					break;
				case "dae":
				case "collada":
					var dae:ColladaDecoder = new ColladaDecoder(byte+"");
					curnode = dae.scenes[0];
					anim = dae.anim;
					break;
				case "fbx":
					var fbx:FbxParser = new FbxParser(byte);
					anim = fbx.anim3d;
					curnode = fbx.rootNode;
					defScale = 0.01;
					break;
				case "json":
					var object:Object = JSON.parse(byte+"");
					break;
				case "amf":
					byte.uncompress(CompressionAlgorithm.LZMA);
					object = byte.readObject();
					break;
			}
			if (object) {
				var objectd:ObjectDecoder = new ObjectDecoder(object);
				curnode = objectd.target;
			}
			if (curnode) {
				scaleUI.value = defScale;
				if (lastNode&&lastNode.parent) {
					lastNode.parent.removeChild(lastNode);
				}
				node = curnode;
				node.scaleX=
				node.scaleY=
				node.scaleZ = defScale;
				view.scene.addChild(node);
			}
		}
		
	}

}