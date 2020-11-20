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
							var mtl:Object = mtldecode.getmtl(g.mtl);
							if(mtl){
								if (mtl.Kd) {
									node.material.color.x = mtl.Kd[0];
									node.material.color.y = mtl.Kd[1];
									node.material.color.z = mtl.Kd[2];
								}
								if (mtl.Ka) {
									node.material.ambient.x = mtl.Ka[0];
									node.material.ambient.y = mtl.Ka[1];
									node.material.ambient.z = mtl.Ka[2];
								}
								if (mtl.map_Kd) {
									new MatLoadMsg(mtl.map_Kd,null,node.material);
								}
							}
						}
						var newPos:Array= drawable.source.pos = [];
						var oldPos:Array = decoder.vs;
						for (var i:int = 0, len:int = oldPos.length;i<len; i += 3) {
							newPos.push(oldPos[i]);
							newPos.push(oldPos[i+1]);
							newPos.push(-oldPos[i+2]);
						}
						
						var newUV:Array= drawable.source.uv = [];
						var oldUV:Array = decoder.vts;
						for (var i:int = 0, len:int = oldUV.length;i<len; i += 2) {
							newUV.push(oldUV[i]);
							newUV.push(-oldUV[i+1]);
						}
						
						drawable.source.index = [];
						var haveUV:Boolean = false;
						if (g.f && g.f[0]  &&g.f[0][0]&&g.f[0][0][0]!=null) {
							var uvI:Array= drawable.source.uvIndex = [];
							haveUV = true;
						}
						for each(var f:Array in g.f) {
							var face:Array = [];
							drawable.source.index.push(face);
							if(haveUV){
								var faceUV:Array = [];
								uvI.push(faceUV);
							}
							for (i = 0, len = f.length; i < len;i++ ) {
								face.push(f[i][0]);
								if (haveUV) {
									faceUV.push(f[i][1]);
								}
							}
						}
						Drawable.optimizeSource(drawable.source);
					}
				}
			}
			trace("obj parser time: " + (getTimer() - t) + " ms");
		}
	}
}