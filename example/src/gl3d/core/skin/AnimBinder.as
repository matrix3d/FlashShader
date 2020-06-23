package gl3d.core.skin 
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import gl3d.core.Node3D;
	import gl3d.ctrl.Ctrl;
	import gl3d.util.Matrix3DUtils;
	/**
	 * ...
	 * @author lizhi
	 */
	public class AnimBinder extends Ctrl
	{
		private var sac:SkinAnimationCtrl;
		private var joint:Joint;
		
		public function AnimBinder(sac:SkinAnimationCtrl,joint:Joint) 
		{
			this.joint = joint;
			this.sac = sac;
			
		}
		override public function update(time:int,node:Node3D):void 
		{
			if (sac.anim && sac.anim.jointMatrixs[joint.name]){
				var matr:Matrix3D = sac.anim.jointMatrixs[joint.name][1];
				/*if (sac.anim.jointMatrixs.id == "Walking,3,4"){
					var a:int = 1;
				}*/
				//trace(matr.rawData);
				//joint.matrix.copyFrom(matr);
				//joint.matrix = joint.matrix;
				//var wd:Matrix3D = joint.world.clone();
				
				//if(sac.anim.jointMatrixs.id=="Walking,3,4"){
			//		trace(sac.anim.jointMatrixs.id);
			//		trace(matr.rawData);
			//		trace(wd.rawData);
			//	}
				//wd.prepend(joint.invBindMatrix);
				//var wp:Vector3D = joint.world.position;
				//node.setPosition(wp.x/wp.w , wp.y/wp.w , wp.z/wp.w );
				node.matrix.copyFrom(matr);
				node.matrix = node.matrix;
				node.setScale(10, 10, 10);
				//trace(Matrix3DUtils.getScale(wd),wd.position);
				//trace(node.world);
			}
		}
		
	}

}