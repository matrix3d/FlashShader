package gl3d.util 
{
	import flash.utils.ByteArray;
	/**
	 * 
	 * http://www.codersnotes.com/notes/wrangling-halfs/
	 * http://www.java-gaming.org/index.php?topic=36705.0
	 * http://stackoverflow.com/questions/5678432/decompressing-half-precision-floats-in-javascript
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
		
		public static function toHalfFloat2(v1:Number, v2:Number):Number{
			//return (toHalfFloat(v1) << 16) | toHalfFloat(v2);
			return (toHalfFloat(v1) * 0x10000) + toHalfFloat(v2);
		}
		
		public static function toHalfFloat(v:Number):int
		{
			if (v == 0) {
				return 0;
			}
			/*if (v > 0.0 && v < 5.96046e-8) {
				return 0x0001;
			}
			if (v < 0.0 && v > -5.96046e-8) {
				return 0x8001;
			}
			if (v > 65504.0) {
				return 0x7bff;  // max value supported by half float
			}
			if (v < -65504.0){
				return ( 0x7bff | 0x8000 );
			}*/
			if (v > 0.0 && v < 0.000030547380447387695) {
				return 0x0001;
			}
			if (v < 0.0 && v > -0.000030547380447387695) {
				return 0x8001;
			}
			var f:int = floatToIntBits(v);
			return ((( f>>16 ) & 0x8000 ) | (((( f & 0x7f800000 ) - 0x38000000 )>>13 ) & 0x7c00 ) | (( f>>13 ) & 0x03ff ));
		}
		public static function toFloat(half:int):Number
		{
			if (half == 0) return 0;
			return intBitsToFloat((( half & 0x8000 )<<16 ) | ((( half & 0x7c00 ) + 0x1C000 )<<13 ) | (( half & 0x03FF )<<13 ));
		}

		/**
		 * 
		 * @param	sign 符号
		 * @param	exponent 指数位宽
		 * @param	fractionshr10 尾数精度
		 * @return
		 */
		public static function halfToFloat(seshr5:Number,eshr5:Number, exponent:Number, fractionshr10:Number):Number{
			var v:Number = Math.pow(2, exponent - 15) * (1 + fractionshr10);
			var s:Number = seshr5 == eshr5?1:0;
			s -= .5;
			s *= 2;
			return v*s;
		}
		public static function toFloatAgal(half:int):Number{
			var halfshr10:Number = half / Math.pow(2,10);
			var fshr10:Number = frc(halfshr10);
			var se:Number = halfshr10 - fshr10;
			var seshr5:Number = se / Math.pow(2, 5);
			var eshr5:Number = frc(seshr5);
			var e:Number = eshr5 * Math.pow(2, 5);
			var v:Number = halfToFloat(seshr5, eshr5, e, fshr10);
			v = v * (half != 0?1:0);
			return v;
		}
		public static function frc(v:Number):Number{
			return v - int(v);
		}
		
		public static function half2float2(v:Number):Array{
			var half2shr16:Number = v/ 0x10000;
			var lowshr16:Number = frc(half2shr16);
			var highshr16:Number = half2shr16 - lowshr16;
			return [toFloat(highshr16),toFloat(lowshr16*0x10000)]
		}
		
		public static function half2float2Agal(v:Number):Array{
			b.position = 0;
			b.writeFloat(v);
			b.position = 0;
			var v2:Number = b.readFloat();
			v = v2;
			var half2shr16:Number = v/ 0x10000;
			var lowshr16:Number = frc(half2shr16);
			var highshr16:Number = half2shr16 - lowshr16;
			return [toFloatAgal(highshr16),toFloatAgal(lowshr16*0x10000)]
		}
	}

}