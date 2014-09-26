package flash3d {
	/**
	 * ...
	 * @author lizhi
	 */
	public class Meshs 
	{
		
		public function Meshs() 
		{
			
		}
		
		public static function sphere(w:Number = 4, h:Number = 2):Node3D {
			var node:Node3D = new Node3D;
			var vs:Array = [0,-1,0];
			var ins:Array = [];
			for (var i:int = 0; i < h - 1; i++ ) {
				var rot:Number = Math.PI / h * (i+1) -Math.PI/2;
				var sin:Number = Math.sin(rot);
				var cos:Number = Math.cos(rot);
				for (var j:int = 0; j < w;j++ ) {
					rot = Math.PI * 2 / w*j;
					vs.push(Math.cos(rot)*cos, sin, Math.sin(rot)*cos);
					var ni:int = vs.length/3 - 1;
					if (i==0) {
						if (j != 0) {
							ins.push(ni, ni - 1, 0);
						}else {
							ins.push(ni, ni + w - 1, 0);
						}
					}
					if (i > 0) {
						if (j != 0) {
							ins.push(ni, ni - 1, ni - w, ni - 1, ni - w - 1, ni - w);
						}
						else {
							ins.push(ni, ni + w - 1, ni - w, ni + w - 1, ni - 1, ni - w);
						}
					}
					if (i==h-2) {
						if (j != 0) {
							ins.push(ni, ni - 1, w*(h-1)+1);
						}else {
							ins.push(ni, ni + w - 1, w*(h-1)+1);
						}
					}
				}
			}
			vs.push(0,1,0);
			node.fs.push(createFace(vs, null, null, ins));
			return node;
		}
		
		public static function cube():Node3D {
			var node:Node3D = new Node3D;
			var ins:Array = [0, 1, 2, 0, 2, 3];
			var uv:Array = [1,1,1,0,0,0,0,1];
			node.fs.push(
				createFace([1,1,1,1,-1,1,-1,-1,1, -1, 1, 1],uv,[0,0,1],ins)
				,createFace([1,1,-1,1,-1,-1,-1,-1,-1,-1, 1, -1],uv,[0,0,-1],ins)
				,createFace([1,1,1,1,1,-1,-1,1,-1,-1, 1, 1],uv,[0,1,0],ins)
				,createFace([1,-1,1,1,-1,-1,-1,-1,-1,-1, -1, 1],uv,[0,-1,0],ins)
				,createFace([1,1,1,1,1,-1,1,-1,-1,1, -1, 1],uv,[1,0,0],ins)
				,createFace([-1,1,1,-1,1,-1,-1,-1,-1, -1, -1, 1],uv,[-1,0,0],ins)
			);
			return node;
		}
		
		public static function star():Node3D {
			var node:Node3D = new Node3D;
			var ins:Array = [0, 1, 2, 0, 2, 3];
			var uv:Array = [1, 0, 0, 0, 0, 1, 1, 1];
			var normV:V3D = new V3D(1);
			var norm:Array = [normV.x,normV.y,normV.z];
			var face:Face3D = createFace([
			0, 1, 1,
			0, 1, -1,
			0, -1, -1,
			0, -1, 1],uv,norm,ins)
			node.fs.push(face);
			for (var i:int = 1; i < 3;i++ ) {
				var rot:Number = Math.PI * 2 / 3 * i;
				normV.rot(0, rot, 0);
				norm = [normV.x,normV.y,normV.z];
				var f:Face3D = new Face3D;
				node.fs.push(f);
				f.ins = face.ins;
				f.uv = face.uv;
				for (var j:int = 0; j < face.vs.length;j++ ) {
					var v:V3D = face.vs[j].clone();
					v.rot(0, rot, 0);
					f.vs[j] = v;
					var normi:int = (i % (norm.length/3))*3;
					f.norm.push(new V3D(norm[normi],norm[normi+1],norm[normi+2]));
				}
			}
			return node;
		}
		
		public static function createFace(vs:Array,uv:Array,norm:Array,ins:Array):Face3D {
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