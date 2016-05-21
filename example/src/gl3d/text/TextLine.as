package gl3d.text 
{
	import gl3d.core.Node3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TextLine extends Node3D
	{
		private var _text:String;
		private var _color:uint = 0;
		private var _border:Boolean = false;
		private var _borderColor:uint = 0;
		public var chars:Array;
		public function TextLine() 
		{
		}
		
		public function get text():String 
		{
			return _text;
		}
		
		public function set text(value:String):void 
		{
			_text = value;
			var tl:int = _text.length;
			chars = [];
			for (var i:int = 0; i < tl;i++ ){
				chars.push(_text.charAt(i));
			}
		}
		
		public function get color():uint 
		{
			return _color;
		}
		
		public function set color(value:uint):void 
		{
			_color = value;
		}
		
		public function get border():Boolean 
		{
			return _border;
		}
		
		public function set border(value:Boolean):void 
		{
			_border = value;
		}
		
		public function get borderColor():uint 
		{
			return _borderColor;
		}
		
		public function set borderColor(value:uint):void 
		{
			_borderColor = value;
		}
		
	}

}