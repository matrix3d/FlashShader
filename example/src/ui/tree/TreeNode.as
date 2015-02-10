package ui.tree {
	import flash.display.BitmapData;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	/**
	 * 树形节点
	 * @author lizhi
	 */
	public class TreeNode {
		public static var ID:int = 0;
		public var treeModel:TreeModel;
		public var parent:TreeNode;
		public var closed:Boolean = true;
		public var name:String;
		public var _children:Vector.<TreeNode>;
		public var data:Object;
		public var icon:BitmapData;
		public function TreeNode() {
			
		}
		public function get children():Vector.<TreeNode> 
		{
			return treeModel.children(this);
		}
		
		public function get numChildren():int {
			return treeModel.numChildren(this);
		}
		
		public function get label():String 
		{
			return treeModel.label(this);
		}
	}

}