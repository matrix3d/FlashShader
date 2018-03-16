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
		public var isRoot:Boolean = false;
		public function Joint(name:String=null ) 
		{
			super(name);
		}
		
		override public function clone():Node3D 
		{
			return null;
			/*var c:Joint = super.clone() as Joint;
			c.invBindMatrix.copyFrom(invBindMatrix);
			return c;*/
		}
		
		//虽然joint在显示列表上，但是只是在骨骼根节点截断
		override public function get world():Matrix3D 
		{
			if (dirtyWrold)
			{
				matrix.copyToMatrix3D(_world);
				if (parent&&!isRoot)
				{
					_world.append(parent.world);
				}
				dirtyWrold = false;
				dirtyInv = true;
			}
			return _world;
		}
		
		override public function set world(value:Matrix3D):void 
		{
			super.world = value;
		}
	}

}