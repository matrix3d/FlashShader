package editor
{
	import com.bit101.components.CheckBox;
	import com.bit101.components.HUISlider;
	import com.bit101.components.PushButton;
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
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.net.FileReference;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TerrainEditor extends Sprite
	{
		private var brush:Sprite;
		private var bgLayer:Sprite;
		public var bg:BitmapData;
		private var brushSize:int;
		private var brushSizeSD:HUISlider;
		private var ct:ColorTransform = new ColorTransform(.05, .05, .05, 1);
		private var ctSD:HUISlider;
		private var isADDCB:CheckBox;
		public function TerrainEditor() 
		{
			brush = new Sprite;
			brushSize = 50;
			
			bg = new BitmapData(512, 512, false, 0x7f7f7f);
			bgLayer = new Sprite;
			addChild(bgLayer);
			bgLayer.addChild(new Bitmap(bg));
			bgLayer.addEventListener(MouseEvent.MOUSE_MOVE, bgLayer_mouseMove);
			
			var w:Window = new Window(this);
			w.setSize(200, 150);
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
			
			new PushButton(vbox, 0, 0, "save", onSave);
			onBrushSizeChange(null);
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
			brush.graphics.beginGradientFill(GradientType.RADIAL, [0xffffff,0], [1, 0], [0, 0xff],matr);
			brush.graphics.drawRect(0, 0, brushSize, brushSize);
		}
		
		private function bgLayer_mouseMove(e:MouseEvent):void 
		{
			if (e.buttonDown) {
				var matr:Matrix = new Matrix;
				matr.translate( -brushSize / 2, -brushSize / 2);
				matr.translate(mouseX, mouseY);
				bg.draw(brush, matr, ct, isADDCB.selected?BlendMode.ADD:BlendMode.SUBTRACT, null, true);
				dispatchEvent(new Event(Event.CHANGE));
			}
		}
		
		private function onSave(e:Event):void 
		{
			var file:FileReference = new FileReference;
			file.save(bg.encode(bg.rect, new PNGEncoderOptions), "t.png");
		}
	}

}