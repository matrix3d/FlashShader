package ui.tree {
	import flash.events.EventDispatcher;
	import flash.utils.describeType;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TreeModel extends EventDispatcher
	{
		
		public function TreeModel() 
		{
			
		}
		
		public function numChildren(node:TreeNode):int {
			return node._children?node._children.length:-1;
		}
		
		public function children(node:TreeNode):Vector.<TreeNode> {
			return Vector.<TreeNode>([]);
		}
		
		public function label(node:TreeNode):String {
			return node.data+"";
		}
		
	}

}