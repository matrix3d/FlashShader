package ui 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import gl3d.events.GLTouchEvent;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Gamepad extends Sprite
	{
		public var btn:Sprite = new Sprite;
		public var maxRadius:Number = 70;
		public var minRadius:Number = 10;
		private var nowMouseEvent:Event;
		public function Gamepad() 
		{
			addChild(btn);
			btn.graphics.beginFill(0xff);
			btn.graphics.drawCircle(0, 0, 40);
			btn.addEventListener(GLTouchEvent.TOUCH_BEGIN, btn_mouseDown);
			graphics.lineStyle(0,0xff0000);
			graphics.drawCircle(0, 0, minRadius);
			graphics.drawCircle(0, 0, maxRadius);
		}
		
		private function btn_mouseDown(e:Event):void 
		{
			nowMouseEvent = e;
			stage.addEventListener(GLTouchEvent.TOUCH_MOVE, stage_mouseMove);
			stage.addEventListener(GLTouchEvent.TOUCH_END, stage_mouseUp);
		}
		
		private function stage_mouseUp(e:Event):void 
		{
			if(GLTouchEvent.isSameTouch(nowMouseEvent,e)){
				stage.removeEventListener(GLTouchEvent.TOUCH_MOVE, stage_mouseMove);
				stage.removeEventListener(GLTouchEvent.TOUCH_END, stage_mouseUp);
				btn.x = btn.y = 0;
			}
		}
		
		private function stage_mouseMove(e:Event):void 
		{
			if(GLTouchEvent.isSameTouch(nowMouseEvent,e)){
				var p:Point = GLTouchEvent.getMousePos(e);
				var v:Vector3D = new Vector3D(p.x-x, p.y-y);
				var len:Number = Math.min(maxRadius,v.length);
				v.normalize();
				v.scaleBy(len);
				
				btn.x = v.x;
				btn.y = v.y;
			}
		}
		
		public function get speed():Vector3D {
			var v:Vector3D = new Vector3D(btn.x, btn.y);
			v.scaleBy(1/maxRadius);
			return v;
		}
		
	}

}