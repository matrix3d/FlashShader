package gl3d.core.skin 
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import gl3d.core.animation.IAnimation;
	import gl3d.core.skin.Joint;
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
		public var maxTime:Number = 0;
		public var startTime:Number = 0;
		private var q:Quaternion = new Quaternion;
		private var interMatrix:Matrix3D = new Matrix3D;
		public function SkinAnimation() 
		{
			
		}
		
		public function clone():SkinAnimation {
			var c:SkinAnimation = new SkinAnimation;
			c.tracks = tracks;
			c.bindShapeMatrix = bindShapeMatrix;
			c.maxTime = maxTime;
			return c;
		}
		
		override public function update(time:int):void 
		{
			var t:Number = ((time-startTime) / 1000) % maxTime;
			if (isNaN(t)) {
				t = 0;
			}
			for each(var track:Track in tracks) {
				var last:TrackFrame = null;
				for each(var f:TrackFrame in track.frames) {
					if (f.time>=t) {
						break;
					}
					last = f;
				}
				if (f && last) {
					interMatrix.copyFrom(last.matrix);
					interMatrix.interpolateTo(f.matrix, (t - last.time) / (f.time-last.time));
					track.target.matrix.copyFrom(interMatrix);
				}else {
					track.target.matrix.copyFrom(f.matrix);
				}
				track.target.updateTransforms(true);
			}
			
			for each(var target:Node3D in targets){
				var world2local:Matrix3D = target.world2local;
				if (target.skin.skinFrame == null) target.skin.skinFrame = new SkinFrame;
				target.skin.skinFrame.quaternions.length = 0;
				
				if (target.skin.skinFrame.matrixs.length == 0) {
					var nj:int = target.skin.joints.length;
					for (i = 0; i < nj;i++ ) {
						target.skin.skinFrame.matrixs.push(new Matrix3D);
					}
				}
				
				for (var i:int = 0; i < target.skin.joints.length;i++ ) {
					var joint:Joint = target.skin.joints[i];
					var invBindMatrix:Matrix3D = joint.invBindMatrix//target.skin.invBindMatrixs[i];
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
					var sourcePos:Vector.<Number> = target.drawable.pos.data;
					var sourceNorm:Vector.<Number> = target.drawable.norm.data;
					if (target.drawable.pos.cpuSkin==null) {
						target.drawable.pos.cpuSkin = new VertexBufferSet(new Vector.<Number>(sourcePos.length), 3);
					}
					if (target.drawable.norm.cpuSkin==null) {
						target.drawable.norm.cpuSkin = new VertexBufferSet(new Vector.<Number>(sourceNorm.length), 3);
					}
					var outpos:Vector.<Number> = target.drawable.pos.cpuSkin.data;
					var outnorm:Vector.<Number> = target.drawable.norm.cpuSkin.data;
					var pos:Vector3D = new Vector3D;
					var norm:Vector3D = new Vector3D;
					for (i = 0; i < outpos.length / 3; i++ ) {
						var x:Number = 0;
						var y:Number = 0;
						var z:Number = 0;
						var nx:Number = 0;
						var ny:Number = 0;
						var nz:Number = 0;
						pos.setTo( sourcePos[i*3], sourcePos[i*3+1],sourcePos[i*3 + 2]);
						norm.setTo( sourceNorm[i*3], sourceNorm[i*3+1],sourceNorm[i*3 + 2]);
						for (var j:int = 0; j < target.skin.maxWeight;j++ ) {
							var jointIndex:int = target.drawable.joints.data[i * target.skin.maxWeight + j];
							if(jointIndex!=-1){
								var weight:Number = target.drawable.weights.data[i * target.skin.maxWeight + j];
								matrix = target.skin.skinFrame.matrixs[jointIndex];
								if (weight != 0) {
									if(!target.skin.useQuat){
										var vr:Vector3D = matrix.transformVector(pos);
										var nr:Vector3D = matrix.deltaTransformVector(norm);
									}else {
										q.fromMatrix(matrix);
										vr = q.rotatePoint(pos);
										vr = vr.add(q.tran);
										nr = q.rotatePoint(norm);
									}
									x += vr.x*weight;
									y += vr.y*weight;
									z += vr.z * weight;
									
									nx += nr.x*weight;
									ny += nr.y*weight;
									nz += nr.z * weight;
								}
							}
						}
						outpos[i * 3] = x;
						outpos[i*3+1] = y;
						outpos[i * 3 + 2] = z;
						var len:Number = Math.sqrt(nx * nx + ny * ny + nz * nz);
						nx /= len;
						ny /= len;
						nz /= len;
						outnorm[i * 3] = nx;
						outnorm[i * 3+1] = ny;
						outnorm[i * 3+2] = nz;
					}
					target.drawable.pos.cpuSkin.invalid = true;
					target.drawable.norm.cpuSkin.invalid = true;
				}
			}
		}
	}

}