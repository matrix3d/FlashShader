package gl3d.shaders.posts 
{
	import as3Shader.Var;
	import flash.display3D.Context3DProgramType;
	import gl3d.core.shaders.GLAS3Shader;
	/**
	 * ...
	 * @author lizhi
	 */
	public class RedScreenShader extends GLAS3Shader
	{
		
		public function RedScreenShader() 
		{
			super(Context3DProgramType.FRAGMENT);
			
			var uv:Var = V();
			var cen:Array = [.5, .5];
			var dist:Var = sub(uv, cen);
			dist = length(dist); //mul(div(dist.y,length(dist)),length(dist));
			oc = pow(dist,1);
			
		}
		
	}

}