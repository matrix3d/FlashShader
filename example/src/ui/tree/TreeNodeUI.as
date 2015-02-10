package ui.tree
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	/**
	 * 树节点ui
	 * @author lizhi
	 */
	public class TreeNodeUI extends Sprite
	{
		public var tf:TextField;
		public var node:TreeNode;
		public var treeUI:TreeUI;
		public var openBtn:TreeOpenBtn;
		private static var DEFICON:BitmapData;
		private var isMenuModel:Boolean;
		private var timer:Timer;
		public function TreeNodeUI(node:TreeNode, x:Number, y:Number, main:TreeUI,isMenuModel:Boolean=false)
		{
			this.isMenuModel = isMenuModel;
			this.node = node;
			this.treeUI = main;
			this.x = x;
			this.y = y;
			
			//icon
			if (DEFICON == null)
			{
				DEFICON = new BitmapData(16, 16, true, 0);
				var pen:Sprite = new Sprite;
				pen.graphics.beginFill(0xd7a438);
				pen.graphics.drawCircle(8, 8, 7);
				DEFICON.draw(pen);
			}
			
			var wrapper:Sprite = new Sprite;
			addChild(wrapper);
			
			var icon:Bitmap = new Bitmap(isMenuModel?node.icon:(node.icon||DEFICON));
			wrapper.addChild(icon);
			icon.x = isMenuModel?0:20;
			
			tf = new TextField();
			tf.defaultTextFormat = new TextFormat("微软雅黑");
			tf.autoSize = "left";
			tf.selectable = tf.mouseWheelEnabled = false;
			wrapper.addChild(tf);
			tf.x = isMenuModel?20:40;
			tf.y = -3;
			tf.backgroundColor = 0x3399ff;
			
			openBtn = new TreeOpenBtn(isMenuModel);
			addChild(openBtn);
			
			if(isMenuModel){
				wrapper.addEventListener(MouseEvent.MOUSE_OVER, onMenuModelOver);
				wrapper.addEventListener(MouseEvent.MOUSE_OUT, wrapper_mouseOut);
				timer = new Timer(100,1);
				timer.addEventListener(TimerEvent.TIMER_COMPLETE, timer_timerComplete);
			}else {
				openBtn.addEventListener(MouseEvent.CLICK, click);
			}
			
			wrapper.addEventListener(MouseEvent.CLICK, tf_click);
		
		}
		
		private function timer_timerComplete(e:TimerEvent):void 
		{
			var b:Boolean = false;
			for each(var c:TreeNode in node.children) {
				if (!c.closed) {
					b = true;
					break;
				}
			}
			if (node.closed||b) {
				treeUI.setDepthClose(treeUI.rootTree, true);
				var n:TreeNode = node;
				while (n) {
					n.closed = false;
					n = n.parent;
				}
				treeUI.render();
			}
		}
		
		private function wrapper_mouseOut(e:MouseEvent):void 
		{
			select(false);
			timer.stop();
		}
		
		private function onMenuModelOver(e:MouseEvent):void 
		{
			select(true);
			timer.reset();
			timer.start();
		}
		
		private function tf_click(e:MouseEvent):void
		{
			var e2:MouseEvent = new MouseEvent(TreeUI.TREE_CLICK);
			dispatchEvent(e2);
		}
		
		public function update():void
		{
			tf.text = node.label;
			openBtn.closed = node.closed;
			openBtn.visible = node.numChildren != 0;
			openBtn.x = isMenuModel?tf.x+tf.width:0;
		}
		
		public function updateTFWidth(w:int):void {
			tf.autoSize = TextFieldAutoSize.NONE;
			tf.width = w;
			openBtn.x = isMenuModel?tf.x+tf.width:0;
		}
		
		public function select(boolean:Boolean):void
		{
			tf.background = boolean;
		}
		
		private function click(e:MouseEvent):void
		{
			node.closed = !node.closed;
			treeUI.render();
		}
	}
}