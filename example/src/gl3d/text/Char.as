package gl3d.text 
{
	/**
	 * ...
	 * @author lizhi
	 */
	public class Char 
	{
		public var instance:CharInstance;
		public var color:uint;
		public var txt:String;
		public var font:String;
		public var fontSize:int;
		
		public var a:Number;
		public var r:Number;
		public var g:Number;
		public var b:Number;
		
		public var x0:Number;
		public var x1:Number;
		public var y0:Number;
		public var y1:Number;
		public var charVersion:int = 0;
		public var lineInfo:LineInfo;
		public function Char(txt:String,font:String,fontSize:int,color:uint) 
		{
			this.color = color;
			this.fontSize = fontSize;
			this.font = font;
			this.txt = txt;
			a = ((color >> 24) & 0xff)/0xff;
			r = ((color >> 16) & 0xff)/0xff;
			g = ((color >> 8) & 0xff)/0xff;
			b = (color & 0xff)/0xff;
		}
		
	}

}