package gl3d.text 
{
	import flash.geom.Rectangle;
	import flash.text.TextLineMetrics;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Char 
	{
		public var id:int;
		public var txt:String;
		public var bound:Rectangle;
		public var linem:TextLineMetrics;
		public var tx:int;
		public var ty:int;
		public var index:int;
		public var u0:Number;
		public var v0:Number;
		public var u1:Number;
		public var v1:Number;
		public var dirty:Boolean = true;
		public function Char(txt:String) 
		{
			this.txt = txt;
			
		}
		
	}

}