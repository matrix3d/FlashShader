package lz.flShader 
{
	/**
	 * ...
	 * @author lizhi
	 */
	public class Var 
	{
		public var name:String;
		public function Var(name:String) {
			this.name = name;
		}
		public function xyzw(value:String):Var {
			var v:Var = new Var(name+"." + value);
			return v;
		}
		
	}

}