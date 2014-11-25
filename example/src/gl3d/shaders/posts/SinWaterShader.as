package gl3d.shaders.posts 
{
	import flash.display3D.Context3DProgramType;
	import flShader.FlShader;
	import flShader.Var;
	/**
	 * ...
	 * @author lizhi
	 */
	public class SinWaterShader extends FlShader
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
			
			var offset:Var = mul(sin(add(mul(uv, Math.PI * 10), time)), scale);
			tex(add(offset, uv), tex0, oc);
		}
		
	}

}