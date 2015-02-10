package ui.tree 
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TreeStyle 
	{
		public var ui:TreeUI;
		public function TreeStyle() 
		{
			
		}
		
		public function renderCell(tree:TreeNode, x:Number, y:Number):Number {
			return 0;
		}
		
		public function createTreeNodeUI(node:TreeNode, x:Number, y:Number, main:TreeUI):TreeNodeUI {
			return new TreeNodeUI(node, x, y, main);
		}
	}

}
