package ui 
{
	/**
	 * ...
	 * @author lizhi
	 */
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	public class ImageWithBtn extends Sprite {
		private var lockX:Boolean;
		private var lockY:Boolean;
		public var w:Number;
		public var h:Number;
		public var bmd:BitmapData;
		public var bmdVec:Vector.<uint>;
		private var btn:Sprite;
		private var _pos:Point = new Point;
		
		private var startPos:Point = new Point;
		private var startMousePos:Point = new Point;
		public function ImageWithBtn(w:Number,h:Number,lockX:Boolean,lockY:Boolean) {
			this.h = h;
			this.w = w;
			this.lockY = lockY;
			this.lockX = lockX;
			bmd = new BitmapData(w, h, false, 0);
			bmdVec = bmd.getVector(bmd.rect);
			addChild(new Bitmap(bmd));
			btn = new Sprite;
			btn.graphics.beginFill(0, .5);
			btn.graphics.lineStyle(0, 0xffffff);
			btn.graphics.drawCircle(0, 0, 5);
			addChild(btn);
			addEventListener(MouseEvent.MOUSE_DOWN, btn_mouseDown);
			update();
		}
		
		private function btn_mouseDown(e:MouseEvent):void 
		{
			pos.x = mouseX;
			pos.y=mouseY
			startPos.x = pos.x;
			startPos.y = pos.y;
			startMousePos.x = mouseX;
			startMousePos.y = mouseY;
			
			btn.stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMove);
			btn.stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUp);
			stage_mouseMove(null);
		}
		
		private function stage_mouseUp(e:MouseEvent):void 
		{
			btn.stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMove);
			btn.stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUp);
		}
		
		private function stage_mouseMove(e:MouseEvent):void 
		{
			pos.x = startPos.x + mouseX - startMousePos.x;
			pos.y = startPos.y + mouseY - startMousePos.y;
			update();
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get pos():Point 
		{
			return _pos;
		}
		
		public function set pos(value:Point):void 
		{
			_pos = value;
		}
		
		public function update():void {
			if (lockX) {
				pos.x = w/2;
			}
			if (lockY) {
				pos.y = h/2;
			}
			pos.x = Math.min(Math.max(0, pos.x), w-1);
			pos.y = Math.min(Math.max(0, pos.y), h-1);
			
			btn.x = pos.x;
			btn.y = pos.y;
		}
	}

}