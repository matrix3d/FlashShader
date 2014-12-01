package  
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import gl3d.ctrl.FirstPersonCtrl;
	import gl3d.hlbsp.Bsp;
	import gl3d.hlbsp.BspRender;
	import gl3d.hlbsp.BspRenderNode;
	import gl3d.hlbsp.Wad;
	/**
	 * ...
	 * @author lizhi
	 */
	[SWF(backgroundColor='0xffffff',width='400',height='250')]
	public class TestBsp extends BaseExample
	{
		private var bsp:BspRenderNode;
		public function TestBsp() 
		{
			
		}
		
		override public function initNode():void {
			
			[Embed(source = "assets/webgl.bsp", mimeType = "application/octet-stream")]var c:Class;
			[Embed(source = "assets/fy_iceworld.bsp", mimeType = "application/octet-stream")]var c:Class;
			//[Embed(source = "assets/de_dust2.bsp", mimeType = "application/octet-stream")]var c:Class;
			bsp = new BspRenderNode(new c as ByteArray, view);
			
			//[Embed(source = "assets/webgl.wad", mimeType = "application/octet-stream")]var tc:Class;
			[Embed(source = "assets/de_vegas.wad", mimeType = "application/octet-stream")]var tc:Class;
			var wad:Wad = new Wad;
			wad.open(new tc as ByteArray);
			bsp.bsp.loadedWads.push(wad);
			bsp.bsp.loadMissingTextures();
			
			view.scene.addChild(bsp);
			bsp.scaleX = bsp.scaleY = bsp.scaleZ = .1;
			bsp.rotationX = -Math.PI / 2;
			bsp.material = material;
			view.light.ambient = Vector.<Number>([.4,.4,.4,1]);
			speed = 3;
			view.camera.z = 0;
			view.light.x = view.light.y = view.light.z = 0;
			view.light.y = .1;
		}
		
		override public function initUI():void {
		}
		
		override public function enterFrame(e:Event):void
		{
			super.enterFrame(e);
		}
		
	}

}