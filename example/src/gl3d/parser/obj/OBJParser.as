package gl3d.parser.obj 
{
	import flash.utils.getTimer;
	import gl3d.core.Drawable;
	import gl3d.core.DrawableSource;
	import gl3d.core.IndexBufferSet;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.core.VertexBufferSet;
	import gl3d.meshs.Meshs;
	import gl3d.parser.obj.MTLDecoder;
	import gl3d.parser.obj.OBJDecoder;
	import gl3d.util.MatLoadMsg;
	/**
	 * ...
	 * @author lizhi
	 */
	public class OBJParser 
	{
		private var decoder:OBJDecoder;
		public var target:Node3D = new Node3D;
		private var alwaysSmoothing:Boolean;
		private var mtldecode:MTLDecoder;
		private var oldindex2newindex:Object;
		private var oldindex2newindexUV:Object;
		private var maxIndex:int;
		private var maxIndexUV:int;
		private var face:Array;
		private var faceUV:Array;
		public function OBJParser(txt:String,alwaysSmoothing:Boolean=false,mtltxt:String=null) 
		{
			this.alwaysSmoothing = alwaysSmoothing;
			var t:int = getTimer();
			decoder = new OBJDecoder(txt);
			trace("obj decode time: " + (getTimer() - t) + " ms");
			if (mtltxt) {
				mtldecode = new MTLDecoder(mtltxt);
			}
			t = getTimer();
			for each(var o:Object in decoder.objs) {
				for each(var g:Object in o.g) {
					if(g.f.length){
						var node:Node3D = new Node3D;
						target.addChild(node);
						var drawable:Drawable = new Drawable;
						drawable.smooting = alwaysSmoothing || g.s;
						drawable.source = new DrawableSource;
						node.drawable = drawable;
						node.material = new Material;
						if (mtldecode&&g.mtl) {
							var mtl:Array = mtldecode.getmtl(g.mtl);
							if (mtl&&mtl[3]) {
								node.material.color.x = mtl[3][0];
								node.material.color.y = mtl[3][1];
								node.material.color.z = mtl[3][2];
							}
							if (mtl&&mtl[1]) {
								new MatLoadMsg(mtl[1],node.material);
							}
						}
						oldindex2newindex = { };
						oldindex2newindexUV = { };
						maxIndex = 0;
						maxIndexUV = 0;
						for each(var f:Array in g.f) {
							face = null;
							faceUV = null;
							for (var i:int = 0, len:int = f.length; i < len;i++ ) {
								addVertex(drawable, f[i]);
							}
						}
					}
				}
			}
			trace("obj parser time: " + (getTimer() - t) + " ms");
		}
		
		private function addVertex(drawable:Drawable,f:Array):void 
		{
			
			var v:Object = f[0];
			var vt:Object = f[1];
			var vn:Object = f[2];
			var source:DrawableSource = drawable.source;
			if (v != null) {
				if (source.pos==null) {
					source.pos = [];
					source.index = [];
				}
				if (face==null) {
					face = [];
					source.index.push(face);
				}
				var newindex:Object = oldindex2newindex[v];
				if (newindex == null) {
					var vi:int = v as int;
					source.pos.push(decoder.vs[vi * 3], decoder.vs[vi * 3 + 1], -decoder.vs[vi * 3 + 2]);
					newindex = maxIndex++;
					oldindex2newindex[v] = newindex;
				}
				face.push(newindex);
			}
			if (vt != null) {
				if (source.uv==null) {
					source.uv = [];
					source.uvIndex = [];
				}
				if (faceUV==null) {
					faceUV = [];
					source.uvIndex.push(faceUV);
				}
				var newindexUV:Object = oldindex2newindexUV[vt];
				if (newindexUV == null) {
					var vti:int = vt as int;
					source.uv.push(decoder.vts[vti * 3], decoder.vts[vti * 3 + 1]);
					newindexUV = maxIndexUV++;
					oldindex2newindexUV[v] = newindexUV;
				}
				faceUV.push(newindexUV);
			}
		}
	}
}