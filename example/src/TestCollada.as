package 
{
	import flash.display.Sprite;
	import gl3d.core.Node3D;
	import gl3d.parser.ColladaDecoder;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestCollada extends BaseExample
	{
		
		public function TestCollada() 
		{
		}
		
		
		override public function initNode():void 
		{
			addSky();
			[Embed(source = "assets/astroBoy_walk_Max.dae", mimeType = "application/octet-stream")]
			//[Embed(source = "assets/aoyingfbx2dae.DAE", mimeType = "application/octet-stream")]
			//[Embed(source = "assets/yurenfbx2dae.DAE", mimeType = "application/octet-stream")]
			//[Embed(source = "assets/yuren.dae", mimeType = "application/octet-stream")]
			//[Embed(source = "assets/test4.dae", mimeType = "application/octet-stream")]
			//[Embed(source = "assets/untitled.dae", mimeType = "application/octet-stream")]
			//[Embed(source = "assets/duck.dae", mimeType = "application/octet-stream")]
			var c:Class;
			var decoder:ColladaDecoder = new ColladaDecoder(new c + "");
			decoder.scenes[0].scaleX=
			decoder.scenes[0].scaleY=
			decoder.scenes[0].scaleZ = 1 / 3;
			view.scene.addChild(decoder.scenes[0]);
			//decoder.scenes[0].rotationX = -90;
			//decoder.scenes[0].rotationY = 180;
		}
	}

}