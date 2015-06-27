package gl3d.shaders 
{
	import as3Shader.AS3Shader;
	import flash.display3D.Context3DProgramType;
	/**
	 * ...
	 * @author lizhi
	 */
	public class SkyBoxFragmentShader extends AS3Shader
	{
		public function SkyBoxFragmentShader(vs:SkyBoxVertexShader) 
		{
			super(Context3DProgramType.FRAGMENT);
			tex(vs.dir, FS(), oc,["cube","miplinear","anisotropic16x"]);
		}
		
	}

}