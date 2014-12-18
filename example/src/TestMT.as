package  
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.text.TextField;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.describeType;
	import ui.Gamepad;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestMT extends Sprite
	{
		private var debug:TextField = new TextField;
		public function TestMT() 
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			debug.autoSize = "left";
			addChild(debug);
			
			var gp:Gamepad = new Gamepad;
			gp.x = 200;
			gp.y = 200;
			addChild(gp);
			
			var s:Sprite = new Sprite;
			s.graphics.beginFill(0,.1);
			s.graphics.drawRect(700, 0, 400, 400);
			addChild(s);
			
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			//s.addEventListener(TouchEvent.TOUCH_BEGIN, touchBegin);
		}
		
		private function stage_touchEnd(e:TouchEvent):void 
		{
			log(e);
		}
		
		private function touchBegin(e:TouchEvent):void 
		{
			log(e);
			stage.addEventListener(TouchEvent.TOUCH_MOVE, stage_touchMove);
			stage.addEventListener(TouchEvent.TOUCH_END, stage_touchEnd);
		}
		
		private function stage_touchMove(e:TouchEvent):void 
		{
			log(e);
		}
		
		
		private function log(t:Object):void {
			debug.appendText(t + "\n");
			debug.scrollV = debug.maxScrollV;
			
		}
		
	}

}