package  
{
	import flash.display3D.Context3DProgramType;
	import flShader.FlShader;
	import flShader.Var;
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
			var c0:Var = C();
			var c1:Var = C(1);
			add(abs(ddx(v0)),abs(ddy(v0)));
			tex(F([1,2,3,4]), c0, c1, "<2d,3d>");
			
			code;
			//trace(code);
		}
	}
}