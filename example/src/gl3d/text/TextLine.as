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
		public var fontSize:int;
		public var font:String;
		public var chars:Array;
		public var textDirty:Boolean = true;
		public var color:uint;
		public function TextLine(text:String=null,font:String="_serif",fontSize:int=12,color:uint=0) 
		{
			this.color = color;
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
					chars.push(new Char(_text.charAt(i),font,fontSize,color));
				}
			}
		}
		
		public function appendText(value:String,font:String="_serif",fontSize:int=12,color:uint=0):void{
			textDirty = true;
			if(_text){
				_text += value;
			}else{
				_text = value;
			}
			
			var tl:int = value.length;
			chars = chars||[];
			for (var i:int = 0; i < tl;i++ ){
				chars.push(new Char(value.charAt(i),font,fontSize,color));
			}
		}
	}

}