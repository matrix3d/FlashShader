package gl3d.ctrl 
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import gl3d.core.Node3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class FollowCtrl extends Ctrl
	{
		private var target:Node3D;
		private var node:Node3D;
		private var help:Matrix3D = new Matrix3D;
		private var help2:Matrix3D = new Matrix3D;
		public function FollowCtrl(target:Node3D,node:Node3D) 
		{
			this.node = node;
			this.target = target;
			
		}
		
		override public function update():void 
		{
			help.identity();
			help.appendRotation(45, Vector3D.X_AXIS);
			help.appendTranslation(0, 20, -20);
			help2.recompose(Vector.<Vector3D>([target.trs[0],target.trs[1],new Vector3D(1,1,1)]));
			help.append(help2);
			node.matrix = Matrix3D.interpolate(node.matrix, help, 0.05);
			node.matrix = node.matrix;
		}
		
	}

}