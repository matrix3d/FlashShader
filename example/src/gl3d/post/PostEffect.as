package gl3d.post 
{
	import gl3d.core.Material;
	import gl3d.meshs.Meshs;
	import gl3d.core.Node3D;
	import gl3d.core.shaders.GLShader;
	import gl3d.shaders.posts.PostGLShader;
	import gl3d.core.TextureSet;
	import gl3d.util.Utils;
	import gl3d.core.View3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class PostEffect 
	{
		public static var node:Node3D;
		private var _material:Material;
		private var numTexture:int;
		public var shader:GLShader;
		public function PostEffect(shader:GLShader=null,numTexture:int=1) 
		{
			this.numTexture = numTexture;
			this.shader = shader;
			if (node==null) {
				node = new Node3D;
				var hw:Number = 1;
				var hh:Number = 1;
				var hd:Number = 0;
				node.drawable=Meshs.createDrawable(
					Vector.<uint>([
						0, 2, 1, 0, 3, 2
						]),
					Vector.<Number>([
						hw, hh, hd, hw, -hh, hd, -hw, -hh, hd, -hw, hh, hd
					]),
					Vector.<Number>([
						1, 0, 1, 1, 0, 1, 0, 0
					]),
					Vector.<Number>([
						0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1
					])
				);
			}
		}
		
		public function get material():Material {
			if (_material==null) {
				_material = new Material();
				_material.shader = shader; 
			}
			return _material;
		}
		
		public function update(view3D:View3D,isEnd:Boolean):void 
		{
			if (numTexture == 1) material.diffTexture = view3D.postRTTs[0];
			else if (numTexture == 0) material.diffTexture = null;
			else throw "post texture num error";
			node.material = material;
			if (isEnd) {
				view3D.renderer.gl3d.setRenderToBackBuffer();
			}else {
				view3D.renderer.gl3d.setRenderToTexture(view3D.postRTTs[1].texture,true);
			}
			view3D.renderer.gl3d.clear();
			node.update(view3D);
		}
		
	}

}