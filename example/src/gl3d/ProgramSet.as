package gl3d 
{
	//import com.adobe.utils.AGALMiniAssembler;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author lizhi
	 */
	public class ProgramSet 
	{
		private var vcode:ByteArray;
		private var fcode:ByteArray;
		private var invalid:Boolean = true;
		public var program:Program3D;
		//private static var assembler:AGALMiniAssembler = new AGALMiniAssembler;
		public function ProgramSet(vcode:ByteArray,fcode:ByteArray) 
		{
			this.fcode = fcode;
			this.vcode = vcode;
			/*trace("\nvcode:",vcode.split("\n").length);
			trace(vcode);
			trace("\nfcode",fcode.split("\n").length);
			trace(fcode);*/
		}
		
		public function update(context:Context3D):void 
		{
			if (invalid) {
				program = context.createProgram();
				//program.upload(assembler.assemble(Context3DProgramType.VERTEX, vcode), assembler.assemble(Context3DProgramType.FRAGMENT, fcode));
				program.upload(vcode,fcode);
				invalid = false;
			}
		}
		
	}

}