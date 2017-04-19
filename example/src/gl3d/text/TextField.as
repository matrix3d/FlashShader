package gl3d.text 
{
	import flash.text.TextFieldAutoSize;
	import gl3d.core.Node3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TextField extends Node3D
	{
		private var _text:String;
		public var fontSize:int;
		public var font:String;
		public var chars:Array = [];
		public var charsLength:int = 0;
		public var textDirty:Boolean = true;
		public var textMatrixDirty:Boolean = false;
		public var color:uint;
		private var _htmlText:String;
		public var width:Number = 100;
		public var height:Number = 100;
		public var wordWrap:Boolean = false;
		public var autoSize:String = TextFieldAutoSize.NONE;
		
		public var textWidth:Number = 0;
		public var textHeight:Number = 0;
		public function TextField(text:String=null,font:String="_serif",fontSize:int=12,color:uint=0) 
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
			if (_text==value){
				return;
			}
			textDirty = true;
			_text = value;
			if(_text){
				charsLength = _text.length;
				for (var i:int = 0; i < charsLength; i++ ){
					var c:Char = chars[i];
					if (c==null){
						c = chars[i] = new Char(_text.charAt(i), font, fontSize, color);
					}else{
						c.txt = _text.charAt(i);
						c.font = font;
						c.fontSize = fontSize;
						c.color = color;
					}
				}
			}
		}
		
		public function get htmlText():String 
		{
			return _htmlText;
		}
		
		public function set htmlText(value:String):void 
		{
			_htmlText = value;
			charsLength = 0;
			if (value){
				try{
					var xml:XML = new XML(value);
					doXML(xml,font,fontSize,color);
				}catch (err:Error){
					trace(err);
				}
			}
		}
		
		private function doXML(xml:XML,font:String,fontSize:int,color:uint):void {
			var l:String = xml.localName();
			if (l=="br"){
				
			}
			var txt:String = xml.text();
			if (txt && txt.length > 0){
				if(l=="font"){
					if ((xml.@face+"")!=""){
						font = xml.@face+"";
					}
					if ((xml.@size+"")!=""){
						fontSize = Number(xml.@size);
					}
					if ((xml.@color+"")!=""){
						color = parseInt((xml.@color+"").replace("#","0x"));
					}
				}
				appendText(txt,font,fontSize,color);
			}
			
			var cs:XMLList = xml.children();
			if (cs.length()) {
				for each(var c:XML in cs) {
					doXML(c,font,fontSize,color);
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
			for (var j:int = 0; j < tl; j++ ){
				var i:int = j + charsLength;
				var c:Char = chars[i];
				if (c==null){
					c = chars[i] = new Char(_text.charAt(i), font, fontSize, color);
				}else{
					c.txt = _text.charAt(i);
					c.font = font;
					c.fontSize = fontSize;
					c.color = color;
				}
			}
			charsLength += tl;
		}
	}

}