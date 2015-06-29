package gl3d.shaders.posts 
{
	import flash.display3D.Context3DProgramType;
	import as3Shader.AS3Shader;
	import gl3d.core.shaders.GLAS3Shader;
	/**
	 * ...
	 * @author lizhi
	 */
	public class PostFragmentShader extends GLAS3Shader
	{
		
		public function PostFragmentShader() 
		{
			super(Context3DProgramType.FRAGMENT);
			tex(V(), FS(), oc);
		}
		
	}

}