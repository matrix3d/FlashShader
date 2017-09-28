package gl3d.parser.lol.skn 
{
	import flash.net.URLLoader;
	import flash.utils.ByteArray;
	import gl3d.core.Drawable;
	import gl3d.core.DrawableSource;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.core.VertexBufferSet;
	import gl3d.util.MatLoadMsg;
	/**
	 * ...
	 * @author lizhi
	 */
	public class LolSknParser 
	{
		public var root:Node3D = new Node3D;
		public function LolSknParser(b:ByteArray) 
		{
			var d:LolSknDecoder = new LolSknDecoder(b);
			root.drawable = new Drawable;
			root.material = new Material;
			new MatLoadMsg("../src/assets/lol/LOLJax/Armsmaster_Concept.jpg", null, root.material);
			var ds:DrawableSource = new DrawableSource;
			root.drawable.source = ds;
			ds.pos = d.skin.pos;
			ds.uv = d.skin.uv;
			//root.drawable.norm = new VertexBufferSet(Vector.<Number>(d.skin.normal), 3);
			
			ds.index = []
			for (var i:int = 0; i < d.skin.indices.length;i+=3 ){
				ds.index.push([d.skin.indices[i],d.skin.indices[i+2],d.skin.indices[i+1]]);
			}
			//ds.uvIndex = ds.index;
			trace(ds.index.length*3);
			trace(root.drawable.pos.data.length);
			trace(root.drawable.index.data.length);
			trace(1);
		}
		
	}

}