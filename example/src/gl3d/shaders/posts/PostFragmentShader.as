package gl3d.shaders.posts 
{
	import flash.display3D.Context3DProgramType;
	import as3Shader.AS3Shader;
	/**
	 * ...
	 * @author lizhi
	 */
	public class PostFragmentShader extends AS3Shader
	{
		
		public function PostFragmentShader() 
		{
			super(Context3DProgramType.FRAGMENT);
			tex(V(), FS(), oc);
		}
		
	}

}