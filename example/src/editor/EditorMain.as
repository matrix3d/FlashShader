package editor 
{
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	/**
	 * ...
	 * @author lizhi
	 */
	public class EditorMain extends Editor
	{
		
		public function EditorMain() 
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			var pe:ParticleEditor = new ParticleEditor;
			addChild(pe);
			pe.x = pe.y = 5;
		}
		
	}

}