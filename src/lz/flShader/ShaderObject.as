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
		public static const TYPE_ATTRIB:int = 2;
		public static const TYPE_VARYING:int = 3;
		public static const TYPE_VAR:int = 4;
		public static const TYPE_NAMES:Array = ["vc","vt","va","v","vc"];
		public var index:int;
		public var type:int;
		public var name:String;
		public var numComp:int;
		public function ShaderObject(type:int,index:int,numComp:int,name:String=null) 
		{
			this.numComp = numComp;
			this.name = name;
			this.index = index;
			this.type = type;
			
		}
		public function toString():String {
			return TYPE_NAMES[type] + index;
		}
		
	}

}