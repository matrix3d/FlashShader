package gl3d.util 
{
	/**
	 * ...
	 * @author lizhi
	 */
	public class MathUtil 
	{
		
		public function MathUtil() 
		{
			
		}
		
		public static function getNextPow2(v:int):int {
			var r:int = 1;
			while (r < v) {
				r *= 2;
			}
			return r;
		}
	}

}