package gl3d.shaders 
{
	import flash.display3D.Context3DProgramType;
	import flash.display3D.textures.Texture;
	import flShader.FlShader;
	import flShader.Var;
	import gl3d.Light;
	import gl3d.Material;
	import gl3d.TextureSet;
	/**
	 * ...
	 * @author lizhi
	 */
	public class PhongFragmentShader extends FlShader
	{
		private var material:Material;
		
		public function PhongFragmentShader(material:Material) 
		{
			super(Context3DProgramType.FRAGMENT);
			this.material = material;
		}
		
		override public function build():void {
			var diffColor:Var = getDiffColor();
			var light:Light = material.view.light;
			if (light.lightAble) {
				var phongColor:Var = getPhongColor();
				mov(diffColor.w, null, phongColor.w);
				mul(phongColor, diffColor, oc);
			}else {
				mov(diffColor,null,oc);
			}
		}
		
		public function getDiffColor():Var {
			if (material.textureSets.length==0) {
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
			var cosAlpha:Var = sat(dp3(e, r));
			
			var light:Light = material.view.light;
			if (light.lightAble) {
				
			}else {
				
			}
			if (material.view.light.lightPowerAble) {
				return add(ambientColor, mul2([lightColor, add(cosTheta, pow(cosAlpha, specularPow)), lightPower]));
			}else {
				return add(ambientColor, mul2([lightColor, add(cosTheta, pow(cosAlpha, specularPow))]));
			}
			return null;
		}
		
	}

}