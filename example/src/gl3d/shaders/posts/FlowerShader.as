package gl3d.shaders.posts 
{
	import flash.display3D.Context3DProgramType;
	import flShader.FlShader;
	import flShader.Var;
	/**
	 * ...
	 * @author lizhi
	 */
	public class FlowerShader  extends FlShader
	{
		
		public function FlowerShader() 
		{
			super(Context3DProgramType.FRAGMENT);
			var UV:Var = mov(V());
			sub(1, UV.y, UV.y);
			var iResolution:Var = mov(C().yz);
			var gl_FragCoord:Var = mul(UV , iResolution);
			var iGlobalTime:Var = div(mov(C().x), 1000);
			
			var p:Var = div(sub(mul(2.0,gl_FragCoord),iResolution),min(iResolution.y,iResolution.x));

			var a:Var = atan2(p.x,p.y);
			var r:Var = mul(length(p),add(0.8,mul(0.2,sin(mul(0.3,iGlobalTime)))));

			var w:Var = cos(sub(mul(2.0,iGlobalTime),mul(r,2.0)));
			var h:Var = add(0.5,mul(0.5,cos(add2([sub(mul(12.0,a),mul(w,7.0)),mul(r,8.0), mul(0.7,iGlobalTime)]))));
			var d:Var = add(0.25,mul2([0.75,pow(h,mul(1.0,r)),add(0.7,mul(0.3,w))]));

			var f:Var = mul2([sqt(sub(1.0,div(r,d))),r,2.5]);
			f =mul(f, add(1.25,mul(0.25,cos(div(add(sub(mul(12.0,a),mul(w,7.0)),mul(r,8.0)),2.0)))));
			f =mul(f, sub(1.0 , mul2([0.35,add(0.5,mul(0.5,sin(mul(r,30.0)))),add(0.5,mul(0.5,cos(add(sub(mul(12.0,a),mul(w,7.0)),mul(r,8.0)))))])));
			
			var col:Var = vec3( f,
							 add2([sub(f,mul(h,0.5)),mul(r,.2) , mul2([0.35,h,sub(1.0,r)])]),
							 add(sub(f,mul(h,r)) , mul2([0.1,h,sub(1.0,r)])) );
			col = sat( col);
			
			var bcol:Var = mix( mov([0.8/2,0.9/2,1.0/2]), mov(1.0), add(0.5,mul(0.5,p.y)) );
			col = mix( col, bcol, smoothstep(mov(-0.3),0.6,sub(r,d)) );
			mov(1, col.w);
			mov(col, oc);
		}
		
	}

}

/*https://www.shadertoy.com/view/4dX3Rn
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

void main(void)
{
	vec2 p = (2.0*gl_FragCoord.xy-iResolution.xy)/min(iResolution.y,iResolution.x);

    float a = atan(p.x,p.y);
    float r = length(p)*(0.8+0.2*sin(0.3*iGlobalTime));

    float w = cos(2.0*iGlobalTime+-r*2.0);
    float h = 0.5+0.5*cos(12.0*a-w*7.0+r*8.0+ 0.7*iGlobalTime);
    float d = 0.25+0.75*pow(h,1.0*r)*(0.7+0.3*w);

    float f = sqrt(1.0-r/d)*r*2.5;
    f *= 1.25+0.25*cos((12.0*a-w*7.0+r*8.0)/2.0);
    f *= 1.0 - 0.35*(0.5+0.5*sin(r*30.0))*(0.5+0.5*cos(12.0*a-w*7.0+r*8.0));
	
	vec3 col = vec3( f,
					 f-h*0.5+r*.2 + 0.35*h*(1.0-r),
                     f-h*r + 0.1*h*(1.0-r) );
	col = clamp( col, 0.0, 1.0 );
	
	vec3 bcol = mix( 0.5*vec3(0.8,0.9,1.0), vec3(1.0), 0.5+0.5*p.y );
	col = mix( col, bcol, smoothstep(-0.3,0.6,r-d) );
    gl_FragColor = vec4( col, 1.0 );
}*/