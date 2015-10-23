package gl3d.parser.q3bsp 
{
	/**
	 * ...
	 * @author lizhi
	 */
	public class Q3BSPEffect 
	{
		
		public var name:String/// string[64] name	Effect shader.
		public var brush:int;///	Brush that generated this effect.
		public var unknown:int;///	Always 5, except in q3dm8, which has one effect with -1.
		/**
		 * The effects lump stores references to volumetric shaders (typically fog) which affect the rendering of a particular group of faces. 
		 */
		public function Q3BSPEffect() 
		{
			
		}
		
	}

}