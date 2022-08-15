package gl3d.shaders.particle 
{
	import flash.display3D.Context3DProgramType;
	import as3Shader.AS3Shader;
	import as3Shader.Var;
	import gl3d.core.Material;
	import gl3d.core.shaders.GLAS3Shader;
	/**
	 * ...
	 * @author lizhi
	 */
	public class ParticleFragmentShader extends GLAS3Shader
	{
		public var diffSampler:Var //= sampler();
		public function ParticleFragmentShader() 
		{
			super(Context3DProgramType.FRAGMENT);
			diffSampler = samplerDiff();
			
		}
		override public function build():void {
			var color:Var = (vs as ParticleVertexShader).colorVarying;
			/*if (material.diffTexture) {
				var tex0:Var = tex(vs.uvVarying, diffSampler, null, material.diffTexture.flags);
				oc = mul(color, tex0);
			}else {*/
				oc = color;
			//}
		}
		
	}

}