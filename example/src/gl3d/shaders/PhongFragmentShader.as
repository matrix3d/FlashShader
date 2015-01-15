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
		public var vs:PhongVertexShader;
		public var wireframeColor:Var = uniform();
		public var diffColor:Var = uniform();
		public var lightColor:Var = uniform();
		public var specular:Var = uniform();
		public var ambientColor:Var = uniform();
		
		public var diffSampler:Var = sampler();
		public var normalmapSampler:Var = sampler();
		public function PhongFragmentShader(material:Material,vs:PhongVertexShader) 
		{
			super(Context3DProgramType.FRAGMENT);
			this.vs = vs;
			this.material = material;
		}
		
		override public function build():void {
			if (material.wireframeAble) {
				var tp:Var = mov(vs.targetPositionVarying);
				var a3:Var = smoothstep(0, fwidth(tp), tp);
				var wireframeColor:Var = mul(sub( 1 , min(min(a3.x, a3.y), a3.z).xxx ) , this.wireframeColor);
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
			if (material.diffTexture==null) {
				var diffColor:Var = this.diffColor;
			}else {
				if (!material.isDistanceField) {
					diffColor = tex(vs.uvVarying, diffSampler,null,["repeat","linear"]);
					mul(this.diffColor.w, diffColor.w, diffColor.w);
				}else {
					//http://www.valvesoftware.com/publications/2007/SIGGRAPH2007_AlphaTestedMagnification.pdf
					var distance:Var = tex(vs.uvVarying,diffSampler,null,["repeat","linear"]).w;
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
			return nrm(t);
		}
		
		public function getPhongColor():Var {
			var lightPower:Var = lightColor.w;
			var specularPow:Var = specular.x;
			
			var normal:Var = vs.normVarying;
			if (material.normalMapAble) {
				var tangent:Var = vs.tangentVarying;
				var biTangent:Var = crs(normal, tangent);
				var normalMap:Var = sub(mul(tex(vs.uvVarying, normalmapSampler,null,["linear"]),2),1);
			}
			
			var l:Var = vs.posLightVarying;
			if (material.normalMapAble) {
				var n:Var = normalMap;
				l = local2tangent(tangent,biTangent,normal,l);
			}else {
				n = normal;
			}
			var cosTheta:Var = sat(dp3(n,l));
			
			if(material.specularAble){
				var e:Var = vs.eyeDirectionVarying;
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