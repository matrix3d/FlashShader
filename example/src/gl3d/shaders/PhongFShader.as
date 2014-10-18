package gl3d.shaders 
{
	import flash.display3D.Context3DProgramType;
	import flash.display3D.textures.Texture;
	import flShader.FlShader;
	import flShader.Var;
	import gl3d.TextureSet;
	/**
	 * ...
	 * @author lizhi
	 */
	public class PhongFShader extends FlShader
	{
		private var texture:TextureSet;
		
		public function PhongFShader(texture:TextureSet=null) 
		{
			super(Context3DProgramType.FRAGMENT);
			this.texture = texture;
		}
		
		override public function build():void {
			var diffColor:Var = getDiffColor();
			var phongColor:Var = getPhongColor();
			mov(diffColor.w, null, phongColor.w);
			mul(phongColor, diffColor, oc);
		}
		
		public function getDiffColor():Var {
			if (texture == null) {
				var diffColor:Var = C();
			}else {
				diffColor = tex(V(3), FS());
				mul(C().w, diffColor.w, diffColor.w);
			}
			return diffColor;
		}
		
		public function getPhongColor():Var {
			var lightColor:Var = C(1);
			var lightPower:Var = lightColor.w;
			var ambientColor:Var = C(2);
			var specularPow:Var = C(3).x;
			
			var n:Var = nrm(V(1));
			var l:Var = nrm(V());
			var cosTheta:Var = sat(dp3(n,l));
			
			var e:Var = nrm(V(2));
			var r:Var = nrm(sub(mul2([F([2]), dp3(l, n), n]), l));
			var cosAlpha:Var = sat(dp3(e,r));
			return add(ambientColor, mul2([lightColor, add(cosTheta, pow(cosAlpha, specularPow)), lightPower]));
		}
		
	}

}