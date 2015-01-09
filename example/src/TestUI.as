package  
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.MouseEvent;
	import ui.Button;
	import ui.Layout;
	import ui.NumericStepper;
	import ui.Panel;
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
			
			panel.addChild(new Button("贴图"));
			panel.addChild(new Button("混合模式"));
			panel.addChild(new Button("shape"));
			panel.addChild(new Button("time 最大 最小"));
			panel.addChild(new Button("位置"));
			panel.addChild(new Button("速度 半径"));
			panel.addChild(new Button("缩放"));
			panel.addChild(new Button("旋转"));
			panel.addChild(new Button("uv"));
			panel.addChild(new Button("颜色"));
			
			Layout.doVLayout(panel.children, 10, 10);
		}
		
	}

}