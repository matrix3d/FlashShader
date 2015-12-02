package 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import gl3d.util.Utils;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Test extends Sprite
	{
		
		public function Test() 
		{
			var bmd:BitmapData = new BitmapData(512, 512, true, 0);
			bmd.perlinNoise(10, 10, 10, 10, true, true);
			var bmd2:BitmapData = bmd.clone();
			addChild(new Bitmap(Utils.createNormalMap(bmd2)));
		}
		
	}

}