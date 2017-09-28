package gl3d.parser.lol.skl 
{
	import flash.geom.Matrix3D;
	import flash.utils.ByteArray;
	import gl3d.core.Drawable;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.core.math.Quaternion;
	import gl3d.meshs.Meshs;
	/**
	 * ...
	 * @author lizhi
	 */
	public class LolSklParser 
	{
		public var root:Node3D = new Node3D;
		public function LolSklParser(b:ByteArray) 
		{
			var skld:LolSklDecoder = new LolSklDecoder(b);
			trace(skld);
			
			var id2node:Object = {};
			var shape:Drawable = Meshs.cube(5, 5, 5);
			for each(var ob:Object in skld.skl.bones){
				trace(ob.parent);
				var bnode:Node3D = new Node3D;
				bnode.material = new Material;
				bnode.drawable = shape
				var q:Quaternion = new Quaternion(ob.quaternion.x, ob.quaternion.y, ob.quaternion.z, ob.quaternion.w);
				var m:Matrix3D = q.toMatrix();
				m.appendScale(ob.scale.x, ob.scale.y, ob.scale.z);
				m.appendTranslation(ob.position.x, ob.position.y, ob.position.z);
				bnode.matrix = m;
				id2node[ob.id] = bnode;
			}
			for each(ob in skld.skl.bones){
				trace(ob.parent);
				bnode = id2node[ob.id];
				if (ob.parent==-1){
					var pnode:Node3D = root;
				}else{
					pnode = id2node[ob.parent];
				}
				if (pnode){
					pnode.addChild(bnode);
				}
			}
			
		}
		
	}

}