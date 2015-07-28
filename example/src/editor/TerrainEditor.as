package editor
{
	import com.bit101.components.CheckBox;
	import com.bit101.components.HBox;
	import com.bit101.components.HUISlider;
	import com.bit101.components.PushButton;
	import com.bit101.components.RadioButton;
	import com.bit101.components.VBox;
	import com.bit101.components.Window;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.GradientType;
	import flash.display.PNGEncoderOptions;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TerrainEditor extends Sprite
	{
		public static const CHANGE:String = "tchange";
		
		private var brush:Sprite;
		private var brushBmd:BitmapData;
		private var bgLayer:Sprite;
		public var heightBitmapData:BitmapData;
		public var colorBitmapData:BitmapData;
		private var brushSize:int;
		private var brushSizeSD:HUISlider;
		private var ct:ColorTransform = new ColorTransform(.02, .02, .02, 1);
		private var ctSD:HUISlider;
		private var isADDCB:CheckBox;
		private var isSmoothingCB:CheckBox;
		private var isColorCB:CheckBox;
		//private var smooth
		public function TerrainEditor() 
		{
			brush = new Sprite;
			brushSize = 50;
			
			heightBitmapData = new BitmapData(512, 512, false, 0x7f);
			colorBitmapData = new BitmapData(512, 512, false, 0xff);
			bgLayer = new Sprite;
			//addChild(bgLayer);
			bgLayer.addChild(new Bitmap(heightBitmapData));
			bgLayer.addEventListener(MouseEvent.MOUSE_MOVE, bgLayer_mouseMove);
			
			var w:Window = new Window(this);
			w.setSize(200, 350);
			var vbox:VBox = new VBox(w.content,5,5);
			brushSizeSD = new HUISlider(vbox, 0, 0, "brushSize", onBrushSizeChange);
			brushSizeSD.tick = 1;
			brushSizeSD.labelPrecision = 0;
			brushSizeSD.setSliderParams(1, 200, brushSize);
			
			ctSD = new HUISlider(vbox, 0, 0, "ct", onCTChange);
			ctSD.tick = .01;
			ctSD.labelPrecision = 2;
			ctSD.setSliderParams(0, 1, ct.blueMultiplier);
			
			isADDCB = new CheckBox(vbox, 0, 0, "isADD");
			isADDCB.selected = true;
			isSmoothingCB = new CheckBox(vbox, 0, 0, "isSmoothing");
			isColorCB = new CheckBox(vbox, 0, 0, "isColor");
			
			new PushButton(vbox, 0, 0, "save", onSave);
			onBrushSizeChange(null);
			
			new PushButton(vbox, 0, 0, "showBG", onShowBG);
			
			var hbox:HBox = new HBox(vbox);
			new RadioButton(hbox, 0, 0, "image0");
			new RadioButton(hbox, 0, 0, "image1");
			new RadioButton(hbox, 0, 0, "image2");
			new RadioButton(hbox, 0, 0, "image3");
		}
		
		private function onShowBG(e:Event):void 
		{
			if (bgLayer.parent) {
				bgLayer.parent.removeChild(bgLayer);
			}else {
				addChildAt(bgLayer, 0);
			}
		}
		
		public function draw(x:Number, y:Number):void {
			var bg:BitmapData = isColorCB.selected?colorBitmapData:heightBitmapData;
			if (isSmoothingCB.selected) {
				var blurBMD:BitmapData = new BitmapData(brushSize, brushSize, false, 0);
				var rect:Rectangle = new Rectangle(x * bg.width - brushSize / 2, y * bg.height - brushSize / 2, brushSize, brushSize);
				blurBMD.applyFilter(bg,rect, new Point(0, 0), new BlurFilter(2, 2, 3));
				matr = new Matrix;
				matr.translate( -brushSize / 2, -brushSize / 2);
				matr.translate(x * bg.width, y * bg.height);
				var clone:BitmapData = new BitmapData(brushSize, brushSize, false, 0);
				clone.copyPixels(bg, rect, new Point);
				clone.draw(blurBMD, null, null, BlendMode.SUBTRACT);
				bg.draw(blurBMD, matr, ct, BlendMode.ADD, null, true);
			}else {
				var matr:Matrix = new Matrix;
				matr.translate( -brushSize / 2, -brushSize / 2);
				matr.translate(x*bg.width, y*bg.height);
				bg.draw(brush, matr, ct, isADDCB.selected?BlendMode.ADD:BlendMode.SUBTRACT, null, true);
				
			}
			dispatchEvent(new Event(CHANGE));
		}
		
		public function setTextures(terrainTextureSets:Array):void 
		{
			
		}
		
		private function onCTChange(e:Event):void 
		{
			ct.redMultiplier = ct.greenMultiplier = ct.blueMultiplier = ctSD.value;
		}
		
		private function onBrushSizeChange(e:Event):void 
		{
			var matr:Matrix = new Matrix;
			brushSize = brushSizeSD.value;
			matr.createGradientBox(brushSize, brushSize, 0, 0, 0);
			brush.graphics.clear();
			brush.graphics.beginGradientFill(GradientType.RADIAL, [0xff,0], [1, 0], [0, 0xff],matr);
			brush.graphics.drawRect(0, 0, brushSize, brushSize);
			brushBmd = new BitmapData(brushSize, brushSize, true, 0);
			brushBmd.draw(brush);
		}
		
		private function bgLayer_mouseMove(e:MouseEvent):void 
		{
			if (e.buttonDown) {
				var bg:BitmapData = isColorCB.selected?colorBitmapData:heightBitmapData;
				draw(mouseX / bg.width, mouseY / bg.height);
			}
		}
		
		private function onSave(e:Event):void 
		{
			var file:FileReference = new FileReference;
			var bg:BitmapData = isColorCB.selected?colorBitmapData:heightBitmapData;
			file.save(bg.encode(bg.rect, new PNGEncoderOptions), "t.png");
		}
	}

}