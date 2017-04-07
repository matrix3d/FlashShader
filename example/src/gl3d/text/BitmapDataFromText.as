package gl3d.text 
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextLineMetrics;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.TextBaseline;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	/**
	 * ...
	 * @author lizhi
	 */
	public class BitmapDataFromText 
	{
		private static var block:TextBlock = new TextBlock;
		public var bmd:BitmapData;
		//public var xoffset:int;
		//public var yoffset:int;
		public var width:int;
		public var height:int;
		public var xadvance:int;
		public var lineHeight:int;
		public function BitmapDataFromText(txt:String,fontSize:int=12,fontName:String="_serif") 
		{
			var te:TextElement = new TextElement(txt, new ElementFormat(new FontDescription(fontName), fontSize,0xffffff));
			block.content = te;
			var textline:flash.text.engine.TextLine = block.createTextLine();
			width = Math.ceil(textline.width);
			height = Math.ceil(Math.ceil(textline.ascent) + Math.ceil(textline.descent));
			bmd = new BitmapData(width, height, true, 0);
			bmd.draw(textline,new Matrix(1,0,0,1,0,Math.ceil(textline.ascent)),null,null,null,true);
			xadvance = width;
			lineHeight = height;
		}
	}
}