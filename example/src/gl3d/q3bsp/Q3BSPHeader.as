package gl3d.q3bsp 
{
	/**
	 * ...
	 * @author lizhi
	 */
	public class Q3BSPHeader 
	{
		///Magic number. Always "IBSP".
		public var magic:String;
		///Version number. 0x2e for the BSP files distributed with Quake 3.
		public var version:int;
		public function Q3BSPHeader() 
		{
			
		}
		
	}

}