package  
{
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
			var v0:Var = new Var("v0");
			//fwidth abs( ddx( v ) ) + abs( ddy( v ) );
			add(abs(ddx(v0)),abs(ddy(v0)));
			trace(code);
			
		}
	}
}