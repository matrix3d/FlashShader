package gl3d.util 
{
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author lizhi
	 */
	public class HFloat 
	{
		private static var b:ByteArray = new ByteArray;
		public function HFloat() 
		{
			
		}
		
		public static function floatToIntBits(v:Number):int{
			b.position = 0;
			b.writeFloat(v);
			b.position = 0;
			return b.readInt();
		}
		public static function intBitsToFloat(v:int):Number{
			b.position = 0;
			b.writeInt(v);
			b.position = 0;
			return b.readFloat();
		}
		
		public static function toHalfFloat(v:Number):int
		{
			var f:int = floatToIntBits(v);

			return ((( f>>16 ) & 0x8000 ) | (((( f & 0x7f800000 ) - 0x38000000 )>>13 ) & 0x7c00 ) | (( f>>13 ) & 0x03ff ));
		}

		public static function toFloat(half:int):Number
		{
			return intBitsToFloat((( half & 0x8000 )<<16 ) | ((( half & 0x7c00 ) + 0x1C000 )<<13 ) | (( half & 0x03FF )<<13 ));
		}
		
	}

}