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
			tex(F([1]), F([1]), c1);
			tex(F([2]), F([3]), c1);
			tex(F([2,3,3,3]), F([3]), c1);
			
			code;
			trace(code);
		}
	}
}