package gl3d.shaders.posts 
{
	import flash.display3D.Context3DProgramType;
	import flShader.FlShader;
	import flShader.Var;
	/**
	 * ...
	 * @author lizhi
	 */
	public class BlurShader extends FlShader
	{
		public function BlurShader(blurSize:Number=1/1000,isVertical:Boolean=true) 
		{
			super(Context3DProgramType.FRAGMENT);
			var arr:Array = [0.06, 0.09, 0.12, 0.15, 0.16, 0.15, 0.12, 0.09, 0.06];
			var color:Var;
			var blurSizeVar:Var = mov(F([blurSize]));
			for (var i:int = -4; i <= 4;i++ ) {
				var v:Number = arr[i + 4];
				var temp:Var = mov(V());
				if (isVertical) {
					mov(add(temp.y,mul(F([i]),blurSizeVar)),null,temp.y);
				}else {
					mov(add(temp.x,mul(F([i]),blurSizeVar)),null,temp.x);
				}
				var color2:Var = mul(tex(temp,FS()),F([v]));
				if (color==null) {
					color = mov(color2, null, color);
				}else {
					color = add(color,color2);
				}
			}
			mov(color, null, oc);
			
		}
		
	}

}