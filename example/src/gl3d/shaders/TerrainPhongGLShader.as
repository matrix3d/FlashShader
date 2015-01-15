package gl3d.shaders 
{
	import as3Shader.AS3Shader;
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
		
		override public function getFragmentShader(material:Material):AS3Shader {
			return new TerrainPhongFragmentShader(material,vs as PhongVertexShader);
		}
		
		override public function preUpdate(material:Material):void {
			super.preUpdate(material);
			textureSets[1] = material.textureSets[1];
			textureSets[2] = material.textureSets[2];
			textureSets[3] = material.textureSets[3];
			textureSets[4] = material.textureSets[4];
		}
		
	}

}