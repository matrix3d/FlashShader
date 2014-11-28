package gl3d.hlbsp 
{
	/**
	 * ...
	 * @author lizhi
	 */
	public class BspTextureHeader 
	{
		// Textures lump begins with a header, followed by offsets to BSPMIPTEX structures, then BSPMIPTEX structures
/*
typedef struct _BSPTEXTUREHEADER
{
    uint32_t nMipTextures;
};
*/
// 32-bit offsets (within texture lump) to (nMipTextures) BSPMIPTEX structures
/*
typedef int32_t BSPMIPTEXOFFSET;
*/
	public var textures:int; // Number of BSPMIPTEX structures
	public var offsets:Array;  // Array of offsets to the textures
		public function BspTextureHeader() 
		{
			
		}
		
	}

}