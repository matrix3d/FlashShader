package gl3d.q3bsp 
{
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Q3BSPVertex 
	{
		
		public var position:Vector3D;///	Vertex position.
		public var texcoord:Array;///	Vertex texture coordinates. 0 = surface, 1 = lightmap.
		public var normal:Vector3D;///	Vertex normal.
		public var color:uint;///	Vertex color. RGBA.
		/**
		 * The vertexes lump stores lists of vertices used to describe faces. 
		 */
		public function Q3BSPVertex() 
		{
			
		}
		
	}

}