package ui.win7 
{
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import ui.Color;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Win7Style 
	{
		public static var fontName:String = "微软雅黑,simsun,宋体";
		public function Win7Style() 
		{
			
		}
		
		public static function drawBG(graphics:Graphics,w:Number,h:Number,tx:Number=0,ty:Number=0,rotation:Number=0,lineColor:uint=0x6E6E6E,p:Number=.94):void {
			graphics.clear();
			graphics.lineStyle(0, lineColor );
			tx = Math.round(tx)-.5;
			ty = Math.round(ty)-.5;
			var matr:Matrix = new Matrix;
			matr.createGradientBox(w, h, Math.PI / 2+rotation*Math.PI/180,tx,ty);
			var color:Color = new Color;
			var color1:uint = 0xffffff;
			color.fromHex(color1);
			
			color.scale(p);
			var color2:uint = color.toHex();
			
			color.scale(p);
			var color3:uint = color.toHex();
			
			color.scale(p);
			var color4:uint = color.toHex();
			
			graphics.beginGradientFill(GradientType.LINEAR,[color1,color2,color3,color4],[1,1,1,1],[0,0xff/2-0xff/30,0xff/2+0xff/30,0xff],matr),
			graphics.drawRoundRect(tx, ty, w, h, 4, 4);
			graphics.endFill();
		}
		
	}

}