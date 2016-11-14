package gl3d.core.shaders 
{
	import as3Shader.Var;
	import flash.display3D.Context3DProgramType;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import gl3d.core.Camera3D;
	import gl3d.core.Light;
	import gl3d.core.Material;
	import gl3d.core.renders.GL;
	/**
	 * ...
	 * @author lizhi
	 */
	public class GLBinder 
	{
		public var v:Var;
		private var index:int;
		private var as3shader:GLAS3Shader;
		public function GLBinder(as3shader:GLAS3Shader,v:Var,index:int=0) 
		{
			this.as3shader = as3shader;
			this.index = index;
			this.v = v;
		}
		//uniform
		public function bindModelUniform(shader:GLShader, material:Material,isLastSameMaterial:Boolean):void {
			material.view.renderer.gl3d.setProgramConstantsFromMatrix(as3shader.programType, v.index,material.node.world,true);
		}
		public function bindViewUniform(shader:GLShader, material:Material, isLastSameMaterial:Boolean):void {
			if (!isLastSameMaterial) material.view.renderer.gl3d.setProgramConstantsFromMatrix(as3shader.programType, v.index,material.camera.world2local,true);
		}
		public function bindPerspectiveUniform(shader:GLShader, material:Material,isLastSameMaterial:Boolean):void {
			if (!isLastSameMaterial) material.view.renderer.gl3d.setProgramConstantsFromMatrix(as3shader.programType, v.index,material.camera.perspective,true);
		}
		public function bindWorld2localUniform(shader:GLShader, material:Material,isLastSameMaterial:Boolean):void {
			material.view.renderer.gl3d.setProgramConstantsFromMatrix(as3shader.programType, v.index,material.node.world2local,true);
		}
		
		public function bindLightPosUniform(shader:GLShader, material:Material,isLastSameMaterial:Boolean):void {
			if (!isLastSameMaterial) {
				var pos:Vector3D = material.view.lights[index].world.position;
				pos.w = 1;
				material.view.renderer.gl3d.setProgramConstantsFromVector3D(as3shader.programType, v.index,pos);
			}
		}
		public function bindLightShadowCameraWorld(shader:GLShader, material:Material,isLastSameMaterial:Boolean):void {
			if (!isLastSameMaterial) {
				// TODO : 优化
				var c:Camera3D = material.view.lights[index].shadowCamera as Camera3D;
				var m2:Matrix3D = c.world.clone();
				m2.append(c.perspective);
				material.view.renderer.gl3d.setProgramConstantsFromMatrix(as3shader.programType,v.index,m2,true);
			}
		}
		public function bindCameraPosUniform(shader:GLShader, material:Material,isLastSameMaterial:Boolean):void {
			if (!isLastSameMaterial) {
				var pos:Vector3D = material.camera.world.position;
				material.view.renderer.gl3d.setProgramConstantsFromVector3D(as3shader.programType, v.index,pos);
			}
		}
		
		public function bindTimeUniform(shader:GLShader, material:Material,isLastSameMaterial:Boolean):void {
			if (!isLastSameMaterial) {
				material.view.renderer.gl3d.setProgramConstantsFromXYZW(as3shader.programType, v.index,material.view.time,material.view.time,material.view.time,material.view.time);
			}
		}
		
		public function bindPixelSizeUniform(shader:GLShader, material:Material,isLastSameMaterial:Boolean):void {
			if (!isLastSameMaterial) {
				material.view.renderer.gl3d.setProgramConstantsFromXYZW(as3shader.programType, v.index,material.view.stage3dWidth,material.view.stage3dWidth,1/material.view.stage3dWidth,1/material.view.stage3dHeight);
			}
		}
		public function bindTextureSizeUniform(shader:GLShader, material:Material,isLastSameMaterial:Boolean):void {
			if (!isLastSameMaterial) {
				material.view.renderer.gl3d.setProgramConstantsFromXYZW(as3shader.programType, v.index,material.diffTexture.width,material.diffTexture.height);
			}
		}
		public function bindUVMulAddUniform(shader:GLShader, material:Material,isLastSameMaterial:Boolean):void {
			if (!isLastSameMaterial) {
				material.view.renderer.gl3d.setProgramConstantsFromXYZW(as3shader.programType, v.index, 
				material.uvMuler?material.uvMuler[0]:1,
				material.uvMuler?material.uvMuler[1]:1,
				material.uvAdder?material.uvAdder[0]:0,
				material.uvAdder?material.uvAdder[1]:0)
			}
		}
		public function bindJointsQuatUniform(shader:GLShader, material:Material,isLastSameMaterial:Boolean):void {
			material.view.renderer.gl3d.setProgramConstantsFromVector(as3shader.programType, v.index,material.node.skin.skinFrame.quaternions);
		}
		public function bindJointsMatrixUniform(shader:GLShader, material:Material,isLastSameMaterial:Boolean):void {
			//if (v.used) {
				var mats:Vector.<Matrix3D> = material.node.skin.skinFrame.matrixs;
				var start:int = v.index;
				for (var i:int = 0; i < mats.length;i++ ) {
					material.view.renderer.gl3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, start+i*4, mats[i], true);
				}
			//}
		}
		public function bindMaterialColorUniform(shader:GLShader, material:Material,isLastSameMaterial:Boolean):void {
			if (!isLastSameMaterial) material.view.renderer.gl3d.setProgramConstantsFromVector3D(as3shader.programType, v.index,material.color);
		}
		public function bindLightColorUniform(shader:GLShader, material:Material,isLastSameMaterial:Boolean):void {
			if (!isLastSameMaterial) material.view.renderer.gl3d.setProgramConstantsFromVector3D(as3shader.programType, v.index,material.view.lights[index].color);
		}
		public function bindLightColorVar(shader:GLShader, material:Material,isLastSameMaterial:Boolean):void {
			if (!isLastSameMaterial) {
				var light:Light = material.view.lights[index];
				var factor1:Number = 1/ (Math.cos(light.innerConeAngle/2)- Math.cos(light.outerConeAngle/2));
				var factor2:Number = 1- Math.cos(light.innerConeAngle/2)* factor1;
				material.view.renderer.gl3d.setProgramConstantsFromXYZW(as3shader.programType,v.index, light.distance,factor1,factor2);
			}
		}
		public function bindAmbientUniform(shader:GLShader, material:Material,isLastSameMaterial:Boolean):void {
			if (!isLastSameMaterial) material.view.renderer.gl3d.setProgramConstantsFromVector3D(as3shader.programType, v.index,material.ambient);
		}
		public function bindSpecularUniform(shader:GLShader, material:Material,isLastSameMaterial:Boolean):void {
			if (!isLastSameMaterial) {
				material.view.renderer.gl3d.setProgramConstantsFromXYZW(as3shader.programType, v.index,material.specularPower);
			}
		}
		public function bindWireframeColorUniform(shader:GLShader, material:Material,isLastSameMaterial:Boolean):void {
			if (!isLastSameMaterial) material.view.renderer.gl3d.setProgramConstantsFromVector3D(as3shader.programType, v.index,material.wireframeColor);
		}
		public function bindTerrainScaleVar(shader:GLShader, material:Material,isLastSameMaterial:Boolean):void {
			if (!isLastSameMaterial) material.view.renderer.gl3d.setProgramConstantsFromVector3D(as3shader.programType, v.index,material.terrainScale);
		}
		//textures
		public function bindDiffSampler(shader:GLShader, material:Material,isLastSameMaterial:Boolean):void {
			shader.textureSets[v.index] = material.diffTexture;
		}
		public function bindNormalmapSampler(shader:GLShader, material:Material,isLastSameMaterial:Boolean):void {
			shader.textureSets[v.index] = material.normalmapTexture;
		}
		public function bindLightmapSampler(shader:GLShader, material:Material,isLastSameMaterial:Boolean):void {
			shader.textureSets[v.index] = material.lightmapTexture;
		}
		public function bindReflectSampler(shader:GLShader, material:Material,isLastSameMaterial:Boolean):void {
			shader.textureSets[v.index] = material.reflectTexture;
		}
		public function bindTerrainsSampler(shader:GLShader, material:Material,isLastSameMaterial:Boolean):void {
			shader.textureSets[v.index] = material.terrainTextureSets[index];
		}
		public function bindShadowmapsSampler(shader:GLShader, material:Material,isLastSameMaterial:Boolean):void {
			shader.textureSets[v.index] = material.view.lights[index].shadowMap;
		}
		//buffs
		public function bindPosBuff(shader:GLShader,material:Material,isLastSameMaterial:Boolean):void {
			//if (v.used) {
				shader.buffSets[v.index] = (material.node.skin&&material.node.skin.useCpu&&material.node.drawable.pos.cpuSkin)?material.node.drawable.pos.cpuSkin:material.node.drawable.pos;
			//}
		}
		public function bindNormBuff(shader:GLShader,material:Material,isLastSameMaterial:Boolean):void {
			//if (v.used) {
				shader.buffSets[v.index] = (material.node.skin&&material.node.skin.useCpu&&material.node.drawable.norm.cpuSkin)?material.node.drawable.norm.cpuSkin:material.node.drawable.norm;
			//}
		}
		public function bindTangentBuff(shader:GLShader,material:Material,isLastSameMaterial:Boolean):void {
			shader.buffSets[v.index] = material.node.drawable.tangent;
		}
		public function bindUVBuff(shader:GLShader,material:Material,isLastSameMaterial:Boolean):void {
			shader.buffSets[v.index] = material.node.drawable.uv;
		}
		public function bindRandomBuff(shader:GLShader,material:Material,isLastSameMaterial:Boolean):void {
			shader.buffSets[v.index] = material.node.drawable.random;
		}
		public function bindSphereRandomBuff(shader:GLShader,material:Material,isLastSameMaterial:Boolean):void {
			shader.buffSets[v.index] = material.node.drawable.sphereRandom;
		}
		public function bindTargetPositionBuff(shader:GLShader,material:Material,isLastSameMaterial:Boolean):void {
			shader.buffSets[v.index] = material.node.drawable.targetPosition;
		}
		public function bindUV2Buff(shader:GLShader,material:Material,isLastSameMaterial:Boolean):void {
			shader.buffSets[v.index] = material.node.drawable.uv2;
		}
		public function bindJointsBuff(shader:GLShader,material:Material,isLastSameMaterial:Boolean):void {
			shader.buffSets[v.index] = material.node.drawable.joint;
		}
		/*public function bindQuatJointsBuff(shader:GLShader,material:Material):void {
			if(v.used)shader.buffSets[v.index] = material.node.drawable.quatJoints;
		}*/
		public function bindWeightsBuff(shader:GLShader,material:Material,isLastSameMaterial:Boolean):void {
			shader.buffSets[v.index] = material.node.drawable.weight;
		}
		/*public function bindCpuSkinPosBuff(shader:GLShader,material:Material):void {
			if(v.used)shader.buffSets[v.index] = material.node.drawable.pos.cpuSkinPos;
		}
		public function bindCpuSkinNormBuff(shader:GLShader,material:Material):void {
			if(v.used)shader.buffSets[v.index] = material.node.drawable.pos.cpuSkinNorm;
		}*/
		
	}

}