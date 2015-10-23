package gl3d.parser.hlbsp 
{
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class BspModel 
	{
		// Smaller bsp models inside the world. Mostly brush entities.
/*
typedef struct _BSPMODEL
{
    float    nMins[3], nMaxs[3];    
    VECTOR3D vOrigin;                  
    int32_t  iHeadNodes[MAX_MAP_HULLS];
    int32_t  nVisLeafs;                 
    int32_t  iFirstFace, nFaces;        
};
*/
	public var mins:Array;      // Defines bounding box
	public var maxs:Array; 
	public var origin:Vector3D;    // Coordinates to move the coordinate system before drawing the model
	public var headNodes:Array; // Indexes into nodes (first into world nodes, remaining into clip nodes)
	public var visLeafs:int;  // No idea
	public var firstFace:int; // Index and count into face array
	public var faces:int;
		public function BspModel() 
		{
			
		}
		
	}

}