package ui 
{
	import com.bit101.components.TextArea;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Log extends TextArea
	{
		static public var instance:Log;
		public function Log() 
		{
			instance = this;
			setSize(550, 60);
		}
		
		public function log(...args):void 
		{
			text += args + "\n";
			draw();
			textField.scrollV = textField.maxScrollV;
		}
		
	}

}