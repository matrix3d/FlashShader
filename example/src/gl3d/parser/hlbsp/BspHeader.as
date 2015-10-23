package gl3d.parser.hlbsp 
{
	/**
	 * ...
	 * @author lizhi
	 */
	// The BSP file header
/*
typedef struct _BSPHEADER
{
	int32_t nVersion;		
	BSPLUMP lump[HEADER_LUMPS];
} BSPHEADER;
*/
	public class BspHeader 
	{
		public var version:int; // Version number, must be 30 for a valid HL BSP file
		public var lumps:Array;   // Stores the directory of lumps as array of BspLump (HEADER_LUMPS elements)
		public function BspHeader() 
		{
			
		}
		
	}

}