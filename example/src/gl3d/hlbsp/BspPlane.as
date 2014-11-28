package gl3d.hlbsp 
{
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class BspPlane 
	{// Planes lump contains plane structures
/*
typedef struct _BSPPLANE
{
	VECTOR3D vNormal; 
	float    fDist;  
	int32_t  nType; 
} BSPPLANE;
*/
 public   var normal:Vector3D; // The planes normal vector
   public var dist:Number;   // Plane equation is: vNormal * X = fDist
   public var type:int;   // Plane type, see vars
		
		public function BspPlane() 
		{
			
		}
		
	}

}