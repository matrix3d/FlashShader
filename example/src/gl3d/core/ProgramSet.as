package gl3d.core {
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
	import flash.utils.ByteArray;
	import gl3d.core.renders.GL;
	/**
	 * ...
	 * @author lizhi
	 */
	public class ProgramSet 
	{
		public var vcode:Object;
		public var fcode:Object;
		private var invalid:Boolean = true;
		private var context:GL;
		public var program:Program3D;
		public function ProgramSet(vcode:Object,fcode:Object) 
		{
			this.fcode = fcode;
			this.vcode = vcode;
		}
		
		/**
		 * @flexjsignorecoercion flash.utils.ByteArray
		 * @flexjsignorecoercion String
		 */
		public function update(context:GL):void 
		{
			if (invalid||this.context!=context) {
				program = context.createProgram();
				//try{
				if (vcode is String){
					var vbyte:ByteArray = new ByteArray;
					vbyte.writeUTFBytes(vcode as String);
					var fbyte:ByteArray = new ByteArray;
					fbyte.writeUTFBytes(fcode as String);
				}else{
					vbyte = vcode as ByteArray;
					fbyte = fcode as ByteArray;
				}
				program.upload(vbyte,fbyte);
				//}catch (err:Error){
					
				//}
				invalid = false;
				this.context = context;
			}
		}
		
	}

}