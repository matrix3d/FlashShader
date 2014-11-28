package gl3d.shaders 
{
	import flash.display3D.Context3DProgramType;
	import flash.display3D.textures.Texture;
	import flShader.FlShader;
	import flShader.Var;
	import gl3d.core.Light;
	import gl3d.core.Material;
	import gl3d.core.TextureSet;
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
			if (material.wireframeAble) {
				var tp:Var = mov(V(4));
				var a3:Var = smoothstep(0, fwidth(tp), tp);
				var wireframeColor:Var = mul(sub( 1 , min(min(a3.x, a3.y), a3.z).xxx ) , C(5));
			}
			var diffColor:Var = getDiffColor();
			var light:Light = material.view.light;
			if (material.lightAble) {
				var phongColor:Var = getPhongColor();
				mov(diffColor.w, phongColor.w);
				if (wireframeColor) {
					add(wireframeColor,mul(phongColor, diffColor),oc);
				}else {
					mul(phongColor, diffColor, oc);
				}
			}else {
				if (wireframeColor) {
					add(diffColor, wireframeColor, oc);
				}else {
					mov(diffColor,oc);
				}
			}
		}
		
		public function getDiffColor():Var {
			if (material.textureSets.length==0) {
				var diffColor:Var = C();
			}else {
				diffColor = tex(V(3), FS(),null,["repeat","linear"]);
				mul(C().w, diffColor.w, diffColor.w);
			}
			return diffColor;
		}
		
		public function getPhongColor():Var {
			var lightColor:Var = C(1);
			var lightPower:Var = lightColor.w;
			var ambientColor:Var = C(2);
			var specularPow:Var = C(3).x;
			
			if (material.normalMapAble) {
				var tangent:Var = V(4);
				var normal:Var = V(1);
				var biTangent:Var = crs(normal, tangent);
				var normalMap:Var = sub(mul(tex(V(3), FS(1)),2),1);
				var temp:Var = createTempVar();
				mov(dp3(tangent,normalMap),temp.x);
				mov(dp3(biTangent,normalMap),temp.y);
				mov(dp3(normal, normalMap), temp.z);
				normal = temp;
			}else {
				normal = V(1);
			}
			var n:Var = nrm(normal);
			var l:Var = nrm(V());
			var cosTheta:Var = sat(dp3(n,l));
			
			var e:Var = nrm(V(2));
			var r:Var = nrm(sub(mul2([2, dp3(l, n), n]), l));
			var cosAlpha:Var = sat(dp3(e, r));
			
			var light:Light = material.view.light;
			if (material.lightAble) {
				
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