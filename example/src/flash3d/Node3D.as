
package flash3d {
	import flash.geom.Vector3D;
	import gl3d.Drawable3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Node3D 
	{
		public var fs:Vector.<Face3D> = new Vector.<Face3D>;
		public var rot:Vector3D = new Vector3D;
		public var pos:Vector3D = new Vector3D;
		public var scale:Vector3D = new Vector3D(1,1,1);
		public function Node3D() 
		{
			
		}
		
		public static function fromDrawable(drawable:Drawable3D):Node3D {
			var node:Node3D = new Node3D;
			node.fs.push(
				createFace(
					drawable.pos?drawable.pos.data:null,
					drawable.uv?drawable.uv.data:null,
					drawable.norm?drawable.norm.data:null,
					drawable.index?drawable.index.data:null
				)
			);
			return node;
		}
		
		public static function createFace(vs:Vector.<Number>,uv:Vector.<Number>,norm:Vector.<Number>,ins:Vector.<uint>):Face3D {
			var face:Face3D = new Face3D;
			for (var i:int = 0; i < vs.length; i += 3 ) {
				face.vs.push(new V3D(vs[i],vs[i+1],vs[i+2]));
				if(norm){
					var normi:int = (i % (norm.length/3))*3;
					face.norm.push(new V3D(norm[normi], norm[normi + 1], norm[normi + 2]));
				}
			}
			if(uv)
			for (i = 0; i < uv.length; i += 2 ) {
				face.uv.push(new V3D(uv[i],uv[i+1]));
			}
			face.ins = Vector.<int>(ins);
			return face;
		}
		
	}

}