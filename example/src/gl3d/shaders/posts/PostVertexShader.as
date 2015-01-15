package gl3d.shaders.posts 
{
	import as3Shader.AS3Shader;
	/**
	 * ...
	 * @author lizhi
	 */
	public class PostVertexShader extends AS3Shader
	{
		
		public function PostVertexShader() 
		{
			mov(VA(), op);
			mov(VA(1), V());
		}
		
	}

}