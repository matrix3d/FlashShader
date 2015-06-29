package gl3d.shaders.posts 
{
	import flash.display3D.Context3DProgramType;
	import as3Shader.AS3Shader;
	import as3Shader.Var;
	import gl3d.core.shaders.GLAS3Shader;
	/**
	 * ...
	 * @author lizhi
	 */
	public class BlurShader extends GLAS3Shader
	{
		public function BlurShader(blurSize:Number=1/1000,isVertical:Boolean=true) 
		{
			super(Context3DProgramType.FRAGMENT);
			var arr:Array = [0.06, 0.09, 0.12, 0.15, 0.16, 0.15, 0.12, 0.09, 0.06];
			var color:Var;
			var blurSizeVar:Var = mov(blurSize);
			var newuv:Var;
			
			for (var i:int = -4; i <= 4;i++ ) {
				var v:Number = arr[i + 4];
				if (newuv==null) {
					newuv = mov(V());
					if (isVertical) {
						add(newuv.y, mul(i, blurSizeVar), newuv.y);
					}else {
						add(newuv.x, mul(i, blurSizeVar), newuv.x);
					}
				}else {
					if (isVertical) {
						add(newuv.y,blurSizeVar, newuv.y);
					}else {
						add(newuv.x,blurSizeVar, newuv.x);
					}
				}
				var color2:Var = mul(tex(newuv,FS()),v);
				if (color==null) {
					color = mov(color2, color);
				}else {
					color = add(color,color2,i==4?oc:null);
				}
			}
		}
		
	}

}