package gl3d.text 
{
	import flash.display.BitmapData;
	import flash.display.InteractiveObject;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import gl3d.core.TextureSet;
	import org.villekoskela.utils.RectanglePacker;
	/**
	 * ...
	 * @author lizhi
	 */
	public class CharSet 
	{
		public var newChars:Array = [];
		private var fontSizeChars:Object = {};
		public var numChar:int = 0;
		public var tset:TextureSet;
		public var bmd:BitmapData;
		private var helpMatr:Matrix = new Matrix;
		private var tsizew:int = 1;
		private var tsizeh:int = 1;
		private var rp:RectanglePacker;
		public function CharSet() 
		{
		}
		
		public function add(chars:Array,len:int):void{
			if(chars){
				newChars.push(chars,len);
			}
		}
		
		public function getChar(txt:String, font:String, fontSize:int):CharInstance{
			var farr:Object = fontSizeChars[font];
			if (farr==null){
				return null;
			}
			var sizearr:Object = farr[fontSize];
			if (sizearr==null){
				return null;
			}
			return sizearr[txt];
		}
		
		public function setChar(char:CharInstance, font:String, fontSize:int):void{
			var farr:Object = fontSizeChars[font];
			if (farr==null){
				farr = fontSizeChars[font] = {};
			}
			var sizearr:Object = farr[fontSize];
			if (sizearr==null){
				sizearr = farr[fontSize] = {};
			}
			sizearr[char.txt] = char;
		}
		
		public function update():void{
			if (newChars.length){
				var needUpdate:Boolean = false;
				var len:int = newChars.length;
				for (var i:int = 0; i < len;i+=2 ){
					var newChar:Array = newChars[i];
					var newCharLen:int = newChars[i + 1];
					for (var j:int = 0; j < newCharLen;j++){
						var c:Char = newChar[j];
						var char:CharInstance=getChar(c.txt,c.font,c.fontSize)
						if (char==null){
							char = new CharInstance(c.txt,c.font,c.fontSize);
							char.id = numChar;
							setChar(char, c.font, c.fontSize);
							numChar++;
							needUpdate = true;
						}
						c.instance = char;
					}
				}
				newChars = [];
				if (!needUpdate) return;
				
				while(true){
					if (rp==null){
						rp = new RectanglePacker(tsizew, tsizeh);
						bmd = new BitmapData(tsizew, tsizeh, true, 0);
						tset  = new TextureSet(bmd,false,false,false,false,false,null);
						var gdirty:Boolean = true;
					}else{
						gdirty = false;
					}
					tset.dataInvalid = true;
					var id2index:Object = {};
					var id2bft:Object = {};
					for each(var tempa:Object in fontSizeChars){
						for each(var tempb:Object in tempa){
							for each(char in tempb){
								if (char.dirty||gdirty){
									char.dirty = true;
									var bft:BitmapDataFromText = new BitmapDataFromText(char.txt,char.fontSize,char.font);
									id2index[char.id] = rp.rectangleCount;
									id2bft[char.id] = bft;
									rp.insertRectangle(bft.width+1, bft.height+1, char.id);
									rp.packRectangles(false);
								}
							}
						}
						
					}
					if (rp.rectangleCount == numChar){
						for each(tempa in fontSizeChars){
							for each(tempb in tempa){
								for each(char in tempb){
									if (char.dirty){
										char.dirty = false;
										var rect:Rectangle = new Rectangle;
										rp.getRectangle(id2index[char.id], rect);
										bft = id2bft[char.id];
										char.width = bft.width;
										char.height = bft.height;
										helpMatr.tx = rect.x;
										helpMatr.ty = rect.y;
										if(bft.bmd){
											bmd.draw(bft.bmd, helpMatr);
										}
										char.u0 = rect.x / tsizew;
										char.v0 = rect.y / tsizeh;
										char.u1 = (rect.x +bft.width) / tsizew;
										char.v1 = (rect.y + bft.height) / tsizeh;
										
										char.ascent = bft.ascent;
										char.xadvance = bft.xadvance;
									}	
								}
							}
						}
						break;
					}
					if (tsizeh==tsizew){
						tsizew *= 2;
					}else{
						tsizeh *= 2;
					}
					rp = null;
				}
			}
		}
	}

}