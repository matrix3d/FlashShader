package gl3d.core.skin 
{
	import flash.display.Sprite;
	import flash.geom.Matrix3D;
	import flash.geom.Utils3D;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
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
		public var isCache:Boolean = true;
		public var tracks:Object = {};//Vector.<Track> = new Vector.<Track>;
		public var bindShapeMatrix:Matrix3D;
		public var targets:Vector.<Node3D>;
		public var targetNames:Vector.<String>;
		public var maxTime:Number = 0;
		private var q:Quaternion = new Quaternion;
		static private var q1:Quaternion= new Quaternion;
		static private var q2:Quaternion = new Quaternion;
		public var name:String;
		public var timeline:SkinAnimTimeLine = new SkinAnimTimeLine;
		//public var trackRoot:Node3D;//骨骼根节点
		public function SkinAnimation() 
		{
			
		}
		
		public function clone():SkinAnimation {
			var c:SkinAnimation = new SkinAnimation;
			//c.tracks = tracks;
			//if(targetNames)
			if(targetNames){
				c.targetNames = targetNames.slice();
			}/*else{
				c.targetNames = new Vector.<String>;
				for each(var t:Track in tracks){
					c.targetNames.push(t.);
				}
			}*/
			c.name = name;
			c.tracks = tracks;
			/*for each(t in tracks){
				var t2:Track = new Track;
				t2.targetName = t.targetName;
				for each(var f:TrackFrame in t.frames){
					var f2:TrackFrame = new TrackFrame;
					f2.time = f.time;
					f2.matrix = f.matrix.clone();
					t2.frames.push(f2);
				}
				c.tracks[t.targetName] = t2;// .push(t2);
			}*/
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
		
		private function getChildByName(node:Node3D,name:String):Node3D{
			if (node.name == name) return node;
			for each(var c:Node3D in node.children){
				var f:Node3D = getChildByName(c, name);
				if (f){
					return f;
				}
			}
			return null;
		}
		
		private function updateJointRoot(skin:Skin):void{
			if (skin.jointRoot == null){
				var depthJoints:Object = {};
				var mind:int = 100000;
				for each(var jtrack:Track in tracks){
					var jnode:Node3D = jtrack.target;
					if(jnode is Joint){
						var d:int = 0;
						var findnode:Node3D = jnode;
						while (findnode){
							findnode = findnode.parent;
							d++;
						}
						if (depthJoints[d]==null){
							depthJoints[d] = [];
							mind = Math.min(mind,d);
						}
						depthJoints[d].push(jnode);
					}
				}
				var minDepthJoints:Array = depthJoints[mind];
				while (true){
					if (minDepthJoints.length == 1){
						minDepthJoints[0].visible = false;
						skin.jointRoot = minDepthJoints[0];//.parent;
						var j:Joint = minDepthJoints[0];
						while (true){
							if (j.parent&&j.parent is Joint){
								j = j.parent as Joint;
							}else{
								break;
							}
						}
						skin.jointRoot = j;
						(skin.jointRoot as Joint).isRoot = true;
						break;
					}
					var temp:Array = [];
					for each(jnode in minDepthJoints){
						findnode = jnode.parent;
						if (temp.indexOf(findnode)==-1){
							temp.push(findnode);
						}
					}
					minDepthJoints = temp;
				}
			}
		}
		
		public function update(t:Number,node:Node3D):void 
		{
			if (targets==null&&targetNames){//根据targetname生成target
				targets = new Vector.<Node3D>;
				for each(var tname:String in targetNames){
					var tn:Node3D = getChildByName(node, tname);
					if (tn){
						targets.push(tn);
					}
				}
			}
			/*for each(var track:Track in tracks) {//检查target是否存在
				if (track.target==null){
					track.target = getChildByName(node, track.targetName);
				}
			}*/
			if (isCache){//缓存
				var tid:int = int(t * 1000 / 60);
				var needCache:Boolean = false;
				for each(var target:Node3D in targets){
					if (target.skin == null) continue;
					
					updateJointRoot(target.skin);
					
					if (target.skin.cache[name]==null){
						needCache = true;
					}else{
						target.skin.cacheFrame = target.skin.cache[name][tid];
						if (target.skin.cacheFrame==null){
							needCache = true;
						}
					}
				}
				if (!needCache){
					return;
				}
				t = tid * 60 / 1000;
			}
			for each(var track:Track in tracks) {//更新动画
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
				}else if(f){
					track.target.matrix.copyFrom(f.matrix);
				}
			}
			
			var lastSkin:Skin;
			var first:Boolean = true;
			for each(target in targets){
				if (target.skin == null) continue;
				if (lastSkin==target.skin){
					break;
				}
				lastSkin = target.skin;
				var currentFrame:SkinFrame;
				if(isCache){
					target.skin.cacheFrame = new SkinFrame;
					currentFrame = target.skin.cacheFrame;
					if (target.skin.cache[name]==null){
						target.skin.cache[name] = [];
					}
					target.skin.cache[name][tid] = currentFrame;
				}else{
					target.skin.cacheFrame = null;
					if (target.skin.skinFrame == null) target.skin.skinFrame = new SkinFrame;
					currentFrame = target.skin.skinFrame;
				}
				currentFrame.quaternions.length = currentFrame.matrixs.length * (target.skin.useHalfFloat?4:8);
				updateIK(target.skin.iks,target);
				
				/*if (target.skin.joints.length<target.skin.jointNames.length){
					for (i = 0; i < target.skin.jointNames.length;i++ ){
						target.skin.joints[i] = getChildByName(node, target.skin.jointNames[i]);
					}
				}*/
				
				updateJointRoot(target.skin);
				
				if(first){
					target.skin.jointRoot.updateTransforms(true);
					first = false;
				}
				
				if (currentFrame.matrixs.length == 0) {
					var nj:int = target.skin.joints.length;
					for (i = 0; i < nj;i++ ) {
						currentFrame.matrixs.push(new Matrix3D);
					}
				}
				var js:Vector.<Joint> = target.skin.joints;
				var ms:Vector.<Matrix3D> = currentFrame.matrixs;
				var useHF:Boolean = target.skin.useHalfFloat;
				var useQuat:Boolean = target.skin.useQuat;
				var l:int = js.length;
				for (var i:int = 0; i <l ;i++ ) {
					var joint:Joint = js[i];
					var matrix:Matrix3D = ms[i];
					matrix.copyFrom(joint.invBindMatrix);
					matrix.append(joint.world);
					//matrix.append(target.skin.jointRoot.world2local);
					
					if(useQuat){
						q.fromMatrix(matrix);
						var qs:Vector.<Number> = currentFrame.quaternions;
						var r:Vector3D = q.tran;
						var s:Vector3D = q.scale;
						if (useHF){
							var i4:int = i * 4;
							
							qs[i4++] =  int(1000000/(r.x/s.x +200)) + (q.x + 1) / 2 ;
							qs[i4++] =  int(1000000/(r.y/s.y+200)) + (q.y + 1) / 2 ;
							qs[i4++] =  int(1000000/(r.z/s.z +200)) + (q.z + 1) / 2 ;
							qs[i4++] = (q.w + 1) / 2;
						}else{
							var i8:int = i * 8;
							qs[i8++] = q.x;
							qs[i8++] = q.y;
							qs[i8++] = q.z;
							qs[i8++] = q.w;
							qs[i8++] = r.x / s.x;
							qs[i8++] = r.y / s.y;
							qs[i8++] = r.z / s.z;
							qs[i8] = 0;
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
											/*var qx:Array = HFloat.half2float2Agal(HFloat.toHalfFloat2(r.x/s.x,q.x));
											var qy:Array = HFloat.half2float2Agal(HFloat.toHalfFloat2(r.y/s.y,q.y));
											var qz:Array = HFloat.half2float2Agal(HFloat.toHalfFloat2(r.z/s.z,q.z));
											var qw:Array = HFloat.half2float2Agal(HFloat.toHalfFloat(q.w));*/
											/*q.x = test(r.x/s.x,q.x)[1];
											q.y = test(r.y/s.y,q.y)[1];
											q.z = test(r.z/s.z,q.z)[1];
											q.w = test(0,q.w)[1];
											q.tran.x = test(r.x/s.x,q.x)[0];
											q.tran.y = test(r.y/s.y,q.y)[0];
											q.tran.z = test(r.z/s.z,q.z)[0];*/
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