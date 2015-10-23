package gl3d.parser.q3bsp 
{
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Q3BSPPlane 
	{
		public var normal:Vector3D;
		public var distance:Number;
		/**
		 * The planes lump stores a generic set of planes that are in turn referenced by nodes and brushsides.
		 * Note that planes are paired. The pair of planes with indices i and i ^ 1 are coincident planes with opposing normals.
		 */
		public function Q3BSPPlane() 
		{
			
		}
		
	}

}