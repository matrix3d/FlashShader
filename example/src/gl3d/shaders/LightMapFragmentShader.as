package gl3d.shaders 
{
	import flash.display3D.Context3DProgramType;
	import as3Shader.AS3Shader;
	import as3Shader.Var;
	import gl3d.core.Material;
	import gl3d.core.shaders.GLAS3Shader;
	/**
	 * ...
	 * @author lizhi
	 */
	public class LightMapFragmentShader extends GLAS3Shader
	{
		
		public function LightMapFragmentShader(material:Material) 
		{
			super(Context3DProgramType.FRAGMENT);
			var t:Var = tex(V(), samplerDiff(), null, material.diffTexture.flags);
			var l:Var = tex(V(1), samplerLightmap(), null, material.lightmapTexture.flags);
			mul(t.xyz, l.xyz, t.xyz);
			oc = t;
		}
		
	}

}