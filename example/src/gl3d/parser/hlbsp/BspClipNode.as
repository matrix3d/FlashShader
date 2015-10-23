package gl3d.parser.hlbsp 
{
	/**
	 * ...
	 * @author lizhi
	 */
	public class BspClipNode 
	{
		// Clip nodes are used for collision detection and make up the clipping hull.
/*
typedef struct _BSPCLIPNODE
{
    int32_t iPlane;
    int16_t iChildren[2]; 
};
*/
public	var plane:int;    // Index into planes
public		var children:Array; // negative numbers are contents behind and in front of the plane
		public function BspClipNode() 
		{
			
		}
		
	}

}