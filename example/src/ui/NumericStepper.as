package ui 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.Keyboard;
	import ui.win7.NumericStepperStyle;
	/**
	 * ...
	 * @author lizhi
	 */
	public class NumericStepper extends UIComponent
	{
		public var label:TextField;
		public var input:TextField;
		public var valueLabel:TextField;
		private var _value:Number;
		private var startMouseX:Number;
		private var startValue:Number;
		private var moved:Boolean = false;
		private var inputMode:Boolean = false;
		private var minValue:Number;
		private var maxValue:Number;
		private var speed:Number;
		private var fixed:int;
		public var inputWidth:Number;
		private var labelStr:String;
		public var labelWidth:Number;
		public function NumericStepper(labelStr:String="label",speed:Number=1,fixed:int=-1,minValue:Number=-1000000,maxValue:Number=1000000,inputWidth:Number=50,labelWidth:Number=50) 
		{
			this.labelWidth = labelWidth;
			this.inputWidth = inputWidth;
			this.labelStr = labelStr;
			this.inputWidth = inputWidth;
			this.fixed = fixed;
			this.speed = speed;
			this.maxValue = maxValue;
			this.minValue = minValue;
			
			label = new TextField;
			label.text = labelStr+"：";
			label.width = labelWidth;
			label.height = 20;
			label.selectable = label.mouseWheelEnabled = false;
			addChild(label);
			
			input = new TextField;
			input.type = TextFieldType.INPUT;
			input.x = label.x +label.width + 5;
			input.border = true;
			input.height = label.height;
			input.width = inputWidth;
			input.addEventListener(KeyboardEvent.KEY_UP, input_keyUp);
			//input.addEventListener(Event.CHANGE, input_change);
			input.restrict="-.0123456789"
			
			valueLabel = new TextField;
			valueLabel.autoSize="left";
			valueLabel.selectable = valueLabel.mouseWheelEnabled = false;
			addChild(valueLabel);
			valueLabel.x = input.x;
			valueLabel.addEventListener(MouseEvent.MOUSE_DOWN, valueLabel_mouseDown);
			valueLabel.addEventListener(MouseEvent.MOUSE_UP, valueLabel_mouseUp);
			value = 0;
			
			style = style || new NumericStepperStyle;
			super(style);
		}
		
		private function input_change(e:Event):void 
		{
			var v:Number = Number(input.text);
			if (isNaN(v)) {
				v = 0;
			}
			value = v;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function input_keyUp(e:KeyboardEvent):void 
		{
			if (e.keyCode == Keyboard.ENTER) {
				input_change(null);
				setViewMode();
			}
		}
		
		private function setInputMode():void {
			addChild(input);
			if (valueLabel.parent) {
				stage.focus = input;
				input.setSelection(0, 1000);
				valueLabel.parent.removeChild(valueLabel);
			}
			inputMode = true;
			stage.addEventListener(MouseEvent.CLICK, stage_click);
		}
		
		private function stage_click(e:MouseEvent):void 
		{
			if (inputMode && e.target != input) {
				input_change(null);
				setViewMode();
			}
		}
		
		private function setViewMode():void {
			addChild(valueLabel);
			if (input.parent) {
				input.parent.removeChild(input);
				stage.focus = stage;
			}
			inputMode = false;
		}
		
		private function valueLabel_mouseUp(e:MouseEvent):void 
		{
			if (!moved) {
				setInputMode();
			}
		}
		
		private function valueLabel_mouseDown(e:MouseEvent):void 
		{
			startMouseX = stage.mouseX;
			startValue = value;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUp);
			valueLabel.background = true;
		}
		
		private function stage_mouseUp(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUp);
			moved = false;
			valueLabel.background = false;
		}
		
		private function stage_mouseMove(e:MouseEvent):void 
		{
			value = (stage.mouseX - startMouseX)*speed + startValue;
			moved = true;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get value():Number 
		{
			return _value;
		}
		
		public function set value(value:Number):void 
		{
			value=Math.max(Math.min(maxValue,value),minValue)
			_value = value;
			if (fixed >= 0) {
				var fixedStr:String = value.toFixed(fixed);
				if (value.toString()!=fixedStr) {
					_value = Number(fixedStr);
				}
			}
			input.text = valueLabel.text = _value+"";
		}
		
	}

}