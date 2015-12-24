package gl3d.parser.fbx{
	import flash.geom.Vector3D;
	import gl3d.core.Drawable;

	public class FbxGeometry {

		private var root : Object;
		public var vertices:Array;
		private var polygons:Array;
		public var drawables:Array;
		public var nodes:Array = [];
		public var uv:Array;
		public var objs:Array = [];
		public function FbxGeometry( root:Object,vertices:Array=null,polygons:Array=null) {
			this.root = root;
			this.polygons=polygons = polygons||FbxTools.getInts(FbxTools.get(root, "PolygonVertexIndex"));
			this.vertices=vertices = vertices||FbxTools.getFloats(FbxTools.get(root, "Vertices"));
			for each(var v:Object in FbxTools.getAll(root,"LayerElementUV") ) {
				var uvi:Array = FbxTools.getInts(FbxTools.get(v,"UVIndex", true));
				uv = FbxTools.getFloats(FbxTools.get(v, "UV"));
				for (var k:int = 0; k < uv.length; k += 2 ) {
					uv[k+1] = 1 - uv[k+1];
				}
				break;
			}
			
			var matOs:Object = FbxTools.get(root, "LayerElementMaterial", true);
			if (matOs!=null) {
				var mats:Array = FbxTools.getInts(FbxTools.get(matOs, "Materials"));
			}
			/*index = [];
			if(uvi){
				uvindex = [];
			}*/
			var prev:int = 0;
			var p:Array = polygons;
			
			var indexA:Array;
			var uvindex:Array;
			var tcounter:int = 0;
			for (var i:int = 0; i < p.length;i++ ){
				var index:int = p[i];
				if (index < 0){
					var start:int = prev;
					var total:int = i - prev + 1;
					if (mats&&tcounter<mats.length) {
						var mid:int = mats[tcounter];
					}else {
						mid = 0;
					}
					var obj:Array = objs[mid];
					if (obj==null) {
						obj = objs[mid] = [[]];
						if (uvi) {
							obj[1] = [];
						}
					}
					indexA = obj[0];
					uvindex = obj[1];
					tcounter += total - 2;
					prev = i + 1;
					p[i] ^= -1;
					var f:Array = [];
					indexA.push(f);
					if(uvi){
						var uvf:Array = [];
						uvindex.push(uvf);
					}
					for (var j:int = 0; j < total;j++ ) {
						f.push(p[start + j]);
						if(uvi){
							uvf.push(uvi[start + j]);
						}
					}
				}
			}
		}

		/*public function getRoot() :Object{
			return root;
		}*/

		/*public function getMaterials():Array {
			var mats:Array = FbxTools.get(root,"LayerElementMaterial",true);
			return mats == null ? null : FbxTools.getInts(FbxTools.get(mats,"Materials"));
		}

		public function getMaterialByTriangle():Array {
			var mids:Array = getMaterials();
			var pos:int = 0;
			var count:int = 0;
			var mats:Array = [];
			for each(var p:int in polygons ) {
				count++;
				if( p >= 0 )
					continue;
				var m:int = mids[pos++];
				for (var i:int = 0; i < count - 2;i++ )
					mats.push(m);
				count = 0;
			}
			return mats;
		}*/

		/*public function getNormals():Array {
			var nrm:Array = FbxTools.getFloats(FbxTools.get(root,"LayerElementNormal.Normals"));
			// if by-vertice (Maya in some cases, unless maybe "Split per-Vertex Normals" is checked)
			// let's reindex based on polygon indexes
			if( FbxTools.get(root,"LayerElementNormal.MappingInformationType").props[0].toString() == "ByVertice" ) {
				var nout:Array = [];
				for each(var i:int in polygons ) {
					var vid:int = i;
					if( vid < 0 ) vid = -vid - 1;
					nout.push(nrm[vid * 3]);
					nout.push(nrm[vid * 3 + 1]);
					nout.push(nrm[vid * 3 + 2]);
				}
				nrm = nout;
			}
			return nrm;
		}*/

		/*public function getColors():Object {
			var color:Array = FbxTools.get(root,"LayerElementColor",true);
			return color == null ? null : { values : FbxTools.getFloats(FbxTools.get(color,"Colors")), index : FbxTools.getInts(FbxTools.get(color,"ColorIndex")) };
		}*/
	}
}