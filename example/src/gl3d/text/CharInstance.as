package gl3d.text 
{
	import flash.geom.Rectangle;
	import flash.text.TextLineMetrics;
	/**
	 * ...
	 * @author lizhi
	 */
	public class CharInstance 
	{
		public var font:String;
		public var fontSize:int;
		public var id:int;
		public var txt:String;
		public var u0:Number;
		public var v0:Number;
		public var u1:Number;
		public var v1:Number;
		public var dirty:Boolean = true;
		public var width:int;
		public var height:int;
		public var ascent:int;
		public var xadvance:int;
		public function CharInstance(txt:String,font:String,fontSize:int) 
		{
			this.fontSize = fontSize;
			this.font = font;
			this.txt = txt;
			
		}
		
	}

}