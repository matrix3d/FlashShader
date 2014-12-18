package gl3d.events 
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Point;
	import flash.ui.Multitouch;
	/**
	 * ...
	 * @author lizhi
	 */
	public class GLTouchEvent
	{
		public function GLTouchEvent() 
		{
		}
		
		static public function get TOUCH_BEGIN():String 
		{
			if (Multitouch.supportsTouchEvents) {
				return TouchEvent.TOUCH_BEGIN;
			}
			return MouseEvent.MOUSE_DOWN;
		}
		
		static public function get TOUCH_END():String 
		{
			if (Multitouch.supportsTouchEvents) {
				return TouchEvent.TOUCH_END;
			}
			return MouseEvent.MOUSE_UP;
		}
		
		static public function get TOUCH_MOVE():String 
		{
			if (Multitouch.supportsTouchEvents) {
				return TouchEvent.TOUCH_MOVE;
			}
			return MouseEvent.MOUSE_MOVE;
		}
		
		static public function getMousePos(e:Event):Point {
			if (e is TouchEvent) {
				var te:TouchEvent = e.currentTarget as TouchEvent;
				return new Point(te.localX,te.localY);
			}
			var t:DisplayObject = e.currentTarget as DisplayObject;
			return new Point(t.mouseX,t.mouseY);
		}
		
		static public function isSameTouch(e1:Event, e2:Event):Boolean {
			if ((e1 is TouchEvent)&&(e2 is TouchEvent)) {
				var te1:TouchEvent = e1 as TouchEvent;
				var te2:TouchEvent = e2 as TouchEvent;
				return te1.touchPointID == te2.touchPointID;
			}
			return true;
		}
	}

}