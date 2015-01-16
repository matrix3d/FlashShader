package ui 
{
	import flash.text.TextField;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Label extends UIComponent
	{
		private var textField:TextField;
		
		public function Label() 
		{
			super(null);
			textField = new TextField;
			addChild(textField);
			textField.autoSize = "left";
			textField.mouseEnabled = textField.mouseWheelEnabled = false;
		}
		override public function get width():Number 
		{
			return textField.width;
		}
		
		override public function get height():Number 
		{
			return textField.height;
		}
		
		public function get text():String 
		{
			return textField.text;
		}
		
		public function set text(value:String):void 
		{
			textField.text = value;
		}
		
	}

}