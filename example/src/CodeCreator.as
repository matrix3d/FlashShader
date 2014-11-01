package  
{
	import flash.display.Sprite;
	/**
	 * ...
	 * @author lizhi
	 */
	public class CodeCreator extends Sprite
	{
		
		public function CodeCreator() 
		{
			var ops:Array= ["mov","add","sub","mul","div","rcp","min","max","frc","sqt","rsq","pow","log","exp","nrm","sin","cos","crs","dp3","dp4","abs","neg","sat","m33","m44","m34","ddx","ddy","ife","ine","ifg","ifl","els","eif","ted","kil","tex","sge","slt","sgn","seq","sne"]
			for each(var op:String in ops) {
				//trace(op);
			}
			
			var xyzw:String = "xyzw";
			for (var i0:int = 0; i0 < xyzw.length; i0++ ) {
				var c:String = xyzw.charAt(i0);
				ccode(c);
				for (var i1:int = 0; i1 < xyzw.length; i1++ ) {
					c = xyzw.charAt(i0) + xyzw.charAt(i1);
					ccode(c);
					for (var i2:int = 0; i2 < xyzw.length; i2++ ) {
						c = xyzw.charAt(i0) + xyzw.charAt(i1) + xyzw.charAt(i2);
						ccode(c);
						for (var i3:int = 0; i3 < xyzw.length; i3++ ) {								
							c = xyzw.charAt(i0) + xyzw.charAt(i1) + xyzw.charAt(i2) +xyzw.charAt(i3);
							ccode(c);
						}
					}
				}
			}
			
		}
		
		private function ccode(c:String):void {
			//trace("public function get "+c+"():Var {return c(\""+c+"\");}");
			//trace("public var "+c+"(get_"+c+", never) : Var;");
			trace("public function get_"+c+"() : Var {return c(\""+c+"\");}");
		}
		
		//private function get xxx():Var {return c("xxx");}
		
	}

}