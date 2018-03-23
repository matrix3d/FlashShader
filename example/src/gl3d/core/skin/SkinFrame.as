package gl3d.core.skin 
{
	import flash.geom.Matrix3D;
	import flash.utils.ByteArray;
	import gl3d.core.math.Quaternion;
	/**
	 * ...
	 * @author lizhi
	 */
	public class SkinFrame 
	{
		public var matrixs:Vector.<Matrix3D> = new Vector.<Matrix3D>;
		public var quaternions:Vector.<Number> = new Vector.<Number>;
		//public var halfQuaternions:ByteArray = new ByteArray;
		public function SkinFrame() 
		{
			
		}
		
	}

}