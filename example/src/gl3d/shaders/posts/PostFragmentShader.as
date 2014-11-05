package gl3d.shaders.posts 
{
	import flash.display3D.Context3DProgramType;
	import flShader.FlShader;
	/**
	 * ...
	 * @author lizhi
	 */
	public class PostFragmentShader extends FlShader
	{
		
		public function PostFragmentShader() 
		{
			super(Context3DProgramType.FRAGMENT);
			tex(V(), FS(), oc);
		}
		
	}

}