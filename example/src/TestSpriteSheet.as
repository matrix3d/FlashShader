package 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.utils.ByteArray;
	import gl3d.core.Camera3D;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.core.TextureSet;
	import gl3d.meshs.Meshs;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestSpriteSheet extends BaseExample
	{
		private var c2d:Camera3D=new Camera3D;
		private var node:Node3D = new Node3D;
		private var quat:Node3D;
		private var obj:Object;
		private var p:Number = 0;
		private var loader:Loader;
		public function TestSpriteSheet() 
		{
			
		}
		override protected function stage_resize(e:Event = null):void 
		{
			super.stage_resize(e);
			c2d.perspective.orthoOffCenterLH( 0, stage.stageWidth, 0, stage.stageHeight, -1000, 1000);
		}
		override public function initNode():void 
		{
			[Embed(source = "assets/nanzhanLv1/idle.json", mimeType = "application/octet-stream")]var j1:Class;
			obj = JSON.parse(""+new j1);
			
			[Embed(source = "assets/nanzhanLv1/idle.wdp",mimeType = "application/octet-stream")]var b1:Class;
			var bmdb:ByteArray = (new b1) as ByteArray;
			loader = new Loader;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_complete);
			loader.loadBytes(bmdb);
			
			
		}
		
		private function loader_complete(e:Event):void 
		{
			var bmd:Object = (loader.content as Bitmap).bitmapData;
			
			[Embed(source = "assets/idle.dat", mimeType = "application/octet-stream")]var c:Class;
			var b:ByteArray = new c as ByteArray;
			b.inflate();
			//obj = b.readObject();
			//bmd=obj.info.tex
			
			quat = new Node3D;
			quat.material = new Material;
			quat.material.uvMuler = [.5, .5];
			quat.material.uvAdder = [.5, .5];
			quat.material.materialCamera = c2d;
			quat.material.lightAble = false;
			quat.material.castShadow = false;
			view.scene.addChild(node);
			node.addChild(quat);
			
			quat.material.diffTexture = new TextureSet(bmd, false, false, false,true,null);
			quat.material.blendModel = BlendMode.LAYER;
			//var size:int = quat.material.diffTexture.width/2;
			var r:Number = 1;
			var vs:Vector.<Number> = Vector.<Number>([0, 0, 0, r, 0, 0, 0, r, 0, r, r, 0]);
			var uv:Vector.<Number> = Vector.<Number>([0, 1, 1, 1, 0, 0, 1, 0]);
			var ins:Vector.<uint>=Vector.<uint>([0, 1, 2, 1, 3, 2]);
			quat.drawable = Meshs.createDrawable(ins, vs, uv);
			//quat.x = size + 0 * ((size*2)+1);
			//quat.y = -size;
			node.x = stage.stageWidth / 2;
			node.y = stage.stageHeight / 2;
		}
		
		override public function enterFrame(e:Event):void 
		{
			if(quat){
				if (int(p)>=(obj.ts.length)){
					p = 0;
				}
				var t:Object = obj.ts[int(p)];
				p += .1;
				quat.scaleX = t.w;
				quat.scaleY = t.h;
				quat.material.uvMuler[0] = t.w / obj.info.w;
				quat.material.uvMuler[1] = t.h / obj.info.h;
				quat.material.uvAdder[0] = t.x / obj.info.w;
				quat.material.uvAdder[1] = t.y / obj.info.h;
				quat.x = t.fx;
				quat.y = -t.h -t.fy;
			}
			super.enterFrame(e);
		}
		
	}

}