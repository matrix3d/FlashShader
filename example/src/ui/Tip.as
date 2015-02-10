package ui 
{
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Tip extends Sprite
	{
		public static var stage:Stage;
		public static var tip:Tip;
		public var label:TextField;
		private static var tip2part:Dictionary = new Dictionary;
		private static var timer:Timer = new Timer(500);
		private static var waitDis:InteractiveObject;
		public static var nowPart:TipPart;
		public function Tip() 
		{
			mouseChildren = mouseEnabled = false;
			label = new TextField;
			label.x = label.y = 2;
			addChild(label);
			
			label.autoSize = TextFieldAutoSize.LEFT;
			label.condenseWhite = true;
			label.multiline = true;
			var tfm:TextFormat = new TextFormat("yahei",12);
			tfm.align = TextFormatAlign.LEFT;
			label.defaultTextFormat = tfm;
			label.text = "tip";
		}
		
		public function update(part:TipPart):void {
			nowPart = part;
			var text:Object = part.text;
			if (text is Function) {
				label.htmlText = text()+"";
			}else {
				label.htmlText = text +"";
			}
			graphics.clear();
			graphics.lineStyle(0);
			graphics.beginFill(0xffffe1, .9);
			graphics.drawRoundRect(0, 0, label.width + 4, label.height + 4,4,4);
		}
		
		public static function setTip(dis:InteractiveObject, text:Object):void {
			
			if(!text){
				dis.removeEventListener(MouseEvent.MOUSE_OVER, dis_mouseOver);
				dis.removeEventListener(MouseEvent.MOUSE_OUT, dis_mouseOut);
				
				tip2part[dis] = null;
				delete tip2part[dis];
				
				if(waitDis==dis){
					waitDis=null;
				}
				
				return;
			}
			var part:TipPart = new TipPart;
			part.text = text;
			tip2part[dis] = part;
			dis.addEventListener(MouseEvent.MOUSE_OVER, dis_mouseOver);
			dis.addEventListener(MouseEvent.MOUSE_OUT, dis_mouseOut);
		}
		
		static private function dis_mouseOut(e:MouseEvent):void 
		{
			if (tip&&tip.parent) {
				tip.parent.removeChild(tip);
			}
			timer.stop();
			waitDis = null;
		}
		
		static private function dis_mouseOver(e:MouseEvent):void 
		{
			var dis:InteractiveObject = e.currentTarget as InteractiveObject;
			if (stage==null) {
				stage = dis.stage;
				timer.addEventListener(TimerEvent.TIMER, timer_timer);
				//stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMove);
			}
			if (stage!=null) {
				if (tip == null) tip = new Tip;
				timer.reset();
				timer.start();
				waitDis = dis;
			}
		}
		
		static private function timer_timer(e:TimerEvent):void 
		{
			stage.addChild(tip);
			var dis:InteractiveObject = waitDis;
			if(dis){
				var text:TipPart = tip2part[dis] as TipPart;
				tip.update(text);
				updatePos();
			}
			timer.stop();
		}
		
		static public function updatePos():void {
			if(tip&&stage&&tip.parent){
				tip.x =Math.min(stage.stageWidth-tip.width,  stage.mouseX+20);
				tip.y = Math.min(stage.stageHeight-tip.height, stage.mouseY + 20);
			}
		}
		
		static private function stage_mouseMove(e:MouseEvent):void 
		{
			updatePos();
		}
	}
}
class TipPart {
	public var onOverTime:Number;
	public var text:Object;
}