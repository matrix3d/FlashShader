package gl3d.shaders 
{
	import flash.display3D.Context3DProgramType;
	import flash.display3D.textures.Texture;
	import as3Shader.AS3Shader;
	import as3Shader.Var;
	import gl3d.core.Fog;
	import gl3d.core.shaders.GLAS3Shader;
	import gl3d.core.Light;
	import gl3d.core.Material;
	import gl3d.core.TextureSet;
	/**
	 * ...
	 * @author lizhi
	 */
	public class PhongFragmentShader extends GLAS3Shader
	{
		public var material:Material;
		private var e:Var;
		private var n:Var;
		public var vs:PhongVertexShader;
		public var wireframeColor:Var //uniform();
		public var diffColor:Var //= uniform();
		//public var lightColor:Var //= //uniform();
		public var specular:Var //= //uniform();
		public var ambientColor:Var //= //uniform();
		
		public var diffSampler:Var// = sampler();
		public var normalmapSampler:Var// = sampler();
		public var reflectSampler:Var// = sampler();
		public function PhongFragmentShader(material:Material,vs:PhongVertexShader) 
		{
			super(Context3DProgramType.FRAGMENT);
			this.vs = vs;
			this.material = material;
			diffSampler = samplerDiff();
			normalmapSampler = samplerNormalmap();
			reflectSampler = samplerReflect();
			wireframeColor = uniformWireframeColor();
			diffColor = uniformMaterialColor();
			specular = uniformSpecular();
			ambientColor = uniformAmbient();
		}
		
		override public function build():void {
			if(!material.writeDepth){
				if (material.wireframeAble) {
					var tp:Var = mov(vs.targetPositionVarying);
					var a3:Var = smoothstep(0, fwidth(tp), tp);
					var wireframeColor:Var = mul(sub( 1 , min(min(a3.x, a3.y), a3.z).xxx ) , this.wireframeColor);
				}
				var diffColor:Var = getDiffColor();
				if (material.lightAble&&material.view.lights.length) {
					for (var i:int = 0; i < material.view.lights.length; i++ ) {
						var light:Light = material.view.lights[i];
						var curPhongColor:Var;
						if (light.lightType==Light.AMBIENT) {
							curPhongColor = uniformLightColor(i);
						}else {
							curPhongColor = getPhongColor(i);
							if (light.lightType == Light.POINT||light.lightType==Light.SPOT) {
								curPhongColor = mul(curPhongColor, getDistanceColor(i));
							}
							if (light.lightType==Light.SPOT) {
								curPhongColor = mul(curPhongColor, getSmoothColor(i));
							}
						}
						if (light.shadowMapEnabled && material.receiveShadows) {
							debug("shadowstart");
							var shadowLightPos:Var = vs.shadowLightPoss[i];
							var shadowLightXY:Var = add(mul(div(shadowLightPos.xy, shadowLightPos.w), [.5, -.5]), .5);
							var shadowLightDepth:Var = tex(shadowLightXY, samplerShadowmaps(i));
							var curDepth:Var = div(shadowLightPos.z, shadowLightPos.w);
							//curPhongColor = mul(curPhongColor, sub(0, sne(shadowLightDepth, curDepth)).xxxx);
							curPhongColor = mul(curPhongColor,slt(curDepth,shadowLightDepth));//mul(curPhongColor, sub(0, sne(shadowLightDepth, curDepth)).xxxx);
							debug("shadowend");
						}
						if (phongColor == null) {
							var phongColor:Var = curPhongColor;
						}else {
							phongColor = add(phongColor, curPhongColor);
						}
					}
					if (material.toonAble) {
						phongColor = div(floor(add(.5,mul(material.toonStep, phongColor))),material.toonStep);
					}
					mov(diffColor.w, phongColor.w);
					if (wireframeColor) {
						add(wireframeColor,mul(phongColor, diffColor),diffColor);
					}else {
						mul(phongColor, diffColor, diffColor);
					}
				}else {
					if (wireframeColor) {
						add(diffColor, wireframeColor, diffColor);
					}
				}
				if (material.reflectTexture) {
					var refc:Var = tex(vs.reflected, reflectSampler, null,material.reflectTexture.flags);
					mul(diffColor.xyz,refc.xyz,diffColor.xyz);
				}
				if(material.fogAble){
					var fog:Fog = material.view.fog;
					if (fog.mode != Fog.FOG_NONE) {
						var d:Var = distance(uniformCameraPos(), vs.modelPosVarying, 3);
						if (fog.mode == Fog.FOG_EXP) {
							var f:Var = rcp(exp(mul(d, fog.density)));
						}else if (fog.mode==Fog.FOG_EXP2) {
							f = rcp(exp(pow(mul(d, fog.density),2)));
						}else if (fog.mode==Fog.FOG_LINEAR) {
							f = sat(div(sub(fog.end , d) , sub(fog.end , fog.start)));
						}
						
						mix(material.view.fog.fogColor,diffColor.xyz,f,diffColor.xyz);
					}
				}
				oc = diffColor;
			}else {
				oc = div(vs.opVarying.z,vs.opVarying.w);
			}
		}
		
		public function getDiffColor():Var {
			if (material.diffTexture==null) {
				var diffColor:Var = mov(this.diffColor);
			}else {
				if (!material.isDistanceField) {
					diffColor = tex(vs.uvVarying, diffSampler, null, material.diffTexture.flags);
					if (material.alphaThreshold > 0) {
						kil(sub(diffColor.w,material.alphaThreshold).x);
					}
				}else {
					//http://www.valvesoftware.com/publications/2007/SIGGRAPH2007_AlphaTestedMagnification.pdf
					var distance:Var = tex(vs.uvVarying,diffSampler,null,material.diffTexture.flags).w;
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
		
		public function getPhongColor(i:int):Var {
			var lightColor:Var=uniformLightColor(i)
			var lightPower:Var =lightColor.w;
			var specularPow:Var = specular.x;
			
			var normal:Var = vs.normVarying;
			if (material.normalMapAble) {
				var tangent:Var = vs.tangentVarying;
				var biTangent:Var = crs(normal, tangent);
				var normalMap:Var = sub(mul(tex(vs.uvVarying, normalmapSampler,null,material.normalmapTexture.flags),2),1);
			}
			
			var l:Var = vs.posLightVaryings[i];
			if (material.normalMapAble) {
				n = normalMap;
				l = local2tangent(tangent,biTangent,normal,l);
			}else {
				n = normal;
			}
			var cosTheta:Var = sat(dp3(n,l));
			if(material.specularAble||material.reflectTexture){
				e = vs.eyeDirectionVarying;
				if (material.normalMapAble) {
					e = local2tangent(tangent,biTangent,normal,e);
				}
				var r:Var = nrm(sub(mul2([2, dp3(l, n), n]), l));
				var cosAlpha:Var = sat(dp3(e, r));
			}
			if (material.specularAble) {
				return add(ambientColor, mul2([lightColor, add(cosTheta, pow(cosAlpha, specularPow)), lightPower]));
			}else {
				return add(ambientColor, mul2([lightColor, cosTheta, lightPower]));
			}
			return null;
		}
		
		public function getDistanceColor(i:int):Var {
			var d:Var = sub(uniformLightPos(i), vs.modelPosVarying);
			return sat(sub(1,div(dp3(d,d),mul(mov(uniformLightVar(i).x),uniformLightVar(i).x))));
		}
		
		public function getSmoothColor(i:int):Var {
			var factor1:Var = uniformLightVar(i).y;
			var factor2:Var = uniformLightVar(i).z;
			var lightToPoint:Var = sub(vs.modelPosVarying, uniformLightPos(i));
			var lightAngleCosine:Var = dp3(nrm(mov(uniformLightPos(i))), nrm(lightToPoint));
			return sat(add(mul(factor1, lightAngleCosine), factor2));
		}
		
	}

}