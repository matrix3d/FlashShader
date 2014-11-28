package gl3d.hlbsp 
{
	/**
	 * ...
	 * @author lizhi
	 */
	// Describes a node of the BSP Tree
/*
typedef struct _BSPNODE
{
	uint32_t iPlane;			 
	int16_t  iChildren[2];		 
	int16_t  nMins[3], nMaxs[3]; 
	uint16_t iFirstFace, nFaces;  
} BSPNODE;
*/
	public class BspNode 
	{
	public	 var plane:int;     // Index into pPlanes lump
    public var children:Array;  // If > 0, then indices into Nodes otherwise bitwise inverse indices into Leafs
	public var mins:Array;      // Bounding box
	public var maxs:Array;
	public var firstFace:int; // Index and count into BSPFACES array
	public var faces:int;
		public function BspNode() 
		{
			
		}
		
	}

}