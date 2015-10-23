package gl3d.parser.q3bsp 
{
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Q3BSPLeaf 
	{
		public var cluster:int///	Visdata cluster index.
		public var area:int///	Areaportal area.
		public var mins:Vector3D///	Integer bounding box min coord.
		public var maxs:Vector3D///	Integer bounding box max coord.
		public var leafface:int///	First leafface for leaf.
		public var n_leaffaces:int///	Number of leaffaces for leaf.
		public var leafbrush:int///	First leafbrush for leaf.
		public var n_leafbrushes:int///	Number of leafbrushes for leaf.
		
		/**
		 * The leafs lump stores the leaves of the map's BSP tree. Each leaf is a convex region that contains, among other things, a cluster index (for determining the other leafs potentially visible from within the leaf), a list of faces (for rendering), and a list of brushes (for collision detection). 
		 * If cluster is negative, the leaf is outside the map or otherwise invalid.
		 */
		public function Q3BSPLeaf() 
		{
			
		}
		
	}

}