package gl3d.parser.mmd 
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import gl3d.core.Drawable3D;
	import gl3d.core.IndexBufferSet;
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
	import gl3d.util.Matrix3DUtils;
	/**
	 * ...
	 * @author lizhi
	 */
	public class MMD 
	{
		public var pmx:PMX;
		public var node:Node3D = new Node3D;
		public var skinNodes:Vector.<Node3D> = new Vector.<Node3D>;
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
			
			var skin:Skin = new Skin;
			skin.maxWeight = pmx.maxWeight;
			
			var bones:Vector.<Node3D> = new Vector.<Node3D>;
			var iks:Array = [];
			for each(var boneObj:Object in pmx.bones) {
				if (boneObj.IK) {
					iks.push(boneObj.IK);
				}
				var bone:Node3D = new Node3D;
				bone.name = boneObj.name;
				bone.type = "JOINT";
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
					var porigin:Array = pmx.bones[boneObj.parent].origin;
					bone.x -= porigin[0];
					bone.y -= porigin[1];
					bone.z -= porigin[2];
				}
				parent.addChild(bone);
				var invbind:Matrix3D = new Matrix3D;
				invbind.appendTranslation( -origin[0], -origin[1], -origin[2]);
				skin.invBindMatrixs.push(invbind);
			}
			
			skin.joints = bones;
			
			var drawable:Drawable3D = Meshs.createDrawable(null, vs, null, null);
			drawable.joints = new VertexBufferSet(js,pmx.maxWeight );
			drawable.weights = new VertexBufferSet(ws, pmx.maxWeight );
			
			i = 0;
			for each(var material:Object in pmx.materials) {
				var count:int = material.indexCount + i;
				var indices:Vector.<uint> = new Vector.<uint>;
				for (; i < count;i+=3 ) {
					indices.push(pmx.indices[i]);
					indices.push(pmx.indices[i+2]);
					indices.push(pmx.indices[i+1]);
				}
				var child:Node3D = new Node3D;
				child.drawable = new Drawable3D;
				child.drawable.pos = drawable.pos;
				child.drawable.joints = drawable.joints;
				child.drawable.weights = drawable.weights;
				child.drawable.index = new IndexBufferSet(indices);
				child.skin = skin;
				child.material = new Material;
				child.material.color[0] = material.diffuse[0];
				child.material.color[1] = material.diffuse[1];
				child.material.color[2] = material.diffuse[2];
				child.material.ambient[0] = material.ambient[0];
				child.material.ambient[1] = material.ambient[1];
				child.material.ambient[2] = material.ambient[2];
				node.addChild(child);
				Skin.optimize(child);
				skinNodes.push(child);
			}
			
			
			
		}
		
		public function bind(vmd:VMD):void {
			var anim:SkinAnimation = new SkinAnimation;
			anim.targets = skinNodes;
			node.controllers = new Vector.<Ctrl>;
			node.controllers.push(anim);
			anim.maxTime = 0;
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
					frame.matrix = q.toMatrix();
					if(node.parent&&name2bone[node.parent.name])
					frame.matrix.append(node.parent.matrix);
					frame.time = key.time / 1000 * 30;
					if (anim.maxTime<frame.time) {
						anim.maxTime = frame.time;
					}
					track.frames.push(frame);
				}
			}
		}
		
	}

}