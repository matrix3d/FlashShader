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
		private var material:Material;
		private var vs:ParticleVertexShader;
		public var diffSampler:Var //= sampler();
		public function ParticleFragmentShader(material:Material,vs:ParticleVertexShader) 
		{
			super(Context3DProgramType.FRAGMENT);
			this.vs = vs;
			this.material = material;
			diffSampler = samplerDiff();
			
		}
		override public function build():void {
			var color:Var = vs.colorVarying;
			if (material.diffTexture) {
				var tex0:Var = tex(vs.uvVarying, diffSampler, null, material.diffTexture.flags);
				oc = mul(color, tex0);
			}else {
				oc = color;
			}
		}
		
	}

}