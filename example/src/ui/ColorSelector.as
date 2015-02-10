package  ui
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	/**
	 * @author lizhi
	 */
	public class ColorSelector extends Sprite
	{
		
		
		private var rlabel:NumericStepper = createStepper("r");
		private var glabel:NumericStepper = createStepper("g");
		private var blabel:NumericStepper = createStepper("b");
		private var rgblabel:TextField = createLabel("0123456789#abcdef");
		
		public var c:Color;
		private var cimage:Sprite = new Sprite;
		private var btnimage1:ImageWithBtn;
		private var btnimage2:ImageWithBtn;
		private var btnimage3:ImageWithBtn;
		
		public var hsvArr:Array=[.99,.5,.99];
		private var lastHsvArr:Array = [ -1, -1, -1];
		
		public function ColorSelector() 
		{
			btnimage1 = new ImageWithBtn(100, 10, false, true);
			addChild(btnimage1);
			btnimage1.addEventListener(Event.CHANGE, btnimage1_change);
			var bmd:BitmapData = btnimage1.bmd;
			c = new Color;
			for (var x:int = 0; x < bmd.width;x++ ) {
				var hex:uint= c.fromHSV(x / bmd.width, 1, 1).toHex();
				for (var y:int = 0; y < bmd.height;y++ ) {
					bmd.setPixel(x, y, hex);
				}
			}
			
			btnimage2 = new ImageWithBtn(100, 100, false, false);
			addChild(btnimage2);
			btnimage2.y = 20;
			btnimage2.addEventListener(Event.CHANGE, btnimage2_change);
			
			btnimage3 = new ImageWithBtn(100, 100, false, false);
			addChild(btnimage3);
			btnimage3.y = 130;
			btnimage3.addEventListener(Event.CHANGE, btnimage3_change);
			
			addChild(cimage);
			cimage.x = 110;
			
			addChild(rlabel);
			addChild(glabel);
			addChild(blabel);
			addChild(rgblabel);
			rlabel.y = 0;
			glabel.y = 30;
			blabel.y = 60;
			rgblabel.y = 90;
			rlabel.x = glabel.x = blabel.x =rgblabel.x= 170;
			
			update();
		}
		
		private function createLabel(restrict:String=null):TextField {
			var label:TextField = new TextField;
			label.restrict = restrict;
			label.width = 50;
			label.height = 20;
			label.border = true;
			label.borderColor = 0x333333;
			label.background = true;
			label.backgroundColor = 0xffffff;
			label.type = TextFieldType.INPUT;
			return label;
		}
		
		private function createStepper(label:String=null):NumericStepper {
			var ns:NumericStepper = new NumericStepper(label, 1, 01, 0, 0xff,50,20);
			ns.addEventListener(Event.CHANGE, label_change);
			return ns;
		}
		
		private function label_change(e:Event):void 
		{
			var tf:Object = e.currentTarget;
			if (tf==rgblabel) {
				var str:String = tf.text.replace(/#/g, "");
				var value:uint =Math.min(0xffffff, parseInt(str, 16));
				tf.text = "#"+value.toString(16);
			}else {
				var r:int = Math.min(255,int(rlabel.value));
				var g:int = Math.min(255,int(glabel.value));
				var b:int = Math.min(255, int(blabel.value));
				value=(r << 16) | (g << 8) | b;
				rlabel.value = r;
				glabel.value = g;
				blabel.value = b;
			}
			
			c.fromHex(value);
			hsvArr = c.toHSV();
			update();
			dispatchChangeEvent()
		}
		
		private function btnimage2_change(e:Event):void 
		{
			hsvArr[1] = btnimage2.pos.x / btnimage2.w;
			hsvArr[2] =1- btnimage2.pos.y / btnimage2.h;
			update();
			dispatchChangeEvent()
		}
		
		private function btnimage3_change(e:Event):void 
		{
			var cx:Number = btnimage3.w / 2;
			var cy:Number = btnimage3.h / 2;
			var r:Number = cx;
			var dx:Number = cx - btnimage3.pos.x;
			var dy:Number = cy - btnimage3.pos.y;
			var d:Number = Math.sqrt(dx * dx + dy * dy);
			var nh:Number = Math.atan2(dy, dx) / Math.PI/2;
			if (nh < 0) nh += 1;
			hsvArr[0] = nh;
			hsvArr[1] = Math.min(.99, d / r);
			update();
			dispatchChangeEvent()
		}
		
		private function btnimage1_change(e:Event):void 
		{
			hsvArr[0] = btnimage1.pos.x / btnimage1.w;
			update();
			dispatchChangeEvent()
		}
		
		public function dispatchChangeEvent():void {
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function update():void {
			var h:Number = hsvArr[0];
			var s:Number = hsvArr[1];
			var v:Number = hsvArr[2];
			btnimage1.pos.x = h * btnimage1.w;
			btnimage1.update();
			btnimage2.pos.x = s * btnimage2.w;
			btnimage2.pos.y = (1-v) * btnimage2.h;
			btnimage2.update();
			
			if(lastHsvArr[0]!=h){
				var bmd:BitmapData = btnimage2.bmd;
				var bmdVec:Vector.<uint> = btnimage2.bmdVec;
				var bmdw:int = btnimage2.w;
				//h
				for (var i:int = 0, len:int = bmdVec.length; i < len;i++ ) {
					var x:int = i % bmdw;
					var y:int = i / bmdw;
					bmdVec[i] = c.fromHSV(h, x / bmd.width, 1 - y / bmd.height).toHex();
				}
				bmd.setVector(bmd.rect, bmdVec);
			}
			
			bmd = btnimage3.bmd;
			var cx:Number = btnimage3.w / 2;
			var cy:Number = btnimage3.h / 2;
			var r:Number = cx;
			var a:Number = h * 2 * Math.PI;
			a += Math.PI;
			btnimage3.pos.x = cx + r * Math.cos(a)*s;
			btnimage3.pos.y = cy + r * Math.sin(a)*s;
			btnimage3.update();
			
			//v
			if(lastHsvArr[2]!=v){
				bmdVec = btnimage3.bmdVec;
				bmdw = btnimage3.w;
				for (i = 0, len = bmdVec.length; i < len;i++ ) {
					x = i % bmdw;
					y = i / bmdw;
					var dx:Number = cx - x;
					var dy:Number = cy - y;
					var d:Number = Math.sqrt(dx * dx + dy * dy);
					if (d < r) {
						var nh:Number = Math.atan2(dy, dx) / Math.PI/2;
						if (nh < 0) nh += 1;
						bmdVec[i]= c.fromHSV(nh, d / r, v).toHex();
					}else {
						bmdVec[i] = 0;
					}
				}
				bmd.setVector(bmd.rect, bmdVec);
			}
			
			c.fromHSV(h, s, v);
			rlabel.value = Math.round(c.r)
			glabel.value = Math.round(c.g);
			blabel.value = Math.round(c.b);
			rgblabel.text = "#" + c.toHex().toString(16);
			
			cimage.graphics.clear();
			cimage.graphics.beginFill(c.toHex());
			cimage.graphics.drawRect(0, 0, 50, 50);
			
			lastHsvArr = [].concat(hsvArr);
		}
		
	}

}


