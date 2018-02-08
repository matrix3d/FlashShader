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
		private var e:Var;
		private var n:Var;
		private var diffmap:Var;
		public var wireframeColor:Var //uniform();
		public var diffColor:Var //= uniform();
		//public var lightColor:Var //= //uniform();
		public var specular:Var //= //uniform();
		public var ambientColor:Var //= //uniform();
		
		public var diffSampler:Var// = sampler();
		public var normalmapSampler:Var// = sampler();
		public var reflectSampler:Var// = sampler();
		private var pvs:PhongVertexShader ;
		public function PhongFragmentShader() 
		{
			super(Context3DProgramType.FRAGMENT);
			diffSampler = samplerDiff();
			normalmapSampler = samplerNormalmap();
			reflectSampler = samplerReflect();
			wireframeColor = uniformWireframeColor();
			diffColor = uniformMaterialColor();
			specular = uniformSpecular();
			ambientColor = uniformAmbient();
		}
		
		override public function build():void {
			pvs = vs as PhongVertexShader;
			if(!material.writeDepth){
				if (material.wireframeAble) {
					var tp:Var = mov(pvs.targetPositionVarying);
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
							var shadowLightPos:Var = pvs.shadowLightPoss[i];
							var shadowLightXY:Var = add(mul(div(shadowLightPos.xy, shadowLightPos.w), [.5, -.5]), .5);
							var shadowLightDepth:Var = tex(shadowLightXY, samplerShadowmaps(i));
							var curDepth:Var = div(shadowLightPos.z, shadowLightPos.w);
							curPhongColor = mul(curPhongColor,slt(curDepth,shadowLightDepth));
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
					sat(phongColor.xyz, phongColor.xyz);
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
					var refc:Var = tex(pvs.reflected, reflectSampler, null,material.reflectTexture.flags);
					mul(diffColor.xyz,refc.xyz,diffColor.xyz);
				}
				if(material.fogAble){
					var fog:Fog = material.view.fog;
					if (fog.mode != Fog.FOG_NONE) {
						var d:Var = distance(uniformCameraPos(), pvs.modelPosVarying, 3);
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
				oc = div(pvs.opVarying.z,pvs.opVarying.w);
			}
		}
		
		public function getDiffColor():Var {
			if (material.diffTexture==null) {
				var diffColor:Var = mov(this.diffColor);
			}else {
				diffmap = tex(pvs.uvVarying, diffSampler, null, material.diffTexture.flags);
				if (!material.isDistanceField) {
					diffColor = mul(diffmap, this.diffColor);
					if (material.alphaThreshold > 0) {
						kil(sub(diffmap.w,material.alphaThreshold).x);
					}
				}else {
					//http://www.valvesoftware.com/publications/2007/SIGGRAPH2007_AlphaTestedMagnification.pdf
					var distance:Var = diffmap.w;
					var smoothing:Var = fwidth(distance);
					var alpha:Var = sat(smoothstep(sub(0.5 , smoothing),add( 0.5 , smoothing), distance));
					diffColor = sub(1, alpha);
				}
			}
			if (material.vertexColorAble){
				mul(pvs.colorVarying, diffColor,diffColor);
			}
			
			if (material.border){
				var buv:Var = pvs.uvVarying;
				var borderWidth:int = 1;
				//var zeroone:Var=mov([0, borderWidth])
				var fw:Var = fwidth(buv);
				var borderOffsets:Var = vec4(0,0,fw.x,fw.y)//div(zeroone.xxyy, uniformTextureSize().xyxy);	//borderOffset= 0011/whwh
				var borderOffsetsAddUV:Var = add(buv.xyxy,borderOffsets);				//borderOffsetsAddUV = borderOffset + uv.xyxy
				var negborderOffsetsAddUV:Var = sub(buv.xyxy,borderOffsets);		//negborderOffsetsAddUV = negBorderOffsets + uv.xyxy
				
				if (material.uvMuler || material.uvAdder){
					var uvma:Var = mov(uniformUVMulAdder());
					var maxuv:Var = add(uvma.xy,uvma.zw);
					min(borderOffsetsAddUV, maxuv.xyxy, borderOffsetsAddUV);
					max(negborderOffsetsAddUV, uvma.zwzw, negborderOffsetsAddUV);
				}
				//isBorder = 周围上下左右4像素的最大值
				var isBorder:Var = tex(borderOffsetsAddUV.zy, diffSampler, null, material.diffTexture.flags);
				max(isBorder, tex(negborderOffsetsAddUV.zy, diffSampler, null, material.diffTexture.flags),isBorder);
				max(isBorder, tex(borderOffsetsAddUV.xw, diffSampler, null, material.diffTexture.flags),isBorder);
				max(isBorder, tex(negborderOffsetsAddUV.xw, diffSampler, null, material.diffTexture.flags),isBorder);
				//软边 color = mix(texColor,borderColor,(1-tex.alpha)*isBorder.alpha);
				diffColor = mix(diffColor,[0,0,0,1],mul(sub(1,diffmap.w),isBorder.w/*mul(slt(diffColor.w,.8),sge(isBorder.w,.8))*/),diffColor);
				//硬边 如果当前透明度小于一个值 并且 周围像素最大值大于一个值(证明边上有像素)
				//mix(diffmap.xyzw,[1,0,0,1],mul(slt(diffmap.w,.8),sge(isBorder.w,.8)),diffmap.xyzw);
			}
			
			return material.gray?diffColor.xxxw:diffColor;
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
			
			var normal:Var = pvs.normVarying;
			if (material.normalMapAble) {
				var tangent:Var = pvs.tangentVarying;
				var biTangent:Var = crs(normal, tangent);
				var normalMap:Var = sub(mul(tex(pvs.uvVarying, normalmapSampler,null,material.normalmapTexture.flags),2),1);
			}
			
			var l:Var = pvs.posLightVaryings[i];
			if (material.normalMapAble) {
				n = normalMap;
				l = local2tangent(tangent,biTangent,normal,l);
			}else {
				n = normal;
			}
			var cosTheta:Var = sat(add(mul(.5,dp3(n,l)),.5));
			if(material.specularAble||material.reflectTexture){
				e = pvs.eyeDirectionVarying;
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
			var d:Var = sub(uniformLightPos(i), pvs.modelPosVarying);
			return sat(sub(1,div(dp3(d,d),mul(mov(uniformLightVar(i).x),uniformLightVar(i).x))));
		}
		
		public function getSmoothColor(i:int):Var {
			var factor1:Var = uniformLightVar(i).y;
			var factor2:Var = uniformLightVar(i).z;
			var lightToPoint:Var = sub(pvs.modelPosVarying, uniformLightPos(i));
			var lightAngleCosine:Var = dp3(nrm(mov(uniformLightPos(i))), nrm(lightToPoint));
			return sat(add(mul(factor1, lightAngleCosine), factor2));
		}
		
	}

}