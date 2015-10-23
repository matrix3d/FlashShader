package gl3d.parser.hlbsp 
{
	/**
	 * ...
	 * @author lizhi
	 */
	public class BspEdge 
	{
		// Edge struct contains the begining and end vertex for each edge
/*
typedef struct _BSPEDGE
{
    uint16_t iVertex[2];        
};
*/
public	var vertices:Array; // Indices into vertex array
		public function BspEdge() 
		{
			
		}
		
	}

}