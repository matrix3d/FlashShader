package 
{
	import com.bit101.utils.MinimalConfigurator;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Test extends Sprite
	{
		public function Test() 
		{
			var a:Point = new Point(Math.random() * 400, Math.random() * 400);
			var b:Point = new Point(Math.random() * 400, Math.random() * 400);
			var c:Point = new Point(Math.random() * 400, Math.random() * 400);
			var bmd:BitmapData = new BitmapData(400, 400, true, 0xffcccccc);
			for (var i:int = 0; i < 10000; i++ ){
				while (true){
					var r0:Number = Math.random();
					var r1:Number = Math.random()
					//r1 *= r1;
					//r1*=(1-r0);
					if ((1-r0)>=r1){
						break;
					}
				}
				var ab:Point = new Point(b.x - a.x, b.y - a.y);
				var ac:Point = new Point(c.x-a.x,c.y-a.y);
				var p0:Point = new Point(a.x + ac.x * r0, a.y + ac.y * r0);
				var p1:Point = new Point(p0.x+ab.x*r1,p0.y+ab.y*r1);
				bmd.setPixel32(p1.x, p1.y, (1-r0)>r1?0xff0000ff:0xffff00ff);
			}
			addChild(new Bitmap(bmd));
			
			var sp:Sprite = new Sprite;
			addChild(sp);
			sp.graphics.lineStyle(2);
			sp.graphics.moveTo(a.x, a.y);
			sp.graphics.lineTo(b.x, b.y);
			sp.graphics.lineTo(c.x, c.y);
			sp.graphics.lineTo(a.x, a.y);
		}
	}

}