package gl3d.core.skin 
{
	import flash.geom.Matrix3D;
	import gl3d.core.animation.IAnimation;
	import gl3d.core.Node3D;
	import gl3d.ctrl.Ctrl;
	/**
	 * ...
	 * @author lizhi
	 */
	public class SkinAnimation extends Ctrl implements IAnimation
	{
		public var tracks:Vector.<Track> = new Vector.<Track>;
		public var bindShapeMatrix:Matrix3D;
		public var target:Node3D;
		private var time:Number = 0;
		public var endTime:Number = 0;
		public function SkinAnimation() 
		{
			
		}
		
		override public function update():void 
		{
			time+= 1 / 60;
			var t:Number = time % endTime;
			for each(var track:Track in tracks) {
				var last:TrackFrame = null;
				for each(var f:TrackFrame in track.frames) {
					last = f;
					if (f.time>=t) {
						break;
					}
				}
				if (last) {
					track.target.matrix = last.matrix;
				}
			}
			
			var world2local:Matrix3D = target.world2local;
			for (var i:int = 0; i < target.skin.joints.length;i++ ) {
				var joint:Node3D = target.skin.joints[i];
				var invBindMatrix:Matrix3D = target.skin.invBindMatrixs[i];
				var matrix:Matrix3D = target.skin.skinFrame.matrixs[i];
				matrix.identity();
				matrix.append(invBindMatrix);
				matrix.append(joint.world);
				matrix.append(world2local);
			};
		}
	}

}