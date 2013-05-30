package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import lz.flShader.Shader;
	
	/**
	 * ...
	 * @author lizhi http://matrix3d.github.io/
	 */
	public class Main extends Sprite 
	{
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			var shader:Shader = new Shader;
			shader.mul(shader.add(1, 2), [1, 2, 3]);
		}
		
	}
	
}