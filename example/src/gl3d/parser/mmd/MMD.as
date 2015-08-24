package gl3d.parser.mmd 
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import gl3d.core.Material;
	import gl3d.core.math.Quaternion;
	import gl3d.core.Node3D;
	import gl3d.core.skin.Skin;
	import gl3d.core.skin.SkinAnimation;
	import gl3d.core.skin.Track;
	import gl3d.core.skin.TrackFrame;
	import gl3d.core.VertexBufferSet;
	import gl3d.ctrl.Ctrl;
	import gl3d.meshs.Meshs;
	import gl3d.parser.mmd.PMX;
	/**
	 * ...
	 * @author lizhi
	 */
	public class MMD 
	{
		public var pmx:PMX;
		public var node:Node3D = new Node3D;
		public var name2bone:Object = { };
		private var q:Quaternion = new Quaternion;
		public function MMD(pmxBuff:ByteArray) 
		{
			pmx = new PMX(pmxBuff);
			
			var vs:Vector.<Number> = new Vector.<Number>;
			var ws:Vector.<Number> = new Vector.<Number>;
			var js:Vector.<Number> = new Vector.<Number>;
			var uvs:Vector.<Number> = new Vector.<Number>;
			for each(var v:Object in pmx.vertices) {
				var pos:Array = v.pos;
				var sbones:Array = v.skin.bones;
				var weights:Array = v.skin.weights;
				var uv:Array = v.uv;
				vs.push(pos[0], pos[1], pos[2]);
				uv.push(uv[0], uv[1]);
				for (var i:int = 0; i < sbones.length;i++ ) {
					js.push(sbones[i]);
					ws.push(weights[i]);
				}
				for (; i < pmx.maxWeight;i++ ) {
					js.push(0);
					ws.push(0);
				}
			}
			var indices:Vector.<uint> = new Vector.<uint>;
			for (i = 0; i < pmx.indices.length;i+=3 ) {
				indices[i] = pmx.indices[i];
				indices[i+1] = pmx.indices[i+2];
				indices[i+2] = pmx.indices[i+1];
			}
			node.drawable = Meshs.createDrawable(indices, vs, null, null);
			node.drawable.joints = new VertexBufferSet(js,pmx.maxWeight );
			node.drawable.weights = new VertexBufferSet(ws, pmx.maxWeight );
			node.skin = new Skin;
			node.skin.maxWeight = pmx.maxWeight;
			node.skin.invBindMatrixs;
			node.skin.joints;
			//node.material = new Material;
			
			var bones:Vector.<Node3D> = new Vector.<Node3D>;
			for each(var boneObj:Object in pmx.bones) {
				var bone:Node3D = new Node3D;
				bone.name = boneObj.name;
				name2bone[bone.name] = bone;
				bone.material = new Material;
				bone.drawable = Meshs.cube(.5, .5, .5);
				var origin:Array = boneObj.origin;
				bone.x = origin[0];
				bone.y = origin[1];
				bone.z = origin[2];
				bones.push(bone);
				if (boneObj.parent==-1) {
					var parent:Node3D = node;
				}else {
					parent = bones[boneObj.parent];
					origin = pmx.bones[boneObj.parent].origin;
					bone.x -= origin[0];
					bone.y -= origin[1];
					bone.z -= origin[2];
				}
				parent.addChild(bone);
			}
			
			node.skin.joints = bones;
		}
		
		public function bind(vmd:VMD):void {
			var anim:SkinAnimation = new SkinAnimation;
			node.controllers = new Vector.<Ctrl>;
			node.controllers.push(anim);
			anim.endTime = 0;
			var name2track:Object = { };
			for each(var key:Object in vmd.boneKeys) {
				var node:Node3D = name2bone[key.name];
				if (node) {
					var track:Track = name2track[node.name];
					if (track==null) {
						track = name2track[node.name] = new Track;
						track.target = node;
						anim.tracks.push(track);
					}
					var frame:TrackFrame = new TrackFrame;
					q.x = key.rot[0];
					q.y = key.rot[1];
					q.z = key.rot[2];
					q.w = key.rot[3];
					q.tran.x = key.pos[0];
					q.tran.y = key.pos[1];
					q.tran.z = key.pos[2];
					//q.computeW();
					frame.matrix = q.toMatrix();
					frame.matrix.invert();
					//frame.matrix.append(node.parent.world2local);
					//frame.matrix = new Matrix3D;
					//frame.matrix.recompose(new <Vector3D>[new Vector3D(key.pos[0],key.pos[1],key.pos[2]),new Vector3D(key.rot[0],key.rot[1],key.rot[2]),new Vector3D(1,1,1)]);
					frame.time = key.time/1000;
					if (anim.endTime<frame.time) {
						anim.endTime = frame.time;
					}
					track.frames.push(frame);
				}
			}
		}
		
	}

}