package ui 
{
	import flash.display.Sprite;
	/**
	 * ...
	 * @author lizhi
	 */
	public class UIComponent extends Sprite
	{
		public var style:Style;
		public var properties:Object = { };
		public var _width:Number = 0;
		public var _height:Number = 0;
		public function UIComponent(style:Style) 
		{
			this.style = style;
			init();
			update();
		}
		
		public function init():void {
			if (style) {
				style.init(this);
			}
		}
		
		public function update():void {
			if (style) {
				style.update(this);
			}
		}
		
		override public function get width():Number 
		{
			return _width;
		}
		
		override public function set width(value:Number):void 
		{
			_width = value;
			if (style) {
				style.update(this);
			}
		}
		
		override public function get height():Number 
		{
			return _height;
		}
		
		override public function set height(value:Number):void 
		{
			_height = value;
			if (style) {
				style.update(this);
			}
		}
		
	}

}