package 
{
	import com.adobe.utils.extended.AGALMiniAssembler;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.utils.getTimer;
	import flShader.AGALByteCreator;
	import flShader.FlShader;
	
	/**
	 * ...
	 * @author lizhi http://matrix3d.github.io/
	 */
	public class Main extends Sprite 
	{
		private var debug:TextField=new TextField;
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			addChild(debug);
			debug.autoSize = "left";
			var shader:MyShader = new MyShader;
			var code:String = shader.code;
			
			var max:int = 1000;
			
			var c:int = max;
			var assembler:AGALMiniAssembler = new AGALMiniAssembler;
			var time:int = getTimer();
			while(c-->0){
				assembler.assemble(shader.programType, code,2);
			}
			debug.appendText(max+"\n");
			debug.appendText((getTimer() - time)+"ms,AGALMiniAssembler\n");
			
			var bytecreator:AGALByteCreator = new AGALByteCreator(2);
			c = max;
			time = getTimer();
			while (c-->0) {
				shader =new MyShader;
				shader.creator = bytecreator;
				shader.code2
			}
			debug.appendText((getTimer() - time)+"ms,FLShader\n");
		}
		
	}
	
}