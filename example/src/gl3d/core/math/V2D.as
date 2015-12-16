package gl3d.core.math {
	import flash.geom.Point;
	/**
	 * ...
	 * @author lizhi
	 */
	public class V2D 
	{
		public var x:Number = 0;
		public var y:Number = 0;
		public function V2D(x:Number,y:Number) 
		{
			setTo(x, y);
		}
		
		public function setTo(x:Number, y:Number):void {
			this.x = x;
			this.y = y;
		}
		
		public function clone():V2D {
			return new V2D(x, y);
		}
		
		public function rot(value:Number):void {
			var sin:Number = Math.sin(value);
			var cos:Number = Math.cos(value);
			var x_:Number = x;
			x = x * cos - y * sin ;
			y = x_ * sin + y * cos;
		}
		
		public function rot2(value:Number, op:Point):void {
			x -= op.x;
			y -= op.y;
			rot(value);
			x += op.x;
			y += op.y;
		}
		
	}

}