package ui 
{
	import com.bit101.components.ColorChooser;
	import com.bit101.components.HBox;
	import com.bit101.components.InputText;
	import com.bit101.components.Label;
	import com.bit101.components.VBox;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import ui.Color;
	/**
	 * ...
	 * @author lizhi
	 */
	public class AttribSeter extends VBox
	{
		public static const TYPE_NUM:int = 0;
		public static const TYPE_VEC_COLOR:int = 1;
		public var ui2target:Dictionary = new Dictionary;
		public var targets:Array = [];
		public function AttribSeter() 
		{
			
		}
		
		public function bind(target:Object, name:String, type:int):void {
			switch(type) {
				case TYPE_NUM:
					var hbox:HBox = new HBox(this);
					var input:InputText = new InputText(hbox);
					input.restrict = "-01234567890.";
					input.addEventListener(Event.CHANGE, input_change);
					targets.push([target,name,type,input]);
					ui2target[input] = targets[targets.length - 1];
					new Label(hbox, 0, 0, target + ":" + name);
					break;
				case TYPE_VEC_COLOR:
					hbox = new HBox(this);
					var color:ColorChooser = new ColorChooser(hbox,0,0,0xffffff,onColorChange);
					color.usePopup = true;
					targets.push([target,name,type,color]);
					ui2target[color] = targets[targets.length - 1];
					new Label(hbox, 0, 0, target + ":" + name);
					break;
			}
		}
		
		private function onColorChange(e:Event):void 
		{
			var colorui:ColorChooser = e.currentTarget as ColorChooser;
			var target:Array = ui2target[colorui] as Array;
			var v:Object = target[0][target[1]];
			var color:Color = new Color;
			color.fromHex(colorui.value);
			v[0] = color.r/0xff;
			v[1] = color.g/0xff;
			v[2] = color.b/0xff;
		}
		
		public function update():void {
			for each(var target:Array in targets) {
				var type:int = target[2];
				var v:Object= target[0][target[1]]
				switch(type) {
					case TYPE_NUM:
						var input:InputText = target[3] as InputText;
						input.text = v+"";
						break;
					case TYPE_VEC_COLOR:
						var colorui:ColorChooser = target[3] as ColorChooser;
						var color:Color = new Color;
						color.fromRGB(v[0]*0xff, v[1]*0xff, v[2]*0xff);
						colorui.value = color.toHex();
						break;
				
				}
			}
		}
		
		private function input_change(e:Event):void 
		{
			var input:InputText = e.currentTarget as InputText;
			var target:Array = ui2target[input] as Array;
			target[0][target[1]]=Number(input.text)
		}
		
	}

}