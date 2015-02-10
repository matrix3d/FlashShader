package gl3d.q3bsp.collision 
{
	/**
	 * ...
	 * @author lizhi
	 */
	public class Q3BSPCollisionType 
	{
        /// Collision test preformed with a 2D ray projecting from the start point.
        public static const Ray:int = 1;
        /// Collision test preformed with a sphere centered around the start point.
        public static const Sphere:int = 2;
        /// Collision test preformed with a box centered around the start point.
        public static const Box:int = 3;
		public function Q3BSPCollisionType() 
		{
			
		}
		
	}

}