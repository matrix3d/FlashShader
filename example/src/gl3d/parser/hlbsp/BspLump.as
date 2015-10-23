package gl3d.parser.hlbsp 
{
	/**
	 * ...
	 * @author lizhi
	 */
	// Describes a lump in the BSP file
/*
typedef struct _BSPLUMP
{
	int32_t nOffset;
	int32_t nLength;
} BSPLUMP;
*/
	public class BspLump 
	{
		public var offset:int; // File offset to data
		public var length:int; // Length of data
		public function BspLump() 
		{
			
		}
		
	}

}