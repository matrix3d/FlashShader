package gl3d.text 
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
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
		public var size:int;
		public var newChars:Array = [];
		public var chars:Object = {};
		public var numChar:int = 0;
		public var txtIndex:int = 0;
		public var tset:TextureSet;
		public var bmd:BitmapData;
		private var helpMatr:Matrix = new Matrix;
		private var tf:TextField = new TextField;
		private var tsize:int =-1;
		private var tsizew:int = 1;
		private var tsizeh:int = 1;
		private var rp:RectanglePacker;
		public function CharSet(font:String=null,fontSize:int=12) 
		{
			tf.textColor = 0xffffff;
			tf.autoSize = TextFieldAutoSize.LEFT;
			var tfm:TextFormat = new TextFormat(font, fontSize);
			tf.defaultTextFormat = tfm;
			tf.text = "A";
			this.size = tf.height;
			trace(size);
			
		}
		
		public function add(chars:Array):void{
			if(chars)
			newChars.push(chars);
		}
		
		public function update():void{
			if (newChars.length){
				var needUpdate:Boolean = false;
				for each(var newChar:Array in newChars){
					for each(var txt:String in newChar){
						if (chars[txt]==null){
							chars[txt] = new Char(txt);
							chars[txt].id = numChar;
							numChar++;
							needUpdate = true;
						}
					}
				}
				if (!needUpdate) return;
				var r:int = 1;
				while (true) {
					var sqrtPow2num:int = int(r / size);
					if (sqrtPow2num*sqrtPow2num>=numChar){
						break;
					}
					r *= 2;
				}
				if (r != tsize){
					txtIndex = 0;
					tsize = r;
					bmd = new BitmapData(tsize, tsize, true, 0);
					tset  = new TextureSet(bmd,false,false,false,false,false,null);
					for each(var char:Char in chars){
						char.dirty = true;
					}
				}else{
					tset.dataInvalid = true;
				}
				newChars = [];
				
				while(true){
					if (rp==null){
						rp = new RectanglePacker(tsizew, tsizeh);
						var gdirty:Boolean = true;
					}else{
						gdirty = false;
					}
					for each(char in chars){
						if (char.dirty||gdirty){
							char.dirty = false;
							tf.text = char.txt;
							char.tx = txtIndex % sqrtPow2num;
							char.ty = int(txtIndex / sqrtPow2num);
							char.index = txtIndex;
							char.bound = tf.getCharBoundaries(0);
							char.linem = tf.getLineMetrics(0);
							helpMatr.tx = size * char.tx;
							helpMatr.ty = size * char.ty;
							rp.insertRectangle(tf.width, tf.height, char.id);
							bmd.draw(tf, helpMatr);
							char.u0 = (char.tx * size+char.linem.x) / tsize;
							char.v0 = char.ty * size / tsize;
							char.u1 = (char.tx * size+char.linem.x+char.linem.width) / tsize;
							char.v1 = (char.ty + 1) * size / tsize;
							txtIndex++;
						}
					}
					rp.packRectangles();
					if (rp.rectangleCount==numChar){
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