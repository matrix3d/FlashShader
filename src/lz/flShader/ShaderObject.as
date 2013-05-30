package lz.flShader 
{
	/**
	 * ...
	 * @author lizhi http://matrix3d.github.io/
	 */
	public class ShaderObject 
	{
		public static const TYPE_CONST:int = 0;
		public static const TYPE_TEMP:int = 1;
		public static const TYPE_NAMES:Array = ["vc","vt"];
		public var index:int;
		public var type:int;
		public function ShaderObject(type:int,index:int) 
		{
			this.index = index;
			this.type = type;
			
		}
		public function toString():String {
			return TYPE_NAMES[type] + index;
		}
		
	}

}