package gl3d.shaders.particle 
{
	import flShader.FlShader;
	import flShader.Var;
	/**
	 * ...
	 * @author lizhi
	 */
	public class ParticleVertexShader extends FlShader
	{
		
		public function ParticleVertexShader() 
		{
			
		}
		override public function build():void {
			var model:Var = C();
			var view:Var = C(4);
			var perspective:Var = C(8);
			var pos:Var = VA();
			var uv:Var = VA(2);
			var random:Var = VA(3);
			var worldPos:Var = m44(pos, model);
			var viewPos:Var = m44(worldPos, view);
			m44(viewPos, perspective, op);
		}
	}

}