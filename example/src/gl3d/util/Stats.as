package gl3d.util 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.ui.ContextMenuItem;
	import flash.utils.getTimer;
	import gl3d.core.View3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Stats extends Sprite
	{
		private var view:View3D;
		public var tf:TextField;
		public var fpsCounter:int = 0;
		public var fps:int = 0;
		public var lastTime:int = -10000;
		public var maxMem:int = 0;
		private var fpss:Array = [];
		public function Stats(view:View3D=null) 
		{
			this.view = view;
			
			addEventListener(Event.ENTER_FRAME, enterFrame);
			tf = new TextField();
			tf.mouseEnabled = tf.selectable = false;
			tf.defaultTextFormat = new TextFormat("Courier New",Capabilities.screenDPI > 200?24:12);
			addChild(tf);
			tf.autoSize = TextFieldAutoSize.LEFT;
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			
		}
		
		private function antiAliasItem_select(e:Event):void 
		{
			var antiAliasItem:ContextMenuItem = e.currentTarget as ContextMenuItem;
			var v:int = int(antiAliasItem.caption.replace("antiAlias", ""));
			view.antiAlias = v;
		}

		private function mouseDown(e:MouseEvent):void 
		{
			if (stage != null) {
				startDrag(false,new Rectangle(0,0,stage.stageWidth-width,stage.stageHeight-height));
				stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUp);
			}
		}

		private function stage_mouseUp(e:MouseEvent):void 
		{
			if(stage!=null)stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUp);
			stopDrag();
		}

		private function enterFrame(e:Event):void 
		{
			var time:int = getTimer();
			if (time-1000>lastTime) {
				fps = fpsCounter;
				if (fps > 0) {
					fps--;
				}
				fpss.unshift(fps);
				if (fpss.length>200){
					fpss.length = 200;
				}
				fpsCounter = 0;
				lastTime = time;
			}
			fpsCounter++;
			if (stage == null) {
				return;
			}
			var text:String = "";
			if (view&&view.driverInfo) {
				text += "num : " + view.renderer.collects.length;
				text += "\ndrw : " + view.renderer.gl3d.drawCounter
				text += "\ntri : " + view.renderer.gl3d.drawTriangleCounter;
				text += "\nani : " + view.antiAlias;
				text += "\nenc : " + view.enableErrorChecking;
				text += "\nwh  : " + view.stage3dWidth + "," + view.stage3dHeight;
				var info:String =view.driverInfo;
				var indexS:int = info.indexOf(" ");
				if (indexS!=-1) {
					info = info.substr(0, indexS);
				}
				text += "\ndri : " + info;
				text += "\npro : " + view.profile;
				text += "\nalv : " + view.renderer.agalVersion;
			}
			text += "\nfps : " + fps + " / " ;
			var frameRate:int = 60;
			frameRate = stage.frameRate;
			text +=  frameRate;
			var mem:int = System.totalMemoryNumber / 1024 / 1024;
			if (mem > maxMem) maxMem = mem;
			text += "\nmem : " + mem+" / "+maxMem;
			tf.text = text;
			
			var fpsGrapHeight:Number = 10;
			graphics.clear();
			graphics.beginFill(0xffffff, .7);
			var w:Number = tf.width;
			var h:Number = tf.height;
			graphics.drawRect(0, 0, w, h+fpsGrapHeight);
			graphics.endFill();
			graphics.lineStyle(0);
			var len:int = Math.min(w, fpss.length);
			for (var i:int = 0; i < len;i++ ){
				var x:Number = i;
				var y:Number = Math.round(h + fpsGrapHeight * (1 - fpss[i] / frameRate));
				if (i == 0){
					graphics.moveTo(x, y);
				}else{
					graphics.lineTo(x, y);
				}
			}
		}
		
	}

}