package flash3d {
	/**
	 * ...
	 * @author lizhi
	 */
	public class V3D 
	{
		public var x:Number = 0;
		public var y:Number = 0;
		public var z:Number = 0;
		public var w:Number = 1;
		public function V3D(x:Number=0,y:Number=0,z:Number=0) 
		{
			setTo(x, y,z);
		}
		
		public function setTo(x:Number, y:Number,z:Number):V3D {
			this.x = x;
			this.y = y;
			this.z = z;
			return this;
		}
		
		public function clone():V3D {
			return new V3D(x, y,z);
		}
		
		public function get length():Number {
			return Math.sqrt(x * x + y * y + z * z);
		}
		
		public function nrm():V3D {
			var a:Number = length;
			x /= a;
			y /= a;
			z /= a;
			return this;
		}
		
		public function rot(v0:Number,v1:Number,v2:Number):V3D {
			var _y:Number = y * Math.cos(v0) -z * Math.sin(v0);
			var _z:Number = z * Math.cos(v0) + y * Math.sin(v0);
			var _x:Number = x * Math.cos(v1) - _z * Math.sin(v1);
			z = _z * Math.cos(v1) + x * Math.sin(v1);
			x = _x * Math.cos(v2) - _y * Math.sin(v2);  
			y = _y * Math.cos(v2) + _x * Math.sin(v2);
			return this;
		}
		
	}

}