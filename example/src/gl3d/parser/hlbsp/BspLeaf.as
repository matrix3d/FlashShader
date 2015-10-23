package gl3d.parser.hlbsp 
{
	/**
	 * ...
	 * @author lizhi
	 */
	public class BspLeaf 
	{
		// Leafs lump contains leaf structures
/*
typedef struct _BSPLEAF
{
	int32_t  nContents;			              
	int32_t  nVisOffset;		              
	int16_t  nMins[3], nMaxs[3];             
	uint16_t iFirstMarkSurface, nMarkSurfaces;
	uint8_t  nAmbientLevels[4];	        
} BSPLEAF;
*/
   public var content:int;          // Contents enumeration, see vars
   public  var visOffset:int;        // Offset into the compressed visibility lump
	public var mins:Array;             // Bounding box
	public var maxs:Array;
	public var firstMarkSurface:int; // Index and count into BSPMARKSURFACE array
	public var markSurfaces:int
	public var ambientLevels:Array;    // Ambient sound levels     
		public function BspLeaf() 
		{
			
		}
		
	}

}