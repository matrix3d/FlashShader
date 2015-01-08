package gl3d.shaders.particle 
{
	import flash.display3D.Context3DProgramType;
	import flShader.FlShader;
	import flShader.Var;
	/**
	 * ...
	 * @author lizhi
	 */
	public class ParticleFragmentShader extends FlShader
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