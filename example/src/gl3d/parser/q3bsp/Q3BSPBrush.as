package gl3d.parser.q3bsp 
{
	/**
	 * ...
	 * @author lizhi
	 */
	public class Q3BSPBrush 
	{
		public var brushside:int;///First brushside for brush.
		public var n_brushsides:int;///	Number of brushsides for brush.
		public var texture:int;///Texture index.
		
		/**
		 * The brushes lump stores a set of brushes, 
		 * which are in turn used for collision detection. 
		 * Each brush describes a convex volume as defined by its surrounding surfaces. 
		 * There are a total of length / sizeof(brushes) records in the lump, 
		 * where length is the size of the lump itself, 
		 * as specified in the lump directory.
		 */
		public function Q3BSPBrush() 
		{
			
		}
		
	}

}