package gl3d.parser.q3bsp 
{
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Q3BSPModel 
	{
		
		public var mins:Vector3D;///	Bounding box min coord.
		public var maxs:Vector3D///	Bounding box max coord.
		public var face:int;///	First face for model.
		public var n_faces:int;///	Number of faces for model.
		public var brush:int;///	First brush for model.
		public var n_brushes:int;///	Number of brushes for model.
		/**
		 * The models lump describes rigid groups of world geometry. The first model correponds to the base portion of the map while the remaining models correspond to movable portions of the map, such as the map's doors, platforms, and buttons. Each model has a list of faces and list of brushes; these are especially important for the movable parts of the map, which (unlike the base portion of the map) do not have BSP trees associated with them. 
		 */
		public function Q3BSPModel() 
		{
			
		}
		
	}

}