package gl3d.hlbsp 
{
	/**
	 * ...
	 * @author lizhi
	 */
	public class BspMipTexture 
	{
		/*
typedef struct _BSPMIPTEX
{
    char     szName[MAXTEXTURENAME]; 
    uint32_t nWidth, nHeight;        
    uint32_t nOffsets[MIPLEVELS];
};
*/
	public var name:String;    // Name of texture, for reference from external WAD file
	public var width:int;   // Extends of the texture
	public var height:int; 
	public var offsets:Array; // Offsets to MIPLEVELS texture mipmaps, if 0 texture data is stored in an external WAD file
		public function BspMipTexture() 
		{
			
		}
		
	}

}