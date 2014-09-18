package  
{
	import flash.display3D.Context3DProgramType;
	import lz.flShader.FlShader;
	import lz.flShader.Var;
	/**
	 * ...
	 * @author lizhi
	 */
	public class MyShader extends FlShader
	{
		public function MyShader() 
		{
			super(Context3DProgramType.FRAGMENT);
			var v0:Var = V();
			add(abs(ddx(v0)),abs(ddy(v0)));
			tex(v0, v0, v0, "<2d,3d>");
			trace(code);
		}
	}
}