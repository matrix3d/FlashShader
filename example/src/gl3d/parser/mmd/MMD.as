package gl3d.parser.mmd 
{
	import flash.utils.ByteArray;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.meshs.Meshs;
	import gl3d.parser.mmd.PMX;
	/**
	 * ...
	 * @author lizhi
	 */
	public class MMD 
	{
		public var node:Node3D=new Node3D;
		public function MMD(pmxBuff:ByteArray,vmdBuff:ByteArray) 
		{
			var pmx:PMX = new PMX(pmxBuff);
			var vmd:VMD = new VMD(vmdBuff);
			
			var vs:Vector.<Number> = new Vector.<Number>;
			for each(var v:Object in pmx.vertices) {
				var pos:Array = v.pos;
				vs.push(pos[0],pos[1],pos[2]);
			}
			var indices:Vector.<uint> = new Vector.<uint>;
			for (var i:int = 0; i < pmx.indices.length;i+=3 ) {
				indices[i] = pmx.indices[i];
				indices[i+1] = pmx.indices[i+2];
				indices[i+2] = pmx.indices[i+1];
			}
			node.drawable = Meshs.createDrawable(indices, vs, null, null);
			//node.material = new Material;
			
			var bones:Vector.<Node3D> = new Vector.<Node3D>;
			for each(var boneObj:Object in pmx.bones) {
				var bone:Node3D = new Node3D;
				bone.name = boneObj.name;
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
			
			
		}
		
	}

}