package ui.tree {
	import flash.events.Event;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	/**
	 * ...
	 * @author lizhi
	 */
	public class ObjectTreeModel extends TreeModel
	{
		public function ObjectTreeModel() 
		{
			
		}
		
		override public function numChildren(node:TreeNode):int {
			if(node._children==null){
				var i:int = 0;
				var xml:XML = describeType(node.data);
				if (xml.variable.length()!=0) {
					 for each(var x:XML in xml.variable) {
						i++;
					}
				}else {
					for (var name:String in node.data) {
						i++;
					}
				}
				return i;
			}
			return node._children.length;
		}
		
		override public function children(node:TreeNode):Vector.<TreeNode> {
			if(node._children==null){
				node._children = new Vector.<TreeNode>;
				var xml:XML = describeType(node.data);
				if (xml.variable.length()!=0) {
					 for each(var x:XML in xml.variable) {
						 try{
							var c:TreeNode = new TreeNode;
							c.treeModel = node.treeModel;
							c.data = node.data[x.@name];
							c.name = x.@name;
							node._children.push(c);
						 }catch(err:Error){}
					}
				}else {
					for (var name:String in node.data) {
						c = new TreeNode;
						c.parent = node;
						c.treeModel = node.treeModel;
						c.data = node.data[name];
						c.name = name;
						node._children.push(c)
					}
				}
			   
			}
			return node._children;
		}
		
		override public function label(node:TreeNode):String {
			var cname:String=getQualifiedClassName(node.data)
			if (node.data is Array||cname.indexOf("__AS3__.vec::Vector")==0) {
				return node.name+" : ["+cname.replace("__AS3__.vec::","")+"] len:" + node.data.length;
			}
			return node.name+" : "+node.data;
		}
		
	}

}