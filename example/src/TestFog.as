package 
{
	import flash.display.Sprite;
	import flash.geom.Point;
	import gl3d.core.Material;
	import gl3d.core.View3D;
	import gl3d.parser.ColladaDecoder;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestFog extends Sprite
	{
		
		public function TestFog() 
		{
			var sceneColor:uint = 0;
			var fogColor:uint = 0xff;
			var mx:int = 200;
			var my:int = 200;
			var end:Number = 400;
			var start:Number = 100;
			for (var x:int = 0; x < 400;x++ ) {
				for (var y:int = 0; y < 400; y++ ) {
					var d:Number = Point.distance(new Point(mx, my), new Point(x, y)) / 800;
					var a:Number = Math.atan2(y - my, x - mx);
					a *= 10;
					var f:Number=d+(Math.sin(a)+1)/10;
					graphics.beginFill(f * fogColor);
					graphics.drawRect(x, y, 1, 1);
				}
			}
		}
		
	}

}