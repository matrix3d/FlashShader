package gl3d.parser.q3bsp 
{
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Q3BSPNode 
	{
		public var plane:int;///	Plane index.
		public var children:Array;///	Children indices. Negative numbers are leaf indices: -(leaf+1).
		public var min:Vector3D;///Integer bounding box min coord.
		public var max:Vector3D;///Integer bounding box max coord.
		/**
		 * The nodes lump stores all of the nodes in the map's BSP tree. The BSP tree is used primarily as a spatial subdivision scheme, dividing the world into convex regions called leafs. The first node in the lump is the tree's root node.
		 */
		public function Q3BSPNode() 
		{
			
		}
		
	}

}