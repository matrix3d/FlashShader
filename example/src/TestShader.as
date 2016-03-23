package 
{
	import as3Shader.AS3Shader;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestShader extends Sprite
	{
		
		public function TestShader() 
		{
			var shader:AS3Shader = new AS3Shader;
			shader.add(1,shader.createTempVar());
			shader.op = shader.add(shader.add([1, 1, 1, 1], [2, 2, 2, 2]), shader.createTempVar());
			//shader.op = shader.add( [2, 2, 2, 2], shader.createTempVar());
			trace(shader.code);
			trace(shader.constMemLen);
			trace(shader.constPoolVec);
			
			//删除无用line
			//buffer
			//vary
			//const
			//temp
			//uniform
		}
		
	}

}