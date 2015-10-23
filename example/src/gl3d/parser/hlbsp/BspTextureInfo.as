package gl3d.parser.hlbsp 
{
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class BspTextureInfo 
	{
		// Texinfo lump contains information about how textures are applied to surfaces
/*
typedef struct _BSPTEXTUREINFO
{
    VECTOR3D vS;      
    float    fSShift; 
    VECTOR3D vT;      
    float    fTShift; 
    uint32_t iMiptex; 
    uint32_t nFlags; 
};
*/
	public var s:Vector3D;          // 1st row of texture matrix
	public var sShift:Number;     // Texture shift in s direction
	public var t:Vector3D;          // 2nd row of texture matrix - multiply 1st and 2nd by vertex to get texture coordinates
	public var tShift:Number;     // Texture shift in t direction
	public var mipTexture:int; // Index into mipTextures array
	public var flags:int;      // Texture flags, seems to always be 0
		public function BspTextureInfo() 
		{
			
		}
		
	}

}