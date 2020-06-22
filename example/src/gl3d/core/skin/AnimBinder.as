package gl3d.core.skin 
{
	import flash.geom.Matrix3D;
	import gl3d.core.Node3D;
	import gl3d.ctrl.Ctrl;
	/**
	 * ...
	 * @author lizhi
	 */
	public class AnimBinder extends Ctrl
	{
		private var sac:SkinAnimationCtrl;
		private var name:String;
		
		public function AnimBinder(sac:SkinAnimationCtrl,name:String) 
		{
			this.name = name;
			this.sac = sac;
			
		}
		override public function update(time:int,node:Node3D):void 
		{
			if (sac.anim&&sac.anim.jointMatrixs[name]){
				var matr:Matrix3D = sac.anim.jointMatrixs[name];
				node.matrix.copyFrom(matr);
				node.matrix = node.matrix;
			}
		}
		
	}

}