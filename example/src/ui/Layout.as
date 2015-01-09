package ui 
{
	import flash.display.DisplayObject;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Layout 
	{
		
		public function Layout() 
		{
			
		}
		
		static public function doVLayout(os:Array, startX:Number=0, startY:Number=0, spacing:Number = 5):void {
			var y:Number = startY;
			for each(var o:DisplayObject in os) {
				o.x = startX;
				o.y = y;
				y += o.height+spacing;
			}
		}
		static public function doHLayout(os:Array, startX:Number=0, startY:Number=0, spacing:Number = 5):void {
			var x:Number = startX;
			for each(var o:DisplayObject in os) {
				o.x = x;
				o.y = startY;
				x += o.width+spacing;
			}
		}
	}

}