package editor 
{
	import flash.display.Sprite;
	import ui.Label;
	import ui.Layout;
	import ui.Panel;
	/**
	 * ...
	 * @author lizhi
	 */
	public class ParticleEditor extends Panel
	{
		
		public function ParticleEditor() 
		{
			var label:Label = new Label;
			addChild(label);
			label.text = "贴图";
			
			Layout.doVLayout(children, 5, 5);
		}
		
	}

}