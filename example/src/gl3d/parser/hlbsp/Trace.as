package gl3d.parser.hlbsp 
{
	/**
	 * ...
	 * @author lizhi
	 */
	public class Trace 
	{
		/**
		 * Structure containing trace related information used during the tracing process.
		 */
		/**  */
		public var allsolid:Boolean;
		
		/** The BspPlane the trace has collided with */
		public var plane:BspPlane;
		
		/** The ratio between 0.0 and 1.0 how far the trace from start to end was successful */
		public var ratio:Number;
		public function Trace() 
		{
			
		}
		
	}

}