package gl3d.parser.q3bsp 
{
	/**
	 * ...
	 * @author lizhi
	 */
	public class Q3BSPBrushside 
	{
		
		public var plane:int;///	Plane index.
		public var texture:int;///	Texture index.
		
		/**
		 * The brushsides lump stores descriptions of brush bounding surfaces. 
		 * There are a total of length / sizeof(brushsides) records in the lump, 
		 * where length is the size of the lump itself, as specified in the lump directory.
		 */
		public function Q3BSPBrushside() 
		{
			
		}
		
	}

}