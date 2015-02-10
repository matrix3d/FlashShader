package ui.tree {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TreeOpenBtn extends Sprite
	{
		private static var addBmd:BitmapData;
		private static var plusBmd:BitmapData;
		private static var triBmd:BitmapData;
		private var image:Bitmap = new Bitmap;
		private var isMenuModel:Boolean;
		public function TreeOpenBtn(isMenuModel:Boolean=false) 
		{
			this.isMenuModel = isMenuModel;
			addChild(image);
			if (addBmd==null) {
				addBmd = new BitmapData(16, 16, true, 0);
				plusBmd = new BitmapData(16, 16, true, 0);
				triBmd = new BitmapData(16, 16, true, 0);
				var pen:Sprite = new Sprite;
				var openBtn:TextField;
				openBtn = new TextField();
				openBtn.autoSize = "left";
				openBtn.defaultTextFormat = new TextFormat("宋体");
				openBtn.textColor=0x4b63a7;
				openBtn.selectable = openBtn.mouseWheelEnabled = false;
				openBtn.x = 4;
				openBtn.y = 1;
				pen.addChild(openBtn);
				
				pen.graphics.lineStyle(0,0x919191);
				pen.graphics.beginFill(0xededed);
				var o:Number = 4;
				pen.graphics.drawRect(0 + o, 0 + o, 16 - o * 2, 16 - o * 2);
				openBtn.text="+"
				addBmd.draw(pen);
				openBtn.text = "-";
				plusBmd.draw(pen);
				
				openBtn.text = "";
				pen.graphics.clear();
				pen.graphics.beginFill(0);
				pen.graphics.moveTo(o,o);
				pen.graphics.lineTo(o,16-o);
				pen.graphics.lineTo(16-2*o,8);
				pen.graphics.lineTo(o,o);
				triBmd.draw(pen);
			}
			closed = true;
		}
		
		public function set closed(v:Boolean):void {
			image.bitmapData = isMenuModel?triBmd:(v?addBmd:plusBmd);
		} 
		
	}

}