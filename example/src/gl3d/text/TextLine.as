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
		private var _htmlText:String;
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
		
		public function get htmlText():String 
		{
			return _htmlText;
		}
		
		public function set htmlText(value:String):void 
		{
			_htmlText = value;
			chars = [];
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
			for (var i:int = 0; i < tl;i++ ){
				chars.push(new Char(value.charAt(i),font,fontSize,color));
			}
		}
	}

}