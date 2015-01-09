package ui 
{
	import flash.text.TextField;
	import ui.win7.ButtonStyle;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Button extends UIComponent
	{
		private var _label:String = "";
		public var textfield:TextField = new TextField;
		public function Button(label:String="",style:Style=null) 
		{
			style = style || new ButtonStyle;
			addChild(textfield);
			super(style);
			this.label = label;
		}
		
		public function get label():String 
		{
			return _label;
		}
		
		public function set label(value:String):void 
		{
			_label = value;
			textfield.text = value;
		}
		
	}

}