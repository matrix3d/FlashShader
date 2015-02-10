package gl3d.q3bsp.collision 
{
	import parser.Q3BSP.Q3BSPPlane;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Q3Trace 
	{
		public var startsOut:Boolean = true;
		public var allSolid:Boolean = false;
		public var plane:Q3BSPPlane;
		public var fraction:Number= 1
		public function Q3Trace() 
		{
			
		}
		
	}

}