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
		public var fontSize:int;
		public var font:String;
		public var chars:Array;
		public var textDirty:Boolean = true;
		public function TextLine(text:String=null,font:String="_serif",fontSize:int=12) 
		{
			this.fontSize = fontSize;
			this.font = font;
			this.text = text;
		}
		
		public function get text():String 
		{
			return _text;
		}
		
		public function set text(value:String):void 
		{
			textDirty = true;
			_text = value;
			if(_text){
				var tl:int = _text.length;
				chars = [];
				for (var i:int = 0; i < tl;i++ ){
					chars.push(_text.charAt(i));
				}
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
	}

}