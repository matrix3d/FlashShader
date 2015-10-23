package gl3d.parser.hlbsp 
{
	/**
	 * ...
	 * @author lizhi
	 */
	public class WadHeader 
	{
		/*
typedef struct
{
    char    szMagic[4]; 
    int32_t nDir;       
    int32_t nDirOffset;
} WADHEADER;
*/
 public   var magic:String;     // should be WAD2/WAD3
   public var dirs:int;      // number of directory entries
   public var dirOffset:int; // offset into directory
		public function WadHeader() 
		{
			
		}
		
	}

}