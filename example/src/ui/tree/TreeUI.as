package ui.tree {
    import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Orientation3D;
	import flash.geom.Point;
	import flash.geom.Vector3D;
    /**
     * ...
     * @author lizhi
     */
    public class TreeUI extends Sprite
    {
		public static const TREE_CLICK:String="treeclick"
		
        public var rootTree:TreeNode=new TreeNode;
        public var treeUI:Sprite = new Sprite;
       private var _treeModel:TreeModel;
		private var lastSelectTreeNodeUI:TreeNodeUI;
		private var _data:Object;
		private var style:TreeStyle;
		public var size:Point = new Point(400, 480);
		public var xy:Point = new Point;
		public function TreeUI(style:TreeStyle=null) 
        {
			this.style = style || new VSTreeStyle;
			this.style.ui = this;
            addChild(treeUI);
			treeModel = new TreeModel;
            rootTree.closed = false;
			treeUI.addEventListener(TREE_CLICK, treeUI_treeClick);
            render();
        }
		
		private function treeUI_treeClick(e:Event):void 
		{
			var tnode:TreeNodeUI = e.target as TreeNodeUI;
			if (lastSelectTreeNodeUI != tnode) {
				if(lastSelectTreeNodeUI)
				lastSelectTreeNodeUI.select(false);
				lastSelectTreeNodeUI = tnode;
				lastSelectTreeNodeUI.select(true);
			}
		}
        
        public function render():void {
            treeUI.graphics.clear();
            treeUI.removeChildren();
			treeUI.graphics.lineStyle(0, 0xff0000);
            renderCell(rootTree, xy.x, xy.y);
			dispatchEvent(new Event(Event.CHANGE));
        }
        
        private function renderCell(tree:TreeNode, x:Number, y:Number):Number {
			return style.renderCell(tree, x, y);
        }
		
		/*public function get obj():Object 
		{
			return _obj;
		}
		
		public function set obj(value:Object):void 
		{
			_obj = value;
			rootTree._children = null;
			rootTree.obj = value;
			render();
		}*/
		
		public function update():void {
			rootTree._children = null;
			render();
		}
		
		public function setDepthClose(tree:TreeNode, val:Boolean):void {
			tree.closed = val;
			if(tree._children)
			for each(var c:TreeNode in tree._children) {
				setDepthClose(c, val);
			}
		}
		
		public function get treeModel():TreeModel 
		{
			return _treeModel;
		}
		
		public function set treeModel(value:TreeModel):void 
		{
			if (_treeModel) {
				_treeModel.removeEventListener(Event.CHANGE, treeModel_change);
			}
			_treeModel = value;
			rootTree.treeModel = value;
			if(_treeModel)_treeModel.addEventListener(Event.CHANGE, treeModel_change);
			update();
		}
		
		public function get data():Object 
		{
			return _data;
		}
		
		public function set data(value:Object):void 
		{
			_data = value;
			rootTree.data = value;
			update();
		}
		
		private function treeModel_change(e:Event):void 
		{
			update();
		}
    }

}

