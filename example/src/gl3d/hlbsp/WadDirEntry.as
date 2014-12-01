package gl3d.hlbsp 
{
	/**
	 * ...
	 * @author lizhi
	 */
	public class WadDirEntry 
	{
		// Directory entry structure
/*
typedef struct _WADDIRENTRY
{
    int32_t nFilePos;            
    int32_t nDiskSize;             
    int32_t nSize;                 
    int8_t  nType;                 
    bool    bCompression;  
    int16_t nDummy;             
    char    szName[MAXTEXTURENAME];
} WADDIRENTRY;
*/

 public   var offset:int;           // offset in WAD
   public var compressedSize:int;   // size in file
   public var size:int;             // uncompressed size
   public var type:int;             // type of entry
   public var compressed:Boolean;       // 0 if none
   public var name:String;             // must be null terminated
		public function WadDirEntry() 
		{
			
		}
		
	}

}