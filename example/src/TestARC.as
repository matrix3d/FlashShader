package 
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.text.TextField;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestARC extends Sprite
	{
		private var cx:Number;
		private var cy:Number;
		private var r:Number = 150;
		private var a:Number = 30;
		private var rot:Number = 0;
		private var poss:Array = [];
		public function TestARC() 
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			cx = 300;
			cy = 300;
			addEventListener(Event.ENTER_FRAME, enterFrame);
			
			for (var i:int = 0; i < 1000;i++ ){
				poss.push(new Point(600*Math.random(),600*Math.random()));
			}
			
			trace(Math.cos(30 / 180 * Math.PI));
			trace(Math.acos(0.8660254037844387));
			trace(Math.cos(0.5235987755982987));
		}
		
		private function enterFrame(e:Event):void 
		{
			
			rot++;
			
			graphics.clear();
			graphics.lineStyle(0);
			graphics.drawCircle(cx, cy, r);
			
			
			graphics.moveTo(cx, cy);
			graphics.lineTo(cx+r*Math.cos((rot+a)*Math.PI/180),cy+r*Math.sin((rot+a)*Math.PI/180));
			graphics.moveTo(cx, cy);
			graphics.lineTo(cx+r*Math.cos((rot-a)*Math.PI/180),cy+r*Math.sin((rot-a)*Math.PI/180));
			
			var v1:Point = new Point(Math.cos(rot*Math.PI/180),Math.sin(rot*Math.PI/180));
			for each(var p:Point in poss){
				var v2x:Number = p.x - cx;
				var v2y:Number = p.y - cy;
				var len:Number = Math.sqrt(v2x * v2x + v2y * v2y);
				v2x /= len;
				v2y /= len;
				var dv:Number = v2x * v1.x + v2y * v1.y;
				if (len<r&&dv>Math.cos(a*Math.PI/180)){
					graphics.lineStyle(0, 0xff0000);
				}else{
					graphics.lineStyle(0, 0xff);
				}
				graphics.drawCircle(p.x, p.y, 2);
			}
		}
		
	}

}