package gl3d.parser.md5 
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import gl3d.core.skin.Joint;
	import gl3d.core.Material;
	import gl3d.core.math.Quaternion;
	import gl3d.core.Node3D;
	import gl3d.core.skin.Skin;
	import gl3d.core.skin.SkinAnimationCtrl;
	import gl3d.core.VertexBufferSet;
	import gl3d.meshs.Meshs;
	import gl3d.parser.md5.MD5MeshDecoder;
	import gl3d.util.Converter;
	/**
	 * ...
	 * @author lizhi
	 */
	public class MD5MeshParser 
	{
		public var skin:Skin;
		public var target:Node3D = new Node3D;
		public var jointRoot:Node3D;
		public var skinNodes:Vector.<Node3D> = new Vector.<Node3D>;
		public var animc:SkinAnimationCtrl;
		public function MD5MeshParser(txt:String) 
		{
			var converter:Converter=new Converter("ZtoY");
			var decoder:MD5MeshDecoder = new MD5MeshDecoder(txt);
			var jointQs:Array = [];
			if(decoder.joints.length)
			skin = new Skin;
			skin.maxWeight = decoder.maxWeight;
			for each(var joint:Array in decoder.joints) {
				var q:Quaternion = new Quaternion(joint[5], joint[6], joint[7]);
				q.computeW();
				q.tran = new Vector3D(joint[2], joint[3], joint[4]);
				jointQs.push(q);
				var matr:Matrix3D = q.toMatrix();
				
				var jnode:Joint = new Joint;
				jnode.type = "JOINT";
				//jnode.material = new Material;
				//jnode.drawable = Meshs.cube(.1, .1, .1);
				jnode.name = joint[0];
				skin.joints.push(jnode);
				if (joint[1]==-1) {
					jointRoot = jnode;
					target.addChild(jnode);
				}else {
					skin.joints[joint[1]].addChild(jnode);
				}
				
				matr.invert();
				jnode.invBindMatrix.copyFrom(converter.getConvertedMat4(matr));
				//skin.invBindMatrixs.push();
			}
			var vsCounter:int = 0;
			for each(var mesh:Object in decoder.meshs) {
				var node:Node3D = new Node3D;
				skinNodes.push(node);
				node.skin = skin;
				if (decoder.joints.length) {
					var js:Vector.<Number> = new Vector.<Number>;
					var ws:Vector.<Number> = new Vector.<Number>;
				}
				for (var i:int = 0, len:int = mesh.vs2.length; i < len;i++ ) {
					var vert:Array = mesh.vs2[i];
					if(vert!=null){
						var fvert:Vector3D = new Vector3D();
						for (var j:int = 0; j < vert[3];j++ ) {
							var weight:Array = mesh.weights[vert[2] + j];
							joint = decoder.joints[weight[0]];
							q = jointQs[weight[0]];
							var pvert:Vector3D=q.rotatePoint(new Vector3D(weight[2],weight[3],weight[4]));
							pvert=pvert.add(q.tran);
							pvert.scaleBy(weight[1]);
							fvert = fvert.add(pvert);
							js.push(weight[0]);
							ws.push(weight[1]);
						}
						for (; j < decoder.maxWeight;j++ ) {
							js.push(0);
							ws.push(0);
						}
						mesh.vs[i] = [vert[0], vert[1], fvert.x, fvert.y, fvert.z];
					}
				}
				var poss:Vector.<Number> = new Vector.<Number>;
				var uvs:Vector.<Number> = new Vector.<Number>;
				for (i = 0, len = mesh.vs.length; i < len;i++ ) {
					var v:Array = mesh.vs[i];
					poss.push(v[2], v[3], v[4]);
					uvs.push(v[0], v[1]);
				}
				var indexs:Vector.<uint> =new Vector.<uint>;
				for each(var ins:Array in mesh.ins) {
					indexs.push(ins[0]+vsCounter);
					indexs.push(ins[2]+vsCounter);
					indexs.push(ins[1]+vsCounter);
				}
				node.material = new Material;
				converter.convertedVec3s(poss);
				node.drawable = Meshs.createDrawable(indexs, poss, uvs, null);
				node.drawable.joint=new  VertexBufferSet(Vector.<Number>(js),decoder.maxWeight);
				node.drawable.weight=new  VertexBufferSet(Vector.<Number>(ws),decoder.maxWeight);
				target.addChild(node);
				//vsCounter += mesh.vs.length;
			}
		}
		
	}

}