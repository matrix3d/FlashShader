package gl3d.core.skin 
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import gl3d.core.animation.IAnimation;
	import gl3d.core.math.Quaternion;
	import gl3d.core.Node3D;
	import gl3d.core.VertexBufferSet;
	import gl3d.ctrl.Ctrl;
	/**
	 * ...
	 * @author lizhi
	 */
	public class SkinAnimation extends Ctrl implements IAnimation
	{
		public var tracks:Vector.<Track> = new Vector.<Track>;
		public var bindShapeMatrix:Matrix3D;
		public var targets:Vector.<Node3D>;
		public var endTime:Number = 0;
		private var q:Quaternion = new Quaternion;
		public function SkinAnimation() 
		{
			
		}
		
		public function clone():SkinAnimation {
			var c:SkinAnimation = new SkinAnimation;
			c.tracks = tracks;
			c.bindShapeMatrix = bindShapeMatrix;
			c.endTime = endTime;
			return c;
		}
		
		override public function update(time:int):void 
		{
			var t:Number = (time/1000) % endTime;
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
			
			for each(var target:Node3D in targets){
				var world2local:Matrix3D = target.world2local;
				if (target.skin.skinFrame == null) target.skin.skinFrame = new SkinFrame;
				target.skin.skinFrame.quaternions.length = 0;
				target.skin.joints[0].updateTransforms(true);
				
				if (target.skin.skinFrame.matrixs.length == 0) {
					var nj:int = target.skin.joints.length;
					for (i = 0; i < nj;i++ ) {
						target.skin.skinFrame.matrixs.push(new Matrix3D);
					}
				}
				
				for (var i:int = 0; i < target.skin.joints.length;i++ ) {
					var joint:Node3D = target.skin.joints[i];
					var invBindMatrix:Matrix3D = target.skin.invBindMatrixs[i];
					var matrix:Matrix3D = target.skin.skinFrame.matrixs[i];
					matrix.identity();
					matrix.append(invBindMatrix);
					matrix.append(joint.world);
					matrix.append(world2local);
					
					if(target.skin.useQuat){
						q.fromMatrix(matrix);
						target.skin.skinFrame.quaternions.push(
							q.x, q.y, q.z, q.w,
							q.tran.x,q.tran.y,q.tran.z,q.tran.w
						);
					}
				}
				
				if (target.skin.useCpu) {
					var source:Vector.<Number> = target.drawable.pos.data;
					if (target.drawable.cpuSkinPos==null) {
						target.drawable.cpuSkinPos = new VertexBufferSet(new Vector.<Number>(source.length), 3);
					}
					var out:Vector.<Number> = target.drawable.cpuSkinPos.data;
					var v:Vector3D = new Vector3D;
					for (i = 0; i < out.length / 3; i++ ) {
						var x:Number = 0;
						var y:Number = 0;
						var z:Number = 0;
						v.setTo( source[i*3], source[i*3+1],source[i*3 + 2]);
						for (var j:int = 0; j < target.skin.maxWeight;j++ ) {
							var weight:Number = target.drawable.weights.data[i * target.skin.maxWeight + j];
							var jointIndex:int = target.drawable.joints.data[i * target.skin.maxWeight + j] / 4;
							matrix = target.skin.skinFrame.matrixs[jointIndex];
							if (weight != 0) {
								if(!target.skin.useQuat){
									var vr:Vector3D = matrix.transformVector(v);
								}else {
									q.fromMatrix(matrix);
									vr = q.rotatePoint(v);
									vr = vr.add(q.tran);
								}
								x += vr.x*weight;
								y += vr.y*weight;
								z += vr.z * weight;
							}
						}
						out[i * 3] = x;
						out[i*3+1] = y;
						out[i*3 + 2] = z;
					}
					target.drawable.cpuSkinPos.invalid = true;
				}
			}
		}
	}

}