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
			var perspective:Var = C(8,4);
			var time:Var = mov(C(12));
			var pos:Var = VA();
			var uv:Var = VA(1);
			var random:Var = VA(2);
			mov(uv, V());
			
			/*random 0 - 1
			random * 2 0 - 2
			(time % 1000) / 1000*/
			var timeRandom:Boolean = true;
			if (timeRandom) {
				time=add(time,mul(20000,random))
			}
			
			pos = add(pos, mul2([random,2,sub(modfrc(time,10000),.5)]).xxx);
			var worldPos:Var = m44(pos, model);
			var viewPos:Var = m44(worldPos, view);
			m44(viewPos, perspective, op);
		}
	}

}