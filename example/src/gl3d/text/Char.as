package gl3d.text 
{
	/**
	 * ...
	 * @author lizhi
	 */
	public class Char 
	{
		public var txt:String;
		public var font:String;
		public var fontSize:int;
		
		public function Char(txt:String,font:String,fontSize:int) 
		{
			this.fontSize = fontSize;
			this.font = font;
			this.txt = txt;
			
		}
		
	}

}