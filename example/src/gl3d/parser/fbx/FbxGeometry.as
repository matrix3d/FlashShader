package gl3d.parser.fbx{
	import flash.geom.Vector3D;
	import gl3d.core.Drawable3D;

	public class FbxGeometry {

		private var root : Object;
		private var vertices:Array;
		private var polygons:Array;
		public var drawable:Drawable3D;
		public var nodes:Array = [];
		public function FbxGeometry( root:Object,vertices:Array=null,polygons:Array=null) {
			this.polygons = polygons;
			this.vertices = vertices;
			this.root = root;
		}

		public function getRoot() :Object{
			return root;
		}

		public function getVertices():Array {
			return vertices||FbxTools.getFloats(FbxTools.get(root,"Vertices"));
		}

		public function getPolygons():Array {
			return polygons||FbxTools.getInts(FbxTools.get(root, "PolygonVertexIndex"));
		}

		public function getMaterials():Array {
			var mats:Array = FbxTools.get(root,"LayerElementMaterial",true);
			return mats == null ? null : FbxTools.getInts(FbxTools.get(mats,"Materials"));
		}

		public function getMaterialByTriangle():Array {
			var mids:Array = getMaterials();
			var pos:int = 0;
			var count:int = 0;
			var mats:Array = [];
			for each(var p:int in getPolygons() ) {
				count++;
				if( p >= 0 )
					continue;
				var m:int = mids[pos++];
				for (var i:int = 0; i < count - 2;i++ )
					mats.push(m);
				count = 0;
			}
			return mats;
		}

		/**
			Decode polygon informations into triangle indexes and vertices indexes.
			Returns vidx, which is the list of vertices indexes and iout which is the index buffer for the full vertex model
		**/
		public function getIndexes():Array {
			var prev:int = 0;
			var p:Array = getPolygons();
			var out:Array = [];
			for (var i:int = 0; i < p.length;i++ ){
				var index:int = p[i];
				p[i] = index
				if (index < 0){
					var start:int = prev;
					var total:int = i - prev + 1;
					prev = i + 1
					p[i] ^= -1
					for (var j:int = 2; j < total;j++ ) {
						out.push(p[start],p[start+j],p[start+j-1]);
					}
				}
			}
			return out;
		}

		public function getNormals():Array {
			var nrm:Array = FbxTools.getFloats(FbxTools.get(root,"LayerElementNormal.Normals"));
			// if by-vertice (Maya in some cases, unless maybe "Split per-Vertex Normals" is checked)
			// let's reindex based on polygon indexes
			if( FbxTools.get(root,"LayerElementNormal.MappingInformationType").props[0].toString() == "ByVertice" ) {
				var nout:Array = [];
				for each(var i:int in getPolygons() ) {
					var vid:int = i;
					if( vid < 0 ) vid = -vid - 1;
					nout.push(nrm[vid * 3]);
					nout.push(nrm[vid * 3 + 1]);
					nout.push(nrm[vid * 3 + 2]);
				}
				nrm = nout;
			}
			return nrm;
		}

		public function getColors():Object {
			var color:Array = FbxTools.get(root,"LayerElementColor",true);
			return color == null ? null : { values : FbxTools.getFloats(FbxTools.get(color,"Colors")), index : FbxTools.getInts(FbxTools.get(color,"ColorIndex")) };
		}

		public function getUVs():Array {
			var uvs:Array = [];
			/*for each(var v:Object in FbxTools.getAll(root,"LayerElementUV") ) {
				var index = v.get("UVIndex", true);
				var values = v.get("UV").getFloats();
				var index = if( index == null ) {
					// ByVertice/Direct (Maya sometimes...)
					[for( i in getPolygons() ) if( i < 0 ) -i - 1 else i];
				} else index.getInts();
				uvs.push({ values : values, index : index });
			}*/
			return uvs;
		}

	}
}