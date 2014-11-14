package gl3d.shaders.posts 
{
	import flash.display3D.Context3DProgramType;
	import flShader.FlShader;
	import flShader.Var;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TileableWaterCausticShader extends FlShader
	{
		
		public function TileableWaterCausticShader() 
		{
			super(Context3DProgramType.FRAGMENT);
			var TAU:Number= 6.28318530718
			var MAX_ITER:Number = 5;
			var SEE_TILING:Boolean = false;
			var iResolution:Var = mov(C().yz);
			var UV:Var = mov(V());
			sub(1, UV.y, UV.y);
			var time:Var = add(mul(div(C().x, mov(1000)) , .5), 23.0).x;
			var sp:Var = UV;
			if (SEE_TILING) {	
				var p:Var =sub( mod(mul2([sp ,TAU , 2.0]), TAU) , 250.0).x;
			}else{
				p = sub(mul(sp , TAU) , 250.0).xx;
			}
			var i:Var = mov(p.xy);
			var c:Var = F(1);
			var inten:Number = .005;

			for (var n:int = 0; n < MAX_ITER; n++) 
			{
				var t:Var = mul(time , (1.0 - (3.5 / (n + 1))));
				var t2:Var;
				var t2y:Var;
				
				t2 = add(cos(sub(t, i.x)), sin(add(t, i.y)));
				t2y = add(sin(sub(t, i.y)), cos(add(t, i.x)));
				i = add(p , t2.xx,i);
				
				t2 = div(p.x, div(sin(add(i.x, t)), inten));
				t2y = div(p.y, div(cos(add(i.y, t)), inten));
				mov ( t2y.x, t2.y);
				c = add(c, rcp(length(t2.xy,2)) );
			}
			
			c =div(c, MAX_ITER);
			c = sub(1.17,pow(c, 1.4));
			var colour:Var = pow(abs(c), 8.0);
			sat(add(colour, [0.0, 0.35, 0.5, 1]), oc);
		}
		
	}

}
/*https://www.shadertoy.com/view/MdlXz8

// Found this on GLSL sandbox. I really liked it, changed a few things and made it tileable.
// :)

// -----------------------------------------------------------------------
// Water turbulence effect by joltz0r 2013-07-04, improved 2013-07-07
// Altered
// -----------------------------------------------------------------------

// #define SEE_TILING

#define TAU 6.28318530718
#define MAX_ITER 5
#define SEE_TILING

void main( void ) 
{
	float time = iGlobalTime * .5+23.0;
	vec2 sp = gl_FragCoord.xy / iResolution.xy;
#ifdef SEE_TILING
	vec2 p = mod(sp*TAU*2.0, TAU)-250.0;
#else
    vec2 p = sp*TAU-250.0;
#endif
	vec2 i = vec2(p);
	float c = 1.0;
	float inten = .005;

	for (int n = 0; n < MAX_ITER; n++) 
	{
		float t = time * (1.0 - (3.5 / float(n+1)));
		i = p + vec2(cos(t - i.x) + sin(t + i.y), sin(t - i.y) + cos(t + i.x));
		c += 1.0/length(vec2(p.x / (sin(i.x+t)/inten),p.y / (cos(i.y+t)/inten)));
	}
	c /= float(MAX_ITER);
	c = 1.17-pow(c, 1.4);
	vec3 colour = vec3(pow(abs(c), 8.0));
	gl_FragColor = vec4(clamp(colour + vec3(0.0, 0.35, 0.5), 0.0, 1.0), 1.0);
}*/