package gl3d.hlbsp 
{
	import flash.text.TextField;
	/**
	 * ...
	 * @author lizhi
	 */
	public class console 
	{
		public static var textfield:TextField;
		public function console() 
		{
			
		}
		static public function log(...args):void {
			trace(args);
			if (textfield) {
				textfield.appendText(args + "\n");
				textfield.scrollV = textfield.maxScrollV;
			}
		}
		
	}

}