package ui 
{
	import com.bit101.components.CheckBox;
	import com.bit101.components.ColorChooser;
	import com.bit101.components.HBox;
	import com.bit101.components.HSlider;
	import com.bit101.components.HUISlider;
	import com.bit101.components.InputText;
	import com.bit101.components.Label;
	import com.bit101.components.Panel;
	import com.bit101.components.Slider;
	import com.bit101.components.VBox;
	import com.bit101.components.Window;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import ui.Color;
	/**
	 * ...
	 * @author lizhi
	 */
	public class AttribSeter extends Sprite
	{
		public static const TYPE_NUM:int = 0;
		public static const TYPE_VEC_COLOR:int = 1;
		public static const TYPE_BOOL:int = 2;
		public var ui2target:Dictionary = new Dictionary;
		public var targets:Array = [];
		private var vbox:VBox;
		private var panel:Window;
		public function AttribSeter() 
		{
			panel = new Window(this);
			vbox = new VBox(panel,5,5);
		}
		
		public function bind(target:Object, name:String, type:int,range:Point=null):void {
			var nui:Object;
			switch(type) {
				case TYPE_NUM:
					var hbox:HBox = new HBox(vbox);
					var slider:HUISlider = new HUISlider(hbox, 0, 0,"",onChange);
					nui = slider;
					slider.setSliderParams(range.x, range.y, 0);
					break;
				case TYPE_VEC_COLOR:
					hbox = new HBox(vbox);
					var color:ColorChooser = new ColorChooser(hbox, 0, 0, 0xffffff, onChange);
					nui = color;
					color.usePopup = true;
					break;
				case TYPE_BOOL:
					hbox = new HBox(vbox);
					var cb:CheckBox = new CheckBox(hbox, 0, 0,"",onChange);
					nui = cb;
					break;
			}
			if (nui) {
				var labelStr:String = (target + "").replace("object ","") + "." + name;
				targets.push([target,name,type,nui]);
				ui2target[nui] = targets[targets.length - 1];
				new Label(hbox, 0, 0, labelStr);
			}
			
			panel.setSize(vbox.width+20, vbox.height+50);
		}
		
		private function onChange(e:Event):void 
		{
			var nui:Object = e.currentTarget;
			var target:Array = ui2target[nui] as Array;
			var v:Object = target[0][target[1]];
			var type:int = target[2];
			switch(type) {
				case TYPE_NUM:
					var slider:HUISlider = nui as HUISlider;
					target[0][target[1]] = slider.value;
					break;
				case TYPE_VEC_COLOR:
					var colorui:ColorChooser = nui as ColorChooser;
					var color:Color = new Color;
					color.fromHex(colorui.value);
					v[0] = color.r/0xff;
					v[1] = color.g/0xff;
					v[2] = color.b/0xff;
					break;
				case TYPE_BOOL:
					var cb:CheckBox = nui as CheckBox;
					target[0][target[1]] = cb.selected;
					break;
			}
		}
		
		public function update():void {
			for each(var target:Array in targets) {
				var type:int = target[2];
				var v:Object = target[0][target[1]]
				var nui:Object=target[3]
				switch(type) {
					case TYPE_NUM:
						var input:HUISlider = nui as HUISlider;
						input.value = Number(v);
						break;
					case TYPE_VEC_COLOR:
						var colorui:ColorChooser = nui as ColorChooser;
						var color:Color = new Color;
						color.fromRGB(v[0]*0xff, v[1]*0xff, v[2]*0xff);
						colorui.value = color.toHex();
						break;
					case TYPE_BOOL:
						var cb:CheckBox = nui as CheckBox;
						cb.selected = v as Boolean;
						break;
				}
			}
		}
	}
}