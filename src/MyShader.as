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
			var v0:Var = new Var(Var.TYPE_V);
			add(abs(ddx(v0)),abs(ddy(v0)));
			trace(code);
			
		}
	}
}