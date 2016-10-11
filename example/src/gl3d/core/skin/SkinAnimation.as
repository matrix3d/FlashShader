package gl3d.core.skin 
{
	import flash.geom.Matrix3D;
	import flash.geom.Utils3D;
	import flash.geom.Vector3D;
	import gl3d.core.animation.IAnimation;
	import gl3d.core.skin.Joint;
	import gl3d.core.math.Quaternion;
	import gl3d.core.Node3D;
	import gl3d.core.VertexBufferSet;
	import gl3d.ctrl.Ctrl;
	import gl3d.util.HFloat;
	import gl3d.util.Matrix3DUtils;
	/**
	 * ...
	 * @author lizhi
	 */
	public class SkinAnimation
	{
		public var tracks:Vector.<Track> = new Vector.<Track>;
		public var bindShapeMatrix:Matrix3D;
		public var targets:Vector.<Node3D>;
		public var maxTime:Number = 0;
		private var q:Quaternion = new Quaternion;
		static private var q1:Quaternion= new Quaternion;
		static private var q2:Quaternion = new Quaternion;
		public var name:String;
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
		
		static public function interpolate(m1 : Matrix3D,m2 : Matrix3D,p : Number,target:Matrix3D) : Matrix3D {
			if (target==null) {
				target = new Matrix3D;
			}
			q1.fromMatrix(m1);
			q2.fromMatrix(m2);
			q1.lerpTo(q2, p);
			
			return q1.toMatrix(target);
		}
		
		public function update(t:Number):void 
		{
			for each(var track:Track in tracks) {
				var last:TrackFrame = null;
				var f:TrackFrame = null;
				for each(f in track.frames) {
					if (f.time>=t) {
						break;
					}
					last = f;
				}
				if (f && last) {
					interpolate(last.matrix, f.matrix, (t - last.time) / (f.time-last.time), track.target.matrix);
				}else {
					track.target.matrix.copyFrom(f.matrix);
				}
				track.target.updateTransforms(true);
			}
			
			
			for each(var target:Node3D in targets){
				var world2local:Matrix3D = target.world2local;
				if (target.skin == null) continue;
				if (target.skin.skinFrame == null) target.skin.skinFrame = new SkinFrame;
				target.skin.skinFrame.quaternions.length = target.skin.skinFrame.matrixs.length * 8;
				updateIK(target.skin.iks,target);
				if (target.skin.skinFrame.matrixs.length == 0) {
					var nj:int = target.skin.joints.length;
					for (i = 0; i < nj;i++ ) {
						target.skin.skinFrame.matrixs.push(new Matrix3D);
					}
				}
				
				for (var i:int = 0; i < target.skin.joints.length;i++ ) {
					var joint:Joint = target.skin.joints[i];
					var matrix:Matrix3D = target.skin.skinFrame.matrixs[i];
					matrix.copyFrom(target.matrix);
					matrix.append(joint.invBindMatrix);
					matrix.append(joint.world);
					matrix.append(world2local);
					
					if(target.skin.useQuat){
						q.fromMatrix(matrix);
						var qs:Vector.<Number> = target.skin.skinFrame.quaternions;
						var r:Vector3D = q.tran;
						var s:Vector3D = q.scale;
						var i8:int = i * 8;
						if(target.skin.useHalfFloat){
							//qs[i8++] = q.x;
							//qs[i8++] = q.y;
							//qs[i8++] = q.z;
							//qs[i8++] = q.w;
							
							qs[i8++] = HFloat.toHalfFloat(q.x);
							qs[i8++] = HFloat.toHalfFloat(q.y);
							qs[i8++] = HFloat.toHalfFloat(q.z);
							qs[i8++] = HFloat.toHalfFloat(q.w);
							qs[i8++] = HFloat.toHalfFloat(r.x/s.x);
							qs[i8++] = HFloat.toHalfFloat(r.y/s.y);
							qs[i8++] = HFloat.toHalfFloat(r.z/s.z);
							qs[i8] = 0;// r.w;
							
							//qs[i8++] = r.x/s.x;
							//qs[i8++] = r.y/s.y;
							//qs[i8++] = r.z / s.z;
							//qs[i8] = 0;// r.w;
							
						}else{
							qs[i8++] = q.x;
							qs[i8++] = q.y;
							qs[i8++] = q.z;
							qs[i8++] = q.w;
							qs[i8++] = r.x/s.x;
							qs[i8++] = r.y/s.y;
							qs[i8++] = r.z/s.z;
							qs[i8] = 0;// r.w;
						}
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
							var jointIndex:int = target.drawable.joint.data[i * target.skin.maxWeight + j];
							if(jointIndex!=-1){
								var weight:Number = target.drawable.weight.data[i * target.skin.maxWeight + j];
								matrix = target.skin.skinFrame.matrixs[jointIndex];
								if (weight != 0) {
									if(!target.skin.useQuat){
										var vr:Vector3D = matrix.transformVector(pos);
										var nr:Vector3D = matrix.deltaTransformVector(norm);
									}else {
										q.fromMatrix(matrix);
										if (target.skin.useHalfFloat){
											q.x = HFloat.toFloat(HFloat.toHalfFloat(q.x));
											q.y = HFloat.toFloat(HFloat.toHalfFloat(q.y));
											q.z = HFloat.toFloat(HFloat.toHalfFloat(q.z));
											q.w = HFloat.toFloat(HFloat.toHalfFloat(q.w));
											q.tran.x=HFloat.toFloat(HFloat.toHalfFloat(q.tran.x));
											q.tran.y=HFloat.toFloat(HFloat.toHalfFloat(q.tran.y));
											q.tran.z=HFloat.toFloat(HFloat.toHalfFloat(q.tran.z));
										}
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
		
		private function updateIK(iks:Vector.<Joint>, mesh:Node3D):void {
			//return;
			if (iks == null) return;
			for (var a:int=0,al:int=iks.length; a<al; a++) {
				var target:Joint = iks[a];
				var ik:IK = target.ik;
				var effector:Joint = ik.effector;
				var targetPosMatrix:Matrix3D = target.world.clone();
				targetPosMatrix.append(mesh.world2local);
				var targetPos:Vector3D = targetPosMatrix.position;
				var il:int = ik.iteration;
				var jl:int = ik.links.length;
				// リンクの回転を初期化。
				for (var j:int=0; j<jl; j++) {
					var ikl:IKLink = ik.links[j];
					var link:Joint = ikl.joint;
					var p:Vector3D = link.matrix.position;
					link.matrix.identity();
					link.matrix.appendTranslation(p.x, p.y, p.z);
					link.updateTransforms(true);
				}
				for (var i:int=0; i<il; i++) {
					for (j=0; j<jl; j++) {
						ikl = ik.links[j];
						link = ikl.joint;
						var inv:Matrix3D = link.world.clone();
						inv.append(mesh.world2local);
						inv.invert();
						var effectorVecMatrix:Matrix3D = effector.world.clone();
						effectorVecMatrix.append(mesh.world2local);
						var effectorVec:Vector3D = effectorVecMatrix.position;
						effectorVec = Utils3D.projectVector(inv, effectorVec);
						effectorVec.normalize();
						var targetVec:Vector3D = targetPos.clone();
						targetVec = Utils3D.projectVector(inv, targetVec);
						targetVec.normalize();
						var angle:Number = targetVec.dotProduct(effectorVec);
						if (angle > 1) { // 誤差対策。
							angle = 1;
						}
						angle = Math.acos(angle);
						if (angle < 1.0e-5) { // 発散対策。
							continue; // 微妙に振動することになるから抜ける方が無難かな。
						}
						if (angle > ik.control) {
							angle = ik.control;
						}
						
						var axis:Vector3D = effectorVec.crossProduct(targetVec);
						axis.normalize();
						p = link.matrix.position;
						link.matrix.appendRotation(angle * 180 / Math.PI, axis);
						link.matrix.position = p;
						if (ikl.limits) { // 実質的に「ひざ」限定。
							// 簡易版
							var q:Quaternion = new Quaternion;
							q.fromMatrix(link.matrix);
							var t:Number = q.w;
							q.setTo(-Math.sqrt(1 - t * t), 0, 0); // X軸回転に限定。
							q.toMatrix(link.matrix);	
						}
						link.updateTransforms(true);
					}
				}
			}
		}
	}

}