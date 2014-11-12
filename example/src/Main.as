package 
{
	import com.adobe.utils.extended.AGALMiniAssembler;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import flShader.AGALByteCreator;
	import gl3d.shaders.PhongFragmentShader;
	import gl3d.shaders.PhongVertexShader;
	import gl3d.util.Utils;
	//import flShader.AGALByteCreator;
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
			
			trace(code);
			
			var max:int = 10000;
			
			var c:int = max;
			var assembler:AGALMiniAssembler = new AGALMiniAssembler;
			assembler.verbose = true;
			var time:int = getTimer();
			while(c-->0){
				assembler.assemble(shader.programType, code,2);
			}
			debug.appendText(max+"\n");
			debug.appendText((getTimer() - time)+"ms,AGALMiniAssembler\n");
			
			tracebyte(assembler.agalcode);
			
			var bytecreator:AGALByteCreator = new AGALByteCreator(2);
			bytecreator.verbose = true;
			c = max;
			time = getTimer();
			while (c-->0) {
				shader =new MyShader;
				shader.creator = bytecreator;
				shader.code2
			}
			tracebyte(bytecreator.data as ByteArray);
			debug.appendText((getTimer() - time) + "ms,FLShader agalbyte\n");
			
			c = max;
			time = getTimer();
			while (c-->0) {
				shader =new MyShader;
				shader.code;
			}
			//tracebyte(bytecreator.data as ByteArray);
			debug.appendText((getTimer() - time) + "ms,FLShader agalcode\n");
			
			trace(Utils.compareByte(bytecreator.data as ByteArray,assembler.agalcode));
		}
		
		private function tracebyte(byte:ByteArray):void {
			var a:Array = [];
			for (var i:int = 0; i < byte.length;i++ ) {
				a.push(byte[i]);
			}
			trace(a);
		}
		
	}
	
}