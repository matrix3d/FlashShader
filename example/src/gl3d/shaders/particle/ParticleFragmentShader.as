package gl3d.shaders.particle 
{
	import flash.display3D.Context3DProgramType;
	import flShader.FlShader;
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
			tex(V(), FS(), oc);
			//mov(C(), oc);
		}
		
	}

}