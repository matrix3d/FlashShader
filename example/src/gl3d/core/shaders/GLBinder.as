package gl3d.core.shaders 
{
	import as3Shader.Var;
	import flash.display3D.Context3DProgramType;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import gl3d.core.Material;
	/**
	 * ...
	 * @author lizhi
	 */
	public class GLBinder 
	{
		private var v:Var;
		private var index:int;
		private var as3shader:GLAS3Shader;
		private var tempvec4:Vector.<Number> = new Vector.<Number>(4);
		public function GLBinder(as3shader:GLAS3Shader,v:Var,index:int=0) 
		{
			this.as3shader = as3shader;
			this.index = index;
			this.v = v;
		}
		//uniform
		public function bindModelUniform(shader:GLShader, material:Material):void {
			if (v.used) material.view.renderer.gl3d.setProgramConstantsFromMatrix(as3shader.programType, v.index,material.node.world,true);
		}
		public function bindViewUniform(shader:GLShader, material:Material):void {
			if (v.used) material.view.renderer.gl3d.setProgramConstantsFromMatrix(as3shader.programType, v.index,material.camera.world2local,true);
		}
		public function bindPerspectiveUniform(shader:GLShader, material:Material):void {
			if (v.used) material.view.renderer.gl3d.setProgramConstantsFromMatrix(as3shader.programType, v.index,material.camera.perspective,true);
		}
		public function bindWorld2localUniform(shader:GLShader, material:Material):void {
			if (v.used) material.view.renderer.gl3d.setProgramConstantsFromMatrix(as3shader.programType, v.index,material.node.world2local,true);
		}
		
		public function bindLightPosUniform(shader:GLShader, material:Material):void {
			if (v.used) {
				var pos:Vector3D = material.view.lights[index].world.position;
				tempvec4[0] = pos.x;
				tempvec4[1] = pos.y;
				tempvec4[2] = pos.z;
				tempvec4[3] = 1;
				material.view.renderer.gl3d.setProgramConstantsFromVector(as3shader.programType, v.index,tempvec4);
			}
		}
		public function bindCameraPosUniform(shader:GLShader, material:Material):void {
			if (v.used) {
				var pos:Vector3D = material.camera.world.position;
				tempvec4[0] = pos.x;
				tempvec4[1] = pos.y;
				tempvec4[2] = pos.z;
				tempvec4[3] = 1;
				material.view.renderer.gl3d.setProgramConstantsFromVector(as3shader.programType, v.index,tempvec4);
			}
		}
		
		public function bindTimeUniform(shader:GLShader, material:Material):void {
			if (v.used) {
				tempvec4[0] = material.view.time;
				tempvec4[1] = material.view.time;
				tempvec4[2] = material.view.time;
				tempvec4[3] = material.view.time;
				material.view.renderer.gl3d.setProgramConstantsFromVector(as3shader.programType, v.index,tempvec4);
			}
		}
		
		public function bindPixelSizeUniform(shader:GLShader, material:Material):void {
			if (v.used) {
				tempvec4[0] = material.view.stage3dWidth;
				tempvec4[1] = material.view.stage3dHeight;
				tempvec4[2] = 1/material.view.stage3dWidth;
				tempvec4[3] = 1/material.view.stage3dHeight;
				material.view.renderer.gl3d.setProgramConstantsFromVector(as3shader.programType, v.index,tempvec4);
			}
		}
		public function bindJointsQuatUniform(shader:GLShader, material:Material):void {
			if (v.used) material.view.renderer.gl3d.setProgramConstantsFromVector(as3shader.programType, v.index,material.node.skin.skinFrame.quaternions);
		}
		public function bindJointsMatrixUniform(shader:GLShader, material:Material):void {
			if (v.used) {
				var mats:Vector.<Matrix3D> = material.node.skin.skinFrame.matrixs;
				var start:int = v.index;
				for (var i:int = 0; i < mats.length;i++ ) {
					material.view.renderer.gl3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, start+i*4, mats[i], true);
				}
			}
		}
		public function bindMaterialColorUniform(shader:GLShader, material:Material):void {
			if (v.used) material.view.renderer.gl3d.setProgramConstantsFromVector(as3shader.programType, v.index,material.color);
		}
		public function bindLightColorUniform(shader:GLShader, material:Material):void {
			if (v.used) material.view.renderer.gl3d.setProgramConstantsFromVector(as3shader.programType, v.index,material.view.lights[index].color);
		}
		public function bindAmbientUniform(shader:GLShader, material:Material):void {
			if (v.used) material.view.renderer.gl3d.setProgramConstantsFromVector(as3shader.programType, v.index,material.ambient);
		}
		public function bindSpecularUniform(shader:GLShader, material:Material):void {
			if (v.used) {
				tempvec4[0] = material.specularPower;
				material.view.renderer.gl3d.setProgramConstantsFromVector(as3shader.programType, v.index,tempvec4);
			}
		}
		public function bindWireframeColorUniform(shader:GLShader, material:Material):void {
			if (v.used) material.view.renderer.gl3d.setProgramConstantsFromVector(as3shader.programType, v.index,material.wireframeColor);
		}
		
		//textures
		public function bindDiffSampler(shader:GLShader, material:Material):void {
			if (v.used) shader.textureSets[v.index] = material.diffTexture;
		}
		public function bindNormalmapSampler(shader:GLShader, material:Material):void {
			if (v.used) shader.textureSets[v.index] = material.normalmapTexture;
		}
		public function bindLightmapSampler(shader:GLShader, material:Material):void {
			if (v.used) shader.textureSets[v.index] = material.lightmapTexture;
		}
		public function bindReflectSampler(shader:GLShader, material:Material):void {
			if (v.used) shader.textureSets[v.index] = material.reflectTexture;
		}
		public function bindTerrainsSampler(shader:GLShader, material:Material):void {
			if (v.used) shader.textureSets[v.index] = material.terrainTextureSets[index];
		}
		
		//buffs
		public function bindPosBuff(shader:GLShader,material:Material):void {
			if (v.used) {
				shader.buffSets[v.index] = (material.node.skin&&material.node.skin.useCpu&&material.node.drawable.pos.cpuSkin)?material.node.drawable.pos.cpuSkin:material.node.drawable.pos;
			}
		}
		public function bindNormBuff(shader:GLShader,material:Material):void {
			if (v.used) {
				shader.buffSets[v.index] = (material.node.skin&&material.node.skin.useCpu&&material.node.drawable.norm.cpuSkin)?material.node.drawable.norm.cpuSkin:material.node.drawable.norm;
			}
		}
		public function bindTangentBuff(shader:GLShader,material:Material):void {
			if(v.used)shader.buffSets[v.index] = material.node.drawable.tangent;
		}
		public function bindUVBuff(shader:GLShader,material:Material):void {
			if(v.used)shader.buffSets[v.index] = material.node.drawable.uv;
		}
		public function bindRandomBuff(shader:GLShader,material:Material):void {
			if(v.used)shader.buffSets[v.index] = material.node.drawable.random;
		}
		public function bindSphereRandomBuff(shader:GLShader,material:Material):void {
			if(v.used)shader.buffSets[v.index] = material.node.drawable.sphereRandom;
		}
		public function bindTargetPositionBuff(shader:GLShader,material:Material):void {
			if(v.used)shader.buffSets[v.index] = material.node.drawable.targetPosition;
		}
		public function bindUV2Buff(shader:GLShader,material:Material):void {
			if(v.used)shader.buffSets[v.index] = material.node.drawable.lightmapUV;
		}
		public function bindJointsBuff(shader:GLShader,material:Material):void {
			if(v.used)shader.buffSets[v.index] = material.node.drawable.joints;
		}
		/*public function bindQuatJointsBuff(shader:GLShader,material:Material):void {
			if(v.used)shader.buffSets[v.index] = material.node.drawable.quatJoints;
		}*/
		public function bindWeightsBuff(shader:GLShader,material:Material):void {
			if(v.used)shader.buffSets[v.index] = material.node.drawable.weights;
		}
		/*public function bindCpuSkinPosBuff(shader:GLShader,material:Material):void {
			if(v.used)shader.buffSets[v.index] = material.node.drawable.pos.cpuSkinPos;
		}
		public function bindCpuSkinNormBuff(shader:GLShader,material:Material):void {
			if(v.used)shader.buffSets[v.index] = material.node.drawable.pos.cpuSkinNorm;
		}*/
	}

}