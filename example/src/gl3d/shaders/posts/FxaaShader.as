package gl3d.shaders.posts 
{
	import as3Shader.Var;
	import flash.display3D.Context3DProgramType;
	import gl3d.core.shaders.GLAS3Shader;
	/**
	 * ...
	 * @author lizhi
	 */
	public class FxaaShader extends GLAS3Shader
	{
		private static const FXAA_REDUCE_MIN:Number =   (1.0 / 128.0);
		private static const FXAA_REDUCE_MUL:Number =   (1.0 / 8.0);
		private static const FXAA_SPAN_MAX:Number =     8.0;
		public function FxaaShader() 
		{
			super(Context3DProgramType.FRAGMENT);
			var uViewportSize:Var = uniformPixelSize();
			var fragCoord:Var = mul(V(), uniformPixelSize());
			var inverseVP:Var = div(mov(1), uViewportSize);
			var rgbNW:Var = tex(mul(add(fragCoord , [-1.0, -1.0]) , inverseVP),samplerDiff());
			var rgbNE:Var = tex(mul(add(fragCoord , [1.0, -1.0]) , inverseVP),samplerDiff());
			var rgbSW:Var = tex(mul(add(fragCoord , [-1.0, 1.0]) , inverseVP),samplerDiff());
			var rgbSE:Var = tex(mul(add(fragCoord , [1.0, 1.0]) , inverseVP),samplerDiff());
			var rgbM:Var  = tex(mul(fragCoord  , inverseVP),samplerDiff());
			var luma:Array = [0.299, 0.587, 0.114];
			var lumaNW:Var = dp3(rgbNW, luma);
			var lumaNE:Var = dp3(rgbNE, luma);
			var lumaSW:Var = dp3(rgbSW, luma);
			var lumaSE:Var = dp3(rgbSE, luma);
			var lumaM:Var  = dp3(rgbM,  luma);
			var lumaMin:Var = min(lumaM, min(min(lumaNW, lumaNE), min(lumaSW, lumaSE)));
			var lumaMax:Var = max(lumaM, max(max(lumaNW, lumaNE), max(lumaSW, lumaSE)));
			
			var dir:Var=
			vec2( neg(sub(add(lumaNW , lumaNE) , add(lumaSW , lumaSE))),
			 sub(add(lumaNW , lumaSW) , add(lumaNE , lumaSE)));
			
			var dirReduce:Var = max(mul(add2([lumaNW , lumaNE , lumaSW , lumaSE]) ,
								  (0.25 * FXAA_REDUCE_MUL)), FXAA_REDUCE_MIN);
			
			var rcpDirMin:Var = div(1.0 , add(min(abs(dir.x), abs(dir.y)) , dirReduce));
			dir = mul(min(vec2(FXAA_SPAN_MAX, FXAA_SPAN_MAX),
					  max(vec2(-FXAA_SPAN_MAX, -FXAA_SPAN_MAX),
					  mul(dir , rcpDirMin))) , inverseVP);
			  
			var rgbA:Var = mul(0.5 , add(
				tex(add(mul(fragCoord , inverseVP) , mul(dir , (1.0 / 3.0 - 0.5))),samplerDiff()) ,
				tex(add(mul(fragCoord , inverseVP) , mul(dir , (2.0 / 3.0 - 0.5))),samplerDiff())
				));
			var rgbB:Var =add( mul(rgbA , 0.5) ,mul( 0.25 , add(
				tex(add(mul(fragCoord , inverseVP) , mul(dir , -0.5)),samplerDiff()) ,
				tex(add(mul(fragCoord , inverseVP) , mul(dir , 0.5)),samplerDiff())
				)));

			var lumaB:Var = dp3(rgbB, luma);
			var flag:Var = mul(sge(lumaB, lumaMin), slt(lumaB, lumaMax));
			oc = add(mul(sub(1, flag), rgbA), mul(flag, rgbB));
		}
		
	}

}

//https://github.com/mitsuhiko/webgl-meincraft/blob/master/assets/shaders/fxaa.glsl
	
/* Basic FXAA implementation based on the code on geeks3d.com with the
   modification that the texture2DLod stuff was removed since it's
   unsupported by WebGL. */
/*
#define FXAA_REDUCE_MIN   (1.0/ 128.0)
#define FXAA_REDUCE_MUL   (1.0 / 8.0)
#define FXAA_SPAN_MAX     8.0

vec4 applyFXAA(vec2 fragCoord, sampler2D tex)
{
    vec4 color;
    vec2 inverseVP = vec2(1.0 / uViewportSize.x, 1.0 / uViewportSize.y);
    vec3 rgbNW = texture2D(tex, (fragCoord + vec2(-1.0, -1.0)) * inverseVP).xyz;
    vec3 rgbNE = texture2D(tex, (fragCoord + vec2(1.0, -1.0)) * inverseVP).xyz;
    vec3 rgbSW = texture2D(tex, (fragCoord + vec2(-1.0, 1.0)) * inverseVP).xyz;
    vec3 rgbSE = texture2D(tex, (fragCoord + vec2(1.0, 1.0)) * inverseVP).xyz;
    vec3 rgbM  = texture2D(tex, fragCoord  * inverseVP).xyz;
    vec3 luma = vec3(0.299, 0.587, 0.114);
    float lumaNW = dot(rgbNW, luma);
    float lumaNE = dot(rgbNE, luma);
    float lumaSW = dot(rgbSW, luma);
    float lumaSE = dot(rgbSE, luma);
    float lumaM  = dot(rgbM,  luma);
    float lumaMin = min(lumaM, min(min(lumaNW, lumaNE), min(lumaSW, lumaSE)));
    float lumaMax = max(lumaM, max(max(lumaNW, lumaNE), max(lumaSW, lumaSE)));
    
    vec2 dir;
    dir.x = -((lumaNW + lumaNE) - (lumaSW + lumaSE));
    dir.y =  ((lumaNW + lumaSW) - (lumaNE + lumaSE));
    
    float dirReduce = max((lumaNW + lumaNE + lumaSW + lumaSE) *
                          (0.25 * FXAA_REDUCE_MUL), FXAA_REDUCE_MIN);
    
    float rcpDirMin = 1.0 / (min(abs(dir.x), abs(dir.y)) + dirReduce);
    dir = min(vec2(FXAA_SPAN_MAX, FXAA_SPAN_MAX),
              max(vec2(-FXAA_SPAN_MAX, -FXAA_SPAN_MAX),
              dir * rcpDirMin)) * inverseVP;
      
    vec3 rgbA = 0.5 * (
        texture2D(tex, fragCoord * inverseVP + dir * (1.0 / 3.0 - 0.5)).xyz +
        texture2D(tex, fragCoord * inverseVP + dir * (2.0 / 3.0 - 0.5)).xyz);
    vec3 rgbB = rgbA * 0.5 + 0.25 * (
        texture2D(tex, fragCoord * inverseVP + dir * -0.5).xyz +
        texture2D(tex, fragCoord * inverseVP + dir * 0.5).xyz);

    float lumaB = dot(rgbB, luma);
    if ((lumaB < lumaMin) || (lumaB > lumaMax))
        color = vec4(rgbA, 1.0);
    else
        color = vec4(rgbB, 1.0);
    return color;
}

#endif*/