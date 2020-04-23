package gl3d.shaders 
{
	import flash.display3D.Context3DProgramType;
	import gl3d.core.shaders.GLAS3Shader;
	/**
	 * ...
	 * @author lizhi
	 */
	public class LineVertexShader extends GLAS3Shader
	{
		
		public function LineVertexShader() 
		{
			super(Context3DProgramType.VERTEX);
			var model:Var = uniformModel();
			var view:Var = uniformView();
			var perspective:Var = uniformPerspective();
			var pos:Var = buffPos()//VA();
			var uv:Var = buffUV()//VA(1);
			var lightMapUV:Var = buffUV2()//VA(2);
			var worldPos:Var = m44(pos, model);
			var viewPos:Var = m44(worldPos, view);
			m44(viewPos, perspective, op);
			mov(uv, V(0));
			mov(lightMapUV, V(1));
		}
		
	}

}