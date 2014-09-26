package gl3d 
{
	import com.adobe.utils.AGALMiniAssembler;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class ProgramSet 
	{
		private var vcode:String;
		private var fcode:String;
		private var invalid:Boolean = true;
		public var program:Program3D;
		private static var assembler:AGALMiniAssembler = new AGALMiniAssembler;
		public function ProgramSet(vcode:String,fcode:String) 
		{
			this.fcode = fcode;
			this.vcode = vcode;
			
		}
		
		public function update(context:Context3D):void 
		{
			if (invalid) {
				program = context.createProgram();
				program.upload(assembler.assemble(Context3DProgramType.VERTEX, vcode), assembler.assemble(Context3DProgramType.FRAGMENT, fcode));
				invalid = false;
			}
		}
		
	}

}