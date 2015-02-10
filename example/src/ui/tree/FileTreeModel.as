package ui.tree {
	import flash.display.BitmapData;
	import flash.filesystem.File;
	/**
	 * ...
	 * @author lizhi
	 */
	public class FileTreeModel extends TreeModel
	{
		public static var folderIcon:BitmapData;
		public static var extension2Icon:Object = { };
		public function FileTreeModel() 
		{
			
		}
		
		override public function numChildren(node:TreeNode):int {
			var file:File = node.data as File;
			if(node._children==null){
				if (file&&file.isDirectory) {
					return file.getDirectoryListing().length;
				}else {
					return 0;
				}
			}
			return node._children.length;
		}
		
		override public function children(node:TreeNode):Vector.<TreeNode> {
			if (node._children == null) {
				var file:File = node.data as File;
				node._children = new Vector.<TreeNode>;
				if (file&&file.isDirectory) {
					 for each(var f:File in file.getDirectoryListing()) {
						var c:TreeNode = new TreeNode;
						c.treeModel = node.treeModel;
						c.data = f;
						c.icon = f.isDirectory?folderIcon:extension2Icon[f.extension.toLowerCase()];
						c.parent = node;
						c.name = f.name;
						node._children.push(c);
					}
				}
			}
			return node._children;
		}
		
		override public function label(node:TreeNode):String {
			var file:File = node.data as File;
			return file?file.name:"null";
		}
	}

}