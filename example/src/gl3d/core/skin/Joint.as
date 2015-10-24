package gl3d.core.skin 
{
	import flash.geom.Matrix3D;
	import gl3d.core.Node3D;
	import gl3d.core.skin.IK;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Joint extends Node3D
	{
		public var invBindMatrix:Matrix3D = new Matrix3D;
		public var ik:IK;
		public function Joint(name:String=null ) 
		{
			super(name);
		}
		
	}

}