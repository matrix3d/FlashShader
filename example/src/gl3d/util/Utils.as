package gl3d.util 
{
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import ui.Color;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Utils 
	{
		
		public function Utils() 
		{
			
		}
		
		public static function createNormalMap(bmd:BitmapData,scale:Number=5,kUseTwoMaps:Boolean=true):BitmapData {
			var bmd2:BitmapData = bmd.clone();
			var valuePX:Color = new Color;
			var valueNX:Color = new Color;
			var valuePY:Color = new Color;
			var valueNY:Color = new Color;
			var neighbors:Color = new Color;
			var slope:Color = new Color;
			var scale:Number = 4.5;
			var kUseTwoMaps:Boolean = true;
			for (var x:int = 0; x < bmd.width;x++ ) {
				for (var y:int = 0; y < bmd.height; y++ ) {
					valuePX.fromHex(bmd.getPixel(x+1,y));
					valueNX.fromHex(bmd.getPixel(x-1,y));
					valuePY.fromHex(bmd.getPixel(x,y+1));
					valueNY.fromHex(bmd.getPixel(x,y-1));
					valuePX.scale(1 / 0xff);
					valueNX.scale(1 / 0xff);
					valuePY.scale(1 / 0xff);
					valueNY.scale(1 / 0xff);
					
					if (kUseTwoMaps) {
						var factor:Number = 1.0 / (2.0 * 255.0); // 255.0 * 2.0
						// Reconstruct the high-precision values from the low precision values
						valuePX.r += 255.0 * (valuePX.b - 0.5);
						valueNX.r += 255.0 * (valueNX.b - 0.5);
						valuePY.r += 255.0 * (valuePY.b - 0.5);
						valueNY.r += 255.0 * (valueNY.b - 0.5);
					}else {
						factor = 1.0 / 2.0;
					}
					// Take into account the boundary conditions in the pool
					
					neighbors.r = valuePX.r * (valuePX.g) + (1.0 - valuePX.g) * valueNX.r; // Enforce the boundary conditions as mirror reflections
					neighbors.g = valuePY.r * (valuePY.g) + (1.0 - valuePY.g) * valueNY.r; // Enforce the boundary conditions as mirror reflections
					neighbors.b = valueNX.r * (valueNX.g) + (1.0 - valueNX.g) * valuePX.r; // Enforce the boundary conditions as mirror reflections
					var w:Number = valueNY.r * (valueNY.g) + (1.0 - valueNY.g) * valuePY.r; // Enforce the boundary conditions as mirror reflections
					 
					slope.fromRGB(scale * (neighbors.b - neighbors.r) * factor, 
										   scale * (w - neighbors.g) * factor, 1.0);
					
					slope.r *= 5.0;
					slope.g *= 5.0;
					slope.r += .5;
					slope.g += .5;
					slope.scale(0xff);
					bmd2.setPixel(x,y,slope.toHex() );
				}
			}
			return bmd2;
		}
		
		public static function tracebyte(byte:ByteArray,isTrace:Boolean=true):Array {
			var a:Array = [];
			for (var i:int = 0; i < byte.length;i++ ) {
				a.push(byte[i]);
			}
			if(isTrace)
			trace(a);
			return a;
		}
		
		public static function compareByte(b1:ByteArray, b2:ByteArray):Boolean {
			return (tracebyte(b1,false)+"")==(tracebyte(b2,false)+"")
		}
		
		public static function getID(obj:Object):String {
			try
			{
				FakeClass(obj);
			}
			catch (e:Error)
			{
				return String( e ).replace( /.*(@\w+).*/, "$1" );
			}
			return null;
		}
		
	}

}
internal final class FakeClass { }