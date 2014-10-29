package  
{
	import com.adobe.utils.extended.AGALMiniAssembler;
	import flash.display3D.Context3DProgramType;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import flShader.AGALByteCreator;
	import flShader.FlShader;
	import flShader.Var;
	/**
	 * ...
	 * @author lizhi
	 */
	public class MyShader extends FlShader
	{
		public function MyShader() 
		{
			super(Context3DProgramType.VERTEX);
			var model:Var = C();
			var view:Var = C(4);
			var perspective:Var = C(8);
			var lightPos:Var = mov(C(12));
			var pos:Var = VA();
			var norm:Var = VA(1);
			var uv:Var = VA(2);
			var worldPos:Var = m44(pos, model);
			var viewPos:Var = m44(worldPos, view);
			m44(viewPos, perspective, op);
			
			var eyeDirection:Var = neg(viewPos, null);
			mov(eyeDirection, null, V(2));
			var viewPosLight:Var = add(m44(lightPos, view),eyeDirection,V());
			var viewNormal:Var = m33(norm, model);
		}
	}
}