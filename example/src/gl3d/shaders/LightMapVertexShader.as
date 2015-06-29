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
	public class LightMapVertexShader extends GLAS3Shader
	{
		
		public function LightMapVertexShader() 
		{
			super(Context3DProgramType.VERTEX);
			var model:Var = C();
			var view:Var = C(4);
			var perspective:Var = C(8);
			var pos:Var = VA();
			var uv:Var = VA(1);
			var lightMapUV:Var = VA(2);
			var worldPos:Var = m44(pos, model);
			var viewPos:Var = m44(worldPos, view);
			m44(viewPos, perspective, op);
			mov(uv, V(0));
			mov(lightMapUV, V(1));
		}
		
	}

}