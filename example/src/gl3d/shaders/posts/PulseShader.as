package gl3d.shaders.posts 
{
	import flash.display3D.Context3DProgramType;
	import as3Shader.AS3Shader;
	import as3Shader.Var;
	/**
	 * ...
	 * @author lizhi
	 */
	public class PulseShader  extends AS3Shader
	{
		
		public function PulseShader() 
		{
			super(Context3DProgramType.FRAGMENT);
			var time:Var = div(C().x,mov(1000));
			var resolution:Var = mov(C().yz);
			var tex0:Var = FS();
			
			var halfres:Var = div(resolution, mov(2));
			var cPos:Var = mul(V(),resolution);
			sub(cPos.x, add2([mul2([.5, halfres.x, sin(div(time, 2))]), mul2([.3, halfres.x, cos(time)]), halfres.x]), cPos.x);
			sub(cPos.y, add2([mul2([.4, halfres.y, sin(div(time, 5))]), mul2([.3, halfres.y, cos(time)]), halfres.y]), cPos.y);
			var cLength:Var = length(cPos);
			var uv:Var = add(V(), div(mul(div(cPos, cLength), sin(sub(div(cLength, 30), mul(time, 10)))), 25));
			var col:Var= div(mul(tex(uv, tex0), 50), cLength);
			mov(1, col.w);
			mov(col, oc);
			/*
			uniform float time;
			uniform vec2 resolution;
			uniform vec4 mouse;
			uniform sampler2D tex0;

			void main(void)
			{
				vec2 halfres = resolution.xy/2.0;
				vec2 cPos = gl_FragCoord.xy;

				cPos.x -= 0.5*halfres.x*sin(time/2.0)+0.3*halfres.x*cos(time)+halfres.x;
				cPos.y -= 0.4*halfres.y*sin(time/5.0)+0.3*halfres.y*cos(time)+halfres.y;
				float cLength = length(cPos);

				vec2 uv = gl_FragCoord.xy/resolution.xy+(cPos/cLength)*sin(cLength/30.0-time*10.0)/25.0;
				vec3 col = texture2D(tex0,uv).xyz*50.0/cLength;

				gl_FragColor = vec4(col,1.0);
			}*/
		}
		
	}

}