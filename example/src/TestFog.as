package 
{
	import flash.display.Sprite;
	import flash.geom.Point;
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
					var d:Number = Point.distance(new Point(mx, my), new Point(x, y));
					var f:Number = (end - d) / (end - start)
					if (f > 1) f = 1;
					if (f < 0) f = 0;
					//var f:Number=1/Math.exp(d*0.01);
					graphics.beginFill(f * sceneColor + (1 - f) * fogColor);
					graphics.drawRect(x, y, 1, 1);
				}
			}
		}
		
	}

}