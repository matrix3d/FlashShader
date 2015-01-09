package ui.win7 
{
	import ui.Style;
	import ui.UIComponent;
	/**
	 * ...
	 * @author lizhi
	 */
	public class PanelStyle extends Style
	{
		
		public function PanelStyle() 
		{
			
		}
		
		override public function update(component:UIComponent):void 
		{
			Win7Style.drawBG(component.graphics, component.width,component.height,0,0,0,0x6e6e6e,.99);
		}
		
		override public function init(component:UIComponent):void 
		{
			component.width = component.height = 200;
		}
		
	}

}