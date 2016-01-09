package awayphysics 
{
	import flash.geom.Matrix3D;
	import gl3d.core.Node3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class GL3DObject extends Away3dObject
	{
		public var node:Node3D;
		
		public function GL3DObject(node:Node3D) 
		{
			this.node = node;
			
		}
		override public function set matrix(value:Matrix3D):void 
		{
			super.matrix = value;
			node.matrix = value;
			node.updateTransforms();
		}
	}

}