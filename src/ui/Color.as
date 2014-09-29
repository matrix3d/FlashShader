package ui 
{
	/**
	 * ...
	 * @author lizhi
	 */
	public class Color {
	public var r:Number;
	public var g:Number;
	public var b:Number;
		public function fromHex(hex:uint=0):void {
			r = (hex >> 16) & 0xff;
			g = (hex >> 8) & 0xff;
			b = hex & 0xff;
		}
		
		public function fromRGB(r:Number=0, g:Number=0, b:Number=0):Color {
			this.r = r;
			this.g = g;
			this.b = b;
			return this;
		}
		
		public function fromHSV(h:Number, s:Number, v:Number):Color {
			var R:Number, G:Number, B:Number;
			if (s == 0) {
				R = G = B = v;
			}else{
				var h6:Number = h * 6;
				var i:int = h6;
				var f:Number = h6 - i;
				var a:Number = v * ( 1 - s )
				var b:Number = v * ( 1 - s * f )
				var c:Number = v * ( 1 - s * (1 - f ) )
				switch(i){
					case 0: R = v; G = c; B = a; break;
					case 1: R = b; G = v; B = a;break;
					case 2: R = a; G = v; B = c;break;
					case 3: R = a; G = b; B = v;break;
					case 4: R = c; G = a; B = v;break;
					case 5: R = v; G = a; B = b;break;
				}
			}
			r = R * 0xff;
			g = G * 0xff;
			this.b = B * 0xff;
			return this;
		}
		
		public function toHSV():Array {
			var R:Number = r / 0xff;
			var G:Number = g / 0xff;
			var B:Number = b / 0xff;
			var max:Number = Math.max(R, G, B);
			var min:Number = Math.min(R, G, B);
			var v:Number = max;
			if(max==min)return [0,0,max]
			var s:Number = (max - min) / max;
			if (R == max) var h:Number = (G - B) / (max - min) / 6;
			if (G == max) h = 1/3 + (B - R) / (max - min) / 6;
			if (B == max) h = 2 / 3 +(R - G) / (max - min) / 6;
			if (h < 0) h += 1;
			return [h, s, v];
		}
		
		public function toHex():uint {
			return (Math.round(r) << 16) | (Math.round(g) << 8) | Math.round(b);
		}
		
	}

}