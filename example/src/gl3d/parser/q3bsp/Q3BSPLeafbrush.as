package gl3d.parser.q3bsp 
{
	/**
	 * ...
	 * @author lizhi
	 */
	public class Q3BSPLeafbrush 
	{
		
		
		public var brush:int///	Brush index.
		/**
		 * The leafbrushes lump stores lists of brush indices, with one list per leaf. There are a total of length / sizeof(leafbrush) records in the lump, where length is the size of the lump itself, as specified in the lump directory.
		 */
		public function Q3BSPLeafbrush() 
		{
			
		}
		
	}

}