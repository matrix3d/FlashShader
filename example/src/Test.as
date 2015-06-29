package 
{
	import as3Shader.AS3Shader;
	import flash.display.Sprite;
	import flash.display3D.Context3DProgramType;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Test extends Sprite
	{
		
		public function Test() 
		{
			var shader:AS3Shader = new AS3Shader(Context3DProgramType.VERTEX);
			shader.mov(shader.mul([1,2,3,4],2), shader.op);
			shader.build();
			trace(shader.code);
			trace(shader.constPoolVec);
		}
		
	}

}