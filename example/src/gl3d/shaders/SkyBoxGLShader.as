package gl3d.shaders 
{
	import flash.display3D.Context3DProgramType;
	import gl3d.core.Camera3D;
	import gl3d.core.renders.GL;
	import gl3d.core.shaders.GLAS3Shader;
	import gl3d.core.shaders.GLShader;
	import gl3d.core.Material;
	import as3Shader.AS3Shader;
	import gl3d.core.Node3D;
	import gl3d.core.View3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class SkyBoxGLShader extends GLShader
	{
		
		public function SkyBoxGLShader() 
		{
			
		}
		override public function getVertexShader(material:Material):GLAS3Shader 
		{
			return new SkyBoxVertexShader;
		}
		
		override public function getFragmentShader(material:Material):GLAS3Shader 
		{
			return new SkyBoxFragmentShader(material,vs as SkyBoxVertexShader);
		}
		
	}

}