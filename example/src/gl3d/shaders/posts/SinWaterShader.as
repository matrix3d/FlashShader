package gl3d.shaders.posts 
{
	import flash.display3D.Context3DProgramType;
	import as3Shader.AS3Shader;
	import as3Shader.Var;
	/**
	 * ...
	 * @author lizhi
	 */
	public class SinWaterShader extends AS3Shader
	{
		
		public function SinWaterShader() 
		{
			super(Context3DProgramType.FRAGMENT);
			/*var uv:Var = V();
			var offset:Array = [.2,0];
			tex(add(offset,uv),FS(),oc,["wrap"]/*,["2d","wrap"]*/
			
			var time:Var = div(C().x,mov(1000));
			var uv:Var = V();
			var tex0:Var = FS();
			var scale:Number = .01;
			
			var offset:Var = mul(sin(add(mul(uv.yx, Math.PI * 10), time)), scale);
			tex(add(offset, uv), tex0, oc);
		}
		
	}

}