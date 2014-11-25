package gl3d.pick 
{
	import flash.geom.Vector3D;
	import gl3d.core.Node3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Picking 
	{
		
		public function Picking() 
		{
			
		}
		
		public function pick(node:Node3D,rayOrigin:Vector3D, rayDirection:Vector3D,pixelPos:Vector3D=null ):Boolean {
			return false;
		}
		
	}

}