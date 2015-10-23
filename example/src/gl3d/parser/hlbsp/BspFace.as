package gl3d.parser.hlbsp 
{
	/**
	 * ...
	 * @author lizhi
	 */
	public class BspFace 
	{
		// Faces are equal to the polygons that make up the world
/*
typedef struct _BSPFACE
{
    uint16_t iPlane;                // Index of the plane the face is parallel to
    uint16_t nPlaneSide;            // Set if different normals orientation
    uint32_t iFirstEdge;            // Index of the first edge (in the surfedge array)
    uint16_t nEdges;                // Number of consecutive surfedges
    uint16_t iTextureInfo;          // Index of the texture info structure
    uint8_t  nStyles[4];            // Specify lighting styles
    //       nStyles[0]             // type of lighting, for the face
    //       nStyles[1]             // from 0xFF (dark) to 0 (bright)
    //       nStyles[2], nStyles[3] // two additional light models
    uint32_t nLightmapOffset;    // Offsets into the raw lightmap data
};
*/
  public  var plane:int;               // Index of the plane the face is parallel to
  public   var planeSide:int;           // Set if different normals orientation
   public  var firstEdge:int;           // Index of the first edge (in the surfedge array)
   public  var edges:int;               // Number of consecutive surfedges
   public  var textureInfo:int;         // Index of the texture info structure
   public  var styles:Array;           // Specify lighting styles
    //  styles[0]            // type of lighting, for the face
    //  styles[1]            // from 0xFF (dark) to 0 (bright)
    //  styles[2], styles[3] // two additional light models
   public  var lightmapOffset:int;      // Offsets into the raw lightmap data
		public function BspFace() 
		{
			
		}
		
	}

}