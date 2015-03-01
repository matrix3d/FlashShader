package gl3d.core 
{
	import flash.display3D.Context3DCompareMode;
	import gl3d.meshs.Meshs;
	import gl3d.shaders.posts.PostGLShader;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Quat extends Node3D
	{
		
		public function Quat() 
		{
			var hw:Number = 1;
			var hh:Number = 1;
			var hd:Number = 0;
			drawable=Meshs.createDrawable(
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
			
			material = new Material;
			material.passCompareMode = Context3DCompareMode.ALWAYS;
			material.shader = new PostGLShader;
		}
	}

}