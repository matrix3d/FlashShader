package gl3d.parser.q3bsp 
{
	/**
	 * ...
	 * @author lizhi
	 */
	public class Q3BSPVisdata 
	{
		public var n_vecs:int;///	Number of vectors.
		public var sz_vecs:int;///	Size of each vector, in bytes.
		//public var ubyte[n_vecs * sz_vecs] vecs	Visibility data. One bit per cluster per vector.
		
		/**
		 * The visdata lump stores bit vectors that provide cluster-to-cluster visibility information.
		 * Cluster x is visible from cluster y if the (1 << y % 8) bit of vecs[x * sz_vecs + y / 8] is set.
		 *
		 *	Note that clusters are associated with leaves.
		 */
		public function Q3BSPVisdata() 
		{
			
		}
		
	}

}