package ui.tree 
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author lizhi
	 */
	public class VSMenuTreeStyle extends TreeStyle
	{
		
		public function VSMenuTreeStyle() 
		{
			
		}
		
		override public function renderCell(tree:TreeNode, x:Number, y:Number):Number {
			renderCell2(tree.children,x,y,0);
			return 0;
		}
		
		public function renderCell2(trees:Vector.<TreeNode>,x:Number,y:Number,startX:Number):void {
			var wrapper:Sprite = new Sprite;
			var uis:Array = [];
			if ((y+20*trees.length)>ui.size.y) {
				if (20*trees.length>ui.size.y) {
					wrapper.y = 0;
				}else {
					wrapper.y = ui.size.y - 20 * trees.length;
				}
			}else {
				wrapper.y = y;
			}
			ui.treeUI.addChild(wrapper);
			var sy:Number = 0;
			var sx:Number = 0;
			var syi:int = 0;
			var maxTfWidths:Array = [0];
			var uiss:Array = [];
			var uis2:Array = [];
			uiss.push(uis2);
			for (var i:int = 0; i < trees.length;i++ ) {
				var child:TreeNode = trees[i]; 
				var tui:TreeNodeUI = createTreeNodeUI(child, 0, 0, ui);
				uis.push(tui);
				tui.update();
				if ((sy+(i-syi)*20+20)>ui.size.y) {
					sy = 0;
					sx = wrapper.width;
					syi = i;
					uis2 = [];
					uiss.push(uis2);
					maxTfWidths.push(0);
				}
				if (tui.tf.width > maxTfWidths[maxTfWidths.length-1] ) {
					maxTfWidths[maxTfWidths.length-1] = tui.tf.width;
				}
				uis2.push(tui);
				tui.x = sx;
				tui.y =sy+ (i-syi) * 20;
				wrapper.addChild(tui);
			}
			
			for each(uis2 in uiss) {
				var maxTfWidth:int = maxTfWidths.shift();
				for each(tui in uis2)
				tui.updateTFWidth(maxTfWidth);
			}
			
			wrapper.graphics.lineStyle(0,0x979797);
			wrapper.graphics.beginFill(0xf0f0f0);
			wrapper.graphics.drawRect(0, 0, wrapper.width, wrapper.height);
			if (((x + wrapper.width) > ui.size.x)
			&&(startX>(ui.size.x-x))
			) {
				wrapper.x = startX - wrapper.width;
			}else {
				wrapper.x = x;
			}
			
			wrapper.filters=[new DropShadowFilter(4,45,0,.5)]
			
			for (i = 0; i < trees.length;i++ ) {
				child = trees[i]; 
				if (!child.closed) {
					renderCell2(child.children,wrapper.x+uis[i].x+uis[i].width,wrapper.y+uis[i].y,x);
				}
			}
		}
		
		override public function createTreeNodeUI(node:TreeNode, x:Number, y:Number, main:TreeUI):TreeNodeUI {
			return new TreeNodeUI(node, x, y, main,true);
		}
		
	}

}