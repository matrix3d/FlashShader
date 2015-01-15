package gl3d.shaders.posts 
{
	import flash.display3D.Context3DProgramType;
	import as3Shader.AS3Shader;
	import as3Shader.Var;
	/**
	 * ...
	 * @author lizhi
	 */
	public class HeartShader extends AS3Shader
	{
		
		public function HeartShader() 
		{
			super(Context3DProgramType.FRAGMENT);
			var UV:Var = mov(V());
			sub(1, UV.y, UV.y);
			var iResolution:Var = mov(C().yz);
			var gl_FragCoord:Var = mul(UV , iResolution);
			var iGlobalTime:Var = div(mov(C().x), 1000);
			
			var p:Var = div(sub(mul(2.0,gl_FragCoord),iResolution),min(iResolution.y,iResolution.x));
			sub(p.y, 0.25, p.y);

			// background color
			var tv3:Var = mov(1);
			mov(.8, tv3.y);
			mov(sub(.7,mul(.07,p.y)),tv3.z);
			var bcol:Var = mul(tv3, sub(1, mul(0.25, length(p))));
			
			// animate
			var tt:Var = div(mod(iGlobalTime,1.5),1.5);
			var ss:Var = add(mul(pow(tt,.2),0.5) ,0.5).x;
			ss = sub(ss,mul2([ss,0.2,sin(mul(tt,6.2831*3.0)),exp(mul(tt,-4.0))]),ss);
			p = mul(p,add([0.5,1.5] , mul(ss,[0.5,-0.5])),p);
		   

			// shape
			var a:Var =div(atan2(p.x,p.y),3.141593);
			var r:Var = length(p);
			var h:Var =abs(a).x;
			var d:Var = div(add(sub(mul(13.0,h) , mul2([22.0,h,h])) , mul2([10.0,h,h,h])),sub(6.0,mul(5.0,h)));

			// color
			var s:Var = sub(1.0,mul(0.5,sat(div(r,d))));
			s = add(0.75 , mul(0.75,p.x));
			s =mul(s, sub(1.0,mul(0.25,r)));
			s = add(0.5 ,mul( 0.6,s));
			s = mul(s, add(0.5, mul(0.5, pow( sub(1.0, sat(div(r, d))), 0.1 ))));
			tv3 = mov([1.0, .5, .3]);
			mul(tv3.y, r, tv3.y);
			var hcol:Var = mul(tv3,s);
			
			var col:Var = mix( bcol, hcol, smoothstep( mov(-0.01), mov(0.01), sub(d,r)) );
			mov(1, col.w);
			mov(col, oc);
		}
		
	}

}

/*https://www.shadertoy.com/view/XsfGRn
void main(void)
{
	vec2 p = (2.0*gl_FragCoord.xy-iResolution.xy)/min(iResolution.y,iResolution.x);
	
	p.y -= 0.25;

    // background color
    vec3 bcol = vec3(1.0,0.8,0.7-0.07*p.y)*(1.0-0.25*length(p));

    // animate
    float tt = mod(iGlobalTime,1.5)/1.5;
    float ss = pow(tt,.2)*0.5 + 0.5;
    ss -= ss*0.2*sin(tt*6.2831*3.0)*exp(-tt*4.0);
    p *= vec2(0.5,1.5) + ss*vec2(0.5,-0.5);
   

    // shape
    float a = atan(p.x,p.y)/3.141593;
    float r = length(p);
    float h = abs(a);
    float d = (13.0*h - 22.0*h*h + 10.0*h*h*h)/(6.0-5.0*h);

	// color
	float s = 1.0-0.5*clamp(r/d,0.0,1.0);
	s = 0.75 + 0.75*p.x;
	s *= 1.0-0.25*r;
	s = 0.5 + 0.6*s;
	s *= 0.5+0.5*pow( 1.0-clamp(r/d, 0.0, 1.0 ), 0.1 );
	vec3 hcol = vec3(1.0,0.5*r,0.3)*s;
	
    vec3 col = mix( bcol, hcol, smoothstep( -0.01, 0.01, d-r) );

    gl_FragColor = vec4(col,1.0);
}*/