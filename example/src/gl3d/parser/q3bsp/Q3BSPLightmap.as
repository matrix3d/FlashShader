package gl3d.parser.q3bsp 
{
	/**
	 * ...
	 * @author lizhi
	 */
	public class Q3BSPLightmap 
	{
		
		///ubyte[128][128][3] map	Lightmap color data. RGB.
		/**
		 * The lightmaps lump stores the light map textures used make surface lighting look more realistic.
		 */
		public var x:Number=0;
		public var y:Number=0;
		public var xScale:Number=0;
		public var yScale:Number=0;
		public function Q3BSPLightmap() 
		{
			
		}
		
	}

}