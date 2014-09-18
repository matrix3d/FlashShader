package lz.flShader 
{
	/**
	 * ...
	 * @author lizhi
	 */
	public class Var 
	{
		public static const TYPE_C:int = 1;
		public static const TYPE_T:int = 2;
		public static const TYPE_VA:int = 3;
		public static const TYPE_V:int = 4;
		public static const TYPE_FS:int = 5;
		public static const TYPE_OC:int = 6;
		public static const TYPE_OP:int = 7;
		
		public var index:int;
		public var type:int;
		public var component:String;
		public function Var(type:int,index:int=0) {
			this.type = type;
			this.index = index;
		}
		public function xyzw(value:String):Var {
			var v:Var = new Var(type, index);
			v.component = value;
			return v;
		}
		
		public function toString():String {
			return [type, index] + "";
		}
		
	}

}