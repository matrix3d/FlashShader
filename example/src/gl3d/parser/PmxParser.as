package gl3d.parser 
{
	import flash.utils.ByteArray;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.meshs.Meshs;
	/**
	 * ...
	 * @author lizhi
	 */
	public class PmxParser 
	{
		public var node:Node3D=new Node3D;
		public function PmxParser(buff:ByteArray) 
		{
			var mmd:MMD = new MMD(buff);
			var vs:Vector.<Number> = new Vector.<Number>;
			for each(var v:Object in mmd.vertices) {
				var pos:Array = v.pos;
				vs.push(pos[0],pos[1],pos[2]);
			}
			var indices:Vector.<uint> = new Vector.<uint>;
			for (var i:int = 0; i < mmd.indices.length;i+=3 ) {
				indices[i] = mmd.indices[i];
				indices[i+1] = mmd.indices[i+2];
				indices[i+2] = mmd.indices[i+1];
			}
			node.drawable = Meshs.createDrawable(indices, vs, null, null);
			node.material = new Material;
		}
		
	}

}