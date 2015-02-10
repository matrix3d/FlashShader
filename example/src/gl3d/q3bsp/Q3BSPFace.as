package gl3d.q3bsp 
{
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Q3BSPFace 
	{
		
		public var texture:int	///Texture index.
		public var effect:int	///Index into lump 12 (Effects), or -1.
		public var type:int	///Face type. 1=polygon, 2=patch, 3=mesh, 4=billboard
		public var vertex:int	///Index of first vertex.
		public var n_vertexes:int	///Number of vertices.
		public var meshvert:int	///Index of first meshvert.
		public var n_meshverts:int	///Number of meshverts.
		public var lm_index:int	///Lightmap index.
		public var lm_start:Vector3D	///Corner of this face's lightmap image in lightmap.
		public var lm_size:Vector3D	///Size of this face's lightmap image in lightmap.
		public var lm_origin:Vector3D	///World space origin of lightmap.
		public var lm_vecs:Array	///World space lightmap s and t unit vectors.
		public var normal:Vector3D///	Surface normal.
		public var size:Vector3D///	Patch dimensions.

		/**
		 * The faces lump stores information used to render the surfaces of the map.
		 */
		public function Q3BSPFace() 
		{
			
		}
		
	}

}