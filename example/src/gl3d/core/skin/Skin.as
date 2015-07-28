package gl3d.core.skin 
{
	import flash.geom.Matrix3D;
	import gl3d.core.Node3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Skin 
	{
		public var skinFrame:SkinFrame;
		public var maxWeight:int;
		public var joints:Vector.<Node3D> = new Vector.<Node3D>;
		public var invBindMatrixs:Vector.<Matrix3D> = new Vector.<Matrix3D>;
		public var useQuat:Boolean = true;
		public var useCpu:Boolean = false;
		public function Skin() 
		{
			
		}
		
	}

}