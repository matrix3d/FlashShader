
package flash3d {
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Node3D 
	{
		public var fs:Vector.<Face3D> = new Vector.<Face3D>;
		public var rot:Vector3D = new Vector3D;
		public var pos:Vector3D = new Vector3D;
		public var scale:Vector3D = new Vector3D(1,1,1);
		public function Node3D() 
		{
			
		}
		
	}

}