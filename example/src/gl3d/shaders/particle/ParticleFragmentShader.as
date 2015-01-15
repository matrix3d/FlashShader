package gl3d.shaders.particle 
{
	import flash.display3D.Context3DProgramType;
	import as3Shader.AS3Shader;
	import as3Shader.Var;
	/**
	 * ...
	 * @author lizhi
	 */
	public class ParticleFragmentShader extends AS3Shader
	{
		
		public function ParticleFragmentShader() 
		{
			super(Context3DProgramType.FRAGMENT);
		}
		override public function build():void {
			var color:Var = V(1);
			var tex0:Var = tex(V(), FS(), null,["linear","repeat"]);
			mul(color,tex0, oc);
		}
		
	}

}