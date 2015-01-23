package gl3d.shaders.particle 
{
	import flash.display3D.Context3DProgramType;
	import as3Shader.AS3Shader;
	import as3Shader.Var;
	import gl3d.core.Material;
	/**
	 * ...
	 * @author lizhi
	 */
	public class ParticleFragmentShader extends AS3Shader
	{
		private var material:Material;
		private var vs:ParticleVertexShader;
		public var diffSampler:Var = sampler();
		public function ParticleFragmentShader(material:Material,vs:ParticleVertexShader) 
		{
			super(Context3DProgramType.FRAGMENT);
			this.vs = vs;
			this.material = material;
			
		}
		override public function build():void {
			var color:Var = vs.colorVarying;
			if (material.diffTexture) {
				var tex0:Var = tex(vs.uvVarying, diffSampler, null, ["miplinear","anisotropic16x", "repeat"]);
				oc = mul(color, tex0);
			}else {
				oc = color;
			}
		}
		
	}

}