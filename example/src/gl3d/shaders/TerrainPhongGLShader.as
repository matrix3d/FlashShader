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
		
		override public function preUpdate(material:Material):void {
			super.preUpdate(material);
			textureSets[0] = material.diffTexture
			textureSets[1] = material.terrainTextureSets[0];
			textureSets[2] = material.terrainTextureSets[1];
			textureSets[3] = material.terrainTextureSets[2];
			textureSets[4] = material.terrainTextureSets[3];
		}
		
	}

}