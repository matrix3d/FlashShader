package gl3d.shaders 
{
	import as3Shader.AS3Shader;
	import gl3d.core.shaders.GLAS3Shader;
	import gl3d.core.Material;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TerrainPhongGLShader extends PhongGLShader
	{
		
		public function TerrainPhongGLShader() 
		{
			
		}
		
		override public function getFragmentShader(material:Material):GLAS3Shader {
			return new TerrainPhongFragmentShader(material,vs as PhongVertexShader);
		}
	}

}