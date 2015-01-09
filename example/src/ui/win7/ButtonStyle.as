package ui.win7 
{
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import ui.Button;
	import ui.Color;
	import ui.Style;
	import ui.UIComponent;
	/**
	 * ...
	 * @author lizhi
	 */
	public class ButtonStyle extends Style
	{
		private static var overColorTransform:ColorTransform = new ColorTransform(1, 1, 1, 1, 0, 30, 30);
		private static var outColorTransform:ColorTransform = new ColorTransform();
		private static var downColorTransform:ColorTransform = new ColorTransform();
		private static var outfilters:Array = [];
		private static var overfilters:Array = [];
		private static var downfilters:Array = [new DropShadowFilter(1,90,0,.7,4,4,1,1,true)]
		
		public function ButtonStyle() 
		{
			
		}
		
		override public function update(component:UIComponent):void 
		{
			var label:TextField = (component as Button).textfield;
			label.width = component.width - label.x * 2;
			label.height = 24;
			label.y = component.height / 2 - label.height / 2+1;
			Win7Style.drawBG(component.graphics, component.width,component.height,0,0,0,0x6e6e6e);
		}
		
		override public function init(component:UIComponent):void 
		{
			var label:TextField = (component as Button).textfield;
			label.defaultTextFormat = new TextFormat(Win7Style.fontName,null,null,null,null,null,null,null,TextFormatAlign.CENTER);
			label.text = "button";
			label.x = 2;
			component._width = 80;
			component._height = 20;
			label.mouseEnabled = label.selectable = label.mouseWheelEnabled = false;
			component.addEventListener(MouseEvent.ROLL_OVER, s_rollOver);
			component.addEventListener(MouseEvent.ROLL_OUT, s_rollOut);
			component.addEventListener(MouseEvent.MOUSE_DOWN, s_mouseDown);
			component.addEventListener(MouseEvent.MOUSE_UP, s_mouseUp);
			component.filters = outfilters;
		}
		
		private static function s_mouseDown(e:MouseEvent):void 
		{
			var s:Sprite = e.currentTarget as Sprite;
			s.filters = downfilters;
		}
		
		private static function s_rollOut(e:MouseEvent):void 
		{
			var s:Sprite = e.currentTarget as Sprite;
			s.filters = outfilters;
			s.transform.colorTransform = outColorTransform;
		}
		
		private static function s_rollOver(e:MouseEvent):void 
		{
			var s:Sprite = e.currentTarget as Sprite;
			s.transform.colorTransform = overColorTransform;
		}
		
		static private function s_mouseUp(e:MouseEvent):void 
		{
			var s:Sprite = e.currentTarget as Sprite;
			s.filters = outfilters;
		}
		
	}

}