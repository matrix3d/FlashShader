package gl3d.parser 
{
	import flash.utils.getTimer;
	import gl3d.core.Drawable3D;
	import gl3d.core.IndexBufferSet;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.core.VertexBufferSet;
	import gl3d.meshs.Meshs;
	/**
	 * ...
	 * @author lizhi
	 */
	public class OBJParser 
	{
		private var decoder:OBJDecoder;
		public var target:Node3D = new Node3D;
		private var hash:int = 0;
		private var alwaysSmoothing:Boolean;
		private var mtldecode:MTLDecoder;
		public function OBJParser(txt:String,alwaysSmoothing:Boolean=false,mtltxt:String=null,basePath:String="") 
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
						var drawable:Drawable3D = new Drawable3D;
						drawable.index = new IndexBufferSet(new <uint>[]);
						drawable.pos = new VertexBufferSet(new <Number>[],3);
						drawable.uv = new VertexBufferSet(new <Number>[],2);
						node.drawable = drawable;
						node.material = new Material;
						if (mtldecode&&g.mtl) {
							var mtl:Array = mtldecode.getmtl(g.mtl);
							if (mtl&&mtl[3]) {
								node.material.color[0] = mtl[3][0];
								node.material.color[1] = mtl[3][1];
								node.material.color[2] = mtl[3][2];
							}
						}
						
						for each(var f:Array in g.f) {
							for (var i:int = 2, len:int = f.length; i < len ; i++ ) {
								addVertex(drawable,f[0],g.s);
								addVertex(drawable,f[i-1],g.s);
								addVertex(drawable,f[i],g.s);
							}
						}
					}
				}
			}
			trace("obj parser time: " + (getTimer() - t) + " ms");
		}
		private function addVertex(drawable:Drawable3D,f:Array,smooting:Boolean):void 
		{
			var v:int = f[0];
			var vt:int = f[1];
			var vn:int = f[2];
			drawable.addVertex([decoder.vs[v * 3], decoder.vs[v * 3 + 1], -decoder.vs[v * 3 + 2]], [decoder.vts[vt*3], 1-decoder.vts[vt*3+1]], -1,(alwaysSmoothing||smooting)?"":hash + "");
			hash++;
		}
	}
}