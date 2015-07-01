package 
{
	import as3Shader.AGALByteCreator;
	import as3Shader.AS3Shader;
	import as3Shader.Var;
	import com.adobe.utils.AGALMiniAssembler;
	import flash.display.Sprite;
	import flash.display3D.Context3DProgramType;
	import flash.utils.ByteArray;
	import gl3d.shaders.PhongVertexShader;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Test extends Sprite
	{
		private var shader:AS3Shader;
		
		public function Test() 
		{
			shader = new AS3Shader(Context3DProgramType.VERTEX);
			//shader.mov(shader.mul([1, 2, 3, 4], 2), shader.op);
			var joint:Var = shader.uniform();
			var joints:Var = shader.floatArray(10);
			shader.mov(q44(shader.createTempVar(),shader.createTempVar(),shader.createTempVar()), shader.op);
			shader.build();
			trace(shader.code);
			trace(shader.constPoolVec);
			
			var am:AGALMiniAssembler = new AGALMiniAssembler;
			am.assemble(shader.programType, shader.code as String);
			
			shader.creator = new AGALByteCreator;
			trace(tracebyte(shader.code as ByteArray) == tracebyte(am.agalcode));
		}
		
		private function tracebyte(byte:ByteArray):String {
			var a:Array = [];
			byte.position = 0;
			while (byte.bytesAvailable) {
				a.push(byte.readByte());
			}
			trace(a);
			return a + "";
		}
		public function q44(pos:Var, quas:Var, tran:Var):Var {
			return shader.add(q33(pos, shader.mov(quas)), tran);
		}
		
		public function q33(pos:Var, quas:Var):Var {
			var t:Var = shader.mul(2 , shader.crs(quas, pos));
			return shader.add2([pos , shader.mul(quas.w , t) , shader.crs(quas, t)]);
		}
		
	}

}