package gl3d.shaders 
{
	import flash.display3D.Context3DProgramType;
	import as3Shader.AS3Shader;
	import as3Shader.Var;
	/**
	 * ...
	 * @author lizhi
	 */
	public class LightMapFragmentShader extends AS3Shader
	{
		
		public function LightMapFragmentShader() 
		{
			super(Context3DProgramType.FRAGMENT);
			var t:Var = tex(V(), FS(0), null, ["repeat", "linear"]);
			var l:Var = tex(V(1), FS(1), null, ["repeat", "linear"]);
			mul(t.xyz, l.xyz, t.xyz);
			oc = t;
		}
		
	}

}