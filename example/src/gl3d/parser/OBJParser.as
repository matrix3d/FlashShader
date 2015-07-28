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
		public function OBJParser(txt:String,alwaysSmoothing:Boolean=false) 
		{
			this.alwaysSmoothing = alwaysSmoothing;
			var t:int = getTimer();
			decoder = new OBJDecoder(txt);
			trace("obj decode time: " + (getTimer() - t) + " ms");
			for each(var o:Object in decoder.objs) {
				var node:Node3D = new Node3D;
				target.addChild(node);
				var drawable:Drawable3D = new Drawable3D;
				drawable.index = new IndexBufferSet(new <uint>[]);
				drawable.pos = new VertexBufferSet(new <Number>[],3);
				drawable.uv = new VertexBufferSet(new <Number>[],2);
				node.drawable = drawable;
				node.material = new Material;
				//Meshs.createDrawable().addVertex
				for each(var g:Object in o.g) {
					for each(var f:Array in g.f) {
						for (var i:int = 2, len:int = f.length; i < len ; i++ ) {
							addVertex(drawable,f[0],g.s);
							addVertex(drawable,f[i],g.s);
							addVertex(drawable,f[i-1],g.s);
						}
					}
				}
			}
		}
		private function addVertex(drawable:Drawable3D,f:Array,smooting:Boolean):void 
		{
			var v:int = f[0];
			var vt:int = f[1];
			var vn:int = f[2];
			drawable.addVertex([decoder.vs[v * 3], decoder.vs[v * 3 + 1], decoder.vs[v * 3 + 2]], [0, 0], -1,(alwaysSmoothing||smooting)?"":hash + "");
			hash++;
		}
	}
}