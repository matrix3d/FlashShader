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
				if (!material.isDistanceField) {
					diffColor = tex(V(3), FS(),null,["repeat","linear"]);
					mul(C().w, diffColor.w, diffColor.w);
				}else {
					//http://www.valvesoftware.com/publications/2007/SIGGRAPH2007_AlphaTestedMagnification.pdf
					var distance:Var = tex(V(3),FS(),null,["repeat","linear"]).w;
					var smoothing:Var = fwidth(distance);
					var alpha:Var = sat(smoothstep(sub(0.5 , smoothing),add( 0.5 , smoothing), distance));
					diffColor = sub(1, alpha);
				}
			}
			return diffColor;
		}
		
		private function local2tangent(tangent:Var, biTangent:Var, normal:Var, value:Var):Var {
			var t:Var = createTempVar();
			dp3(tangent, value, t.x);
			dp3(biTangent, value, t.y);
			dp3(normal, value, t.z);
			return t;
		}
		
		public function getPhongColor():Var {
			var lightColor:Var = C(1);
			var lightPower:Var = lightColor.w;
			var ambientColor:Var = C(2);
			var specularPow:Var = C(3).x;
			
			var normal:Var = V(1);
			if (material.normalMapAble) {
				var tangent:Var = V(4);
				var biTangent:Var = crs(normal, tangent);
				var normalMap:Var = sub(mul(tex(V(3), FS(1),null,["linear"]),2),1);
			}
			
			var l:Var = V();
			if (material.normalMapAble) {
				var n:Var = normalMap;
				l = local2tangent(tangent,biTangent,normal,l);
			}else {
				n = normal;
			}
			var cosTheta:Var = sat(dp3(n,l));
			
			if(material.specularAble){
				var e:Var = V(2);
				if (material.normalMapAble) {
					e = local2tangent(tangent,biTangent,normal,e);
				}
				var r:Var = nrm(sub(mul2([2, dp3(l, n), n]), l));
				var cosAlpha:Var = sat(dp3(e, r));
			}
			if (material.shininess!=1) {
				if (material.specularAble) {
					return add(ambientColor, mul2([lightColor, add(cosTheta, pow(cosAlpha, specularPow)), lightPower]));
				}else {
					return add(ambientColor, mul2([lightColor, cosTheta, lightPower]));
				}
			}else {
				if (material.specularAble) {
					return add(ambientColor, mul2([lightColor, add(cosTheta, pow(cosAlpha, specularPow))]));
				}else {
					return add(ambientColor, mul2([lightColor, cosTheta]));
				}
			}
			return null;
		}
		
	}

}