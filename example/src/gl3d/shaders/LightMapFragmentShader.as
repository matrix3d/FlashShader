package gl3d.shaders 
{
	import flash.display3D.Context3DProgramType;
	import as3Shader.AS3Shader;
	import as3Shader.Var;
	import gl3d.core.shaders.GLAS3Shader;
	/**
	 * ...
	 * @author lizhi
	 */
	public class LightMapFragmentShader extends GLAS3Shader
	{
		
		public function LightMapFragmentShader() 
		{
			super(Context3DProgramType.FRAGMENT);
			var t:Var = tex(V(), samplerDiff(), null, ["repeat", "anisotropic16x","miplinear"]);
			var l:Var = tex(V(1), samplerLightmap(), null, ["repeat", "anisotropic16x","miplinear"]);
			mul(t.xyz, l.xyz, t.xyz);
			oc = t;
		}
		
	}

}