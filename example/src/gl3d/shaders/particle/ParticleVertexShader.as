package gl3d.shaders.particle 
{
	import as3Shader.AS3Shader;
	import as3Shader.Var;
	/**
	 * ...
	 * @author lizhi
	 */
	public class ParticleVertexShader extends AS3Shader
	{
		
		public function ParticleVertexShader() 
		{
			
		}
		
		override public function build():void {
			var model:Var = C();
			var view:Var = C(4);
			var perspective:Var = C(8,4);
			var time:Var = mov(C(12));
			var pos:Var = mov(VA());
			var uv:Var = VA(1);
			var random:Var = VA(2);
			var sphereRandom:Var = VA(3);
			
			mov(uv, V());
			
			var time1:Var = frc(add(mul(100,random.x),mul(time.x, 1 / 10000)));//0-1;
			var negtime1:Var = sub(1, time1);
			
			add(pos.xyz, mul2([3,time1.x,sphereRandom]).xyz,pos.xyz);
			
			//var size:Var =mul(negtime1, .2);
			var size:Number = .2;
			var worldPos:Var = m44(pos, model);
			var viewPos:Var = m44(worldPos, view);
			add(viewPos.xy, mul(sub(uv, .5), size).xy, viewPos.xy);
			op = m44(viewPos, perspective);
			
			//var color:Var = mov(random);
			//mul(color,negtime1, V(1));
			mov([1, 1, 1, 1], V(1));
		}
	}

}