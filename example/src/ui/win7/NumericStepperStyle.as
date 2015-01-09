package ui.win7 
{
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import ui.NumericStepper;
	import ui.Style;
	import ui.UIComponent;
	/**
	 * ...
	 * @author lizhi
	 */
	public class NumericStepperStyle extends Style
	{
		
		public function NumericStepperStyle() 
		{
			
		}
		
		override public function init(component:UIComponent):void 
		{
			var step:NumericStepper = component as NumericStepper;
			component._height = 20;
			var format:TextFormat = new TextFormat(Win7Style.fontName);
			step.label.defaultTextFormat = new TextFormat(format.font, null, null, null, null, null, null, null, TextFormatAlign.RIGHT);
			step.label.setTextFormat(step.label.defaultTextFormat);
			
			step.input.defaultTextFormat = format;
			step.input.setTextFormat(step.input.defaultTextFormat);
			step.input.borderColor = 0x4DC5FF;
			step.valueLabel.defaultTextFormat =  new TextFormat(format.font, null, null, null, null, true);
			step.valueLabel.setTextFormat(step.valueLabel.defaultTextFormat);
			step.valueLabel.backgroundColor = 0x4DC5FF;
			step.valueLabel.textColor = 0x0080C0;
		}
		
	}

}