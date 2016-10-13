package 
{
	import flash.events.Event;
	import flash.utils.ByteArray;
	import gl3d.core.Drawable;
	import gl3d.core.InstanceMaterial;
	import gl3d.core.Node3D;
	import gl3d.meshs.Meshs;
	import gl3d.parser.dae.ColladaDecoder;
	import gl3d.parser.dae.ColladaParser;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Test2D extends BaseExample
	{
		private var cube:Node3D;
		private var map2d:Node3D = new Node3D;
		private var rx:Number = 45;
		private var clone:Node3D;
		public function Test2D() 
		{
			
		}
		
		override public function initNode():void 
		{
			view.scene.addChild(map2d);
			var cubed:Drawable = Meshs.cube(100,100,100);
			var c:int = 10;
			view.antiAlias = 16;
			cube = new Node3D;
			cube.material = material;
			map2d.addChild(cube);
			cube.drawable = cubed;
			while (c-->0) {
				clone = cube.clone();
				clone.material = new InstanceMaterial;
				clone.x = (Math.random()-.5)*400;
				clone.y = (Math.random() - .5) * 400;
				map2d.addChild(clone);
			}
			map2d.setRotation(rx, 0, 0);
			view.camera.z = -10000;
			
			[Embed(source = "assets/astroBoy_walk_Max.dae", mimeType = "application/octet-stream")]var testdae:Class;
			var b:ByteArray = new testdae as ByteArray;
			var p:ColladaDecoder = new ColladaDecoder(b+"");
			p.scenes[0].setRotation(-90,0,0);
			p.scenes[0].scaleX = p.scenes[0].scaleY = p.scenes[0].scaleZ = 30;
			map2d.addChild(p.scenes[0]);
			
			c = 20;
			while (c-->0) {
				clone = p.scenes[0].clone();
				clone.x = (Math.random()-.5)*400;
				clone.y = (Math.random() - .5) * 400;
				map2d.addChild(clone);
			}
		}
		
		override public function initCtrl():void 
		{
			//super.initCtrl();
		}
		
		
		override public function enterFrame(e:Event):void 
		{
			clone.x = mouseX - stage.stageWidth / 2;
			clone.y =  (stage.stageHeight / 2 - mouseY) / Math.cos(Math.PI / 180 * rx);
			super.enterFrame(e);
		}
		
		override protected function stage_resize(e:Event = null):void 
		{
			super.stage_resize(e);
			view.camera.orthoLH(stage.stageWidth, stage.stageHeight, 0, 400000);
		}
	}

}