package gl3d.shaders.posts 
{
	import flash.display3D.Context3DProgramType;
	import flShader.FlShader;
	import flShader.Var;
	/**
	 * ...
	 * @author lizhi
	 */
	public class HdrShader extends FlShader
	{
		/**
		 * 
		 * @param	fAvgLum 0-.5
		 * @param	fDimmer 0-1
		 */
		public function HdrShader(fAvgLum:Number=.5, fDimmer:Number=.25) 
		{
			super(Context3DProgramType.FRAGMENT);
			var baseTex:Var=FS();
			var bloomTex:Var=FS();
			var uv:Var = V();
			var texCol:Var = tex(uv,baseTex);
			//计算平均亮度
			var vLum:Var = dp3([0.27,0.67,0.06] , texCol.xyz);
			//亮度缩放
			var vLumScaled:Var = mul(fDimmer/fAvgLum,  vLum);
			
			texCol = div(mul(texCol.xyz, vLumScaled),add(1,texCol));
			
			var texBloom:Var = tex(uv,bloomTex);        
			add(texBloom , texCol,oc);
		}
		
	}

}
//http://www.dreamfairy.cn/blog/index.php/2013/05/28/lets-create-a-post-processing-effect-hdr.html