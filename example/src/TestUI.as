package  
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3DProfile;
	import flash.events.MouseEvent;
	import ui.Alert;
	import ui.Button;
	import ui.ColorSelector;
	import ui.Layout;
	import ui.NumericStepper;
	import ui.Panel;
	import ui.tree.ObjectTreeModel;
	import ui.tree.TreeUI;
	import ui.tree.VSMenuTreeStyle;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestUI extends Sprite
	{
		
		public function TestUI() 
		{
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			var panel:Panel = new Panel;
			panel.width = 300;
			panel.height = 300;
			addChild(panel);
			panel.x = panel.y = 50;
			
			panel.addChild(new Button("贴图"+Context3DProfile.STANDARD));
			panel.addChild(new Button("混合模式"));
			panel.addChild(new Button("shape"));
			panel.addChild(new Button("time 最大 最小"));
			panel.addChild(new NumericStepper("颜色"));
			panel.addChild(new ColorSelector());
			var tree:TreeUI = new TreeUI(new VSMenuTreeStyle);
			tree.treeModel = new ObjectTreeModel;
			tree.data = {a:1,b:{c:1,d:[1,2]}};
			panel.addChild(tree);
			
			Layout.doVLayout(panel.children, 10, 10);
			
			addEventListener(MouseEvent.CLICK, click);
		}
		
		private function click(e:MouseEvent):void 
		{
			
			Alert.alert("123");
		}
		
	}

}