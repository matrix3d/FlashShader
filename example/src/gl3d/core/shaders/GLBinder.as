package gl3d.core.shaders 
{
	import as3Shader.Var;
	import gl3d.core.Material;
	/**
	 * ...
	 * @author lizhi
	 */
	public class GLBinder 
	{
		private var v:Var;
		
		public function GLBinder(v:Var) 
		{
			this.v = v;
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
			throw "no impl"
			//if (v.used) shader.textureSets[v.index] = material.diffTexture;
		}
		
		//buffs
		public function bindPosBuff(shader:GLShader,material:Material):void {
			if(v.used)shader.buffSets[v.index] = material.node.drawable.pos;
		}
		public function bindNormBuff(shader:GLShader,material:Material):void {
			if(v.used)shader.buffSets[v.index] = material.node.drawable.norm;
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
		public function bindQuatJointsBuff(shader:GLShader,material:Material):void {
			if(v.used)shader.buffSets[v.index] = material.node.drawable.quatJoints;
		}
		public function bindWeightsBuff(shader:GLShader,material:Material):void {
			if(v.used)shader.buffSets[v.index] = material.node.drawable.weights;
		}
		public function bindCpuSkinPosBuff(shader:GLShader,material:Material):void {
			if(v.used)shader.buffSets[v.index] = material.node.drawable.cpuSkinPos;
		}
		
	}

}