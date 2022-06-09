package  
{
	import as3Shader.Var;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestVar extends Sprite
	{
		
		public function TestVar() 
		{
			var v:Var2 = new Var2(0);
			trace(v.ddd);
		}
		
	}

}
import as3Shader.Var;

dynamic class Var2 extends Var{
	public function Var2(type:int, index:int = 0) 
	{
		super(0);
		
		trace(ccc);
	}
}