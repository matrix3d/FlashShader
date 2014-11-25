package gl3d.shaders 
{
	import flShader.FlShader;
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
		
		override public function getFragmentShader(material:Material):FlShader {
			return new TerrainPhongFragmentShader(material);
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