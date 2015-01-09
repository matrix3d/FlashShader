package ui 
{
	import flash.display.DisplayObject;
	import ui.win7.PanelStyle;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Panel extends UIComponent
	{
		public var children:Array = [];
		public function Panel(style:Style=null) 
		{
			style =style|| new PanelStyle;
			super(style);
		}
		
		override public function addChild(child:DisplayObject):DisplayObject 
		{
			var i:int = children.indexOf(child);
			if (i!=-1) {
				children.splice(i, 1);
			}
			children.push(child);
			return super.addChild(child);
		}
		
		override public function removeChild(child:DisplayObject):DisplayObject 
		{
			var i:int = children.indexOf(child);
			if (i!=-1) {
				children.splice(i, 1);
			}
			return super.removeChild(child);
		}
		
	}

}