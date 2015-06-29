package gl3d.core.shaders 
{
	import as3Shader.AS3Shader;
	import as3Shader.Creator;
	import as3Shader.Var;
	import flash.display3D.Context3DProgramType;
	import gl3d.core.Material;
	/**
	 * ...
	 * @author lizhi
	 */
	public class GLAS3Shader extends AS3Shader
	{
		private var binds:Vector.<Function> = new Vector.<Function>;
		public function GLAS3Shader(programType:String=Context3DProgramType.VERTEX,creator:Creator=null) 
		{
			super(programType, creator);
		}
		
		public function bind(shader:GLShader,material:Material):void {
			for each(var binder:Function in binds) {
				binder(shader,material);
			}
		}
		
		//textures
		public function samplerDiff():Var {
			var samp:Var = sampler();
			var binder:GLBinder = new GLBinder(samp);
			binds.push(binder.bindDiffSampler);
			return samp;
		}
		public function samplerNormalmap():Var {
			var samp:Var = sampler();
			var binder:GLBinder = new GLBinder(samp);
			binds.push(binder.bindNormalmapSampler);
			return samp;
		}
		public function samplerLightmap():Var {
			var samp:Var = sampler();
			var binder:GLBinder = new GLBinder(samp);
			binds.push(binder.bindLightmapSampler);
			return samp;
		}
		public function samplerReflect():Var {
			var samp:Var = sampler();
			var binder:GLBinder = new GLBinder(samp);
			binds.push(binder.bindReflectSampler);
			return samp;
		}
		public function samplerTerrains():Var {
			var samp:Var = sampler();
			var binder:GLBinder = new GLBinder(samp);
			binds.push(binder.bindTerrainsSampler);
			return samp;
		}
		
		//buffs
		public function buffPos():Var {
			var buff:Var = buff();
			var binder:GLBinder = new GLBinder(buff);
			binds.push(binder.bindPosBuff);
			return buff;
		}
		public function buffNorm():Var {
			var buff:Var = buff();
			var binder:GLBinder = new GLBinder(buff);
			binds.push(binder.bindNormBuff);
			return buff;
		}
		public function buffTangent():Var {
			var buff:Var = buff();
			var binder:GLBinder = new GLBinder(buff);
			binds.push(binder.bindTangentBuff);
			return buff;
		}
		public function buffUV():Var {
			var buff:Var = buff();
			var binder:GLBinder = new GLBinder(buff);
			binds.push(binder.bindUVBuff);
			return buff;
		}
		public function buffRandom():Var {
			var buff:Var = buff();
			var binder:GLBinder = new GLBinder(buff);
			binds.push(binder.bindRandomBuff);
			return buff;
		}
		public function buffSphereRandom():Var {
			var buff:Var = buff();
			var binder:GLBinder = new GLBinder(buff);
			binds.push(binder.bindSphereRandomBuff);
			return buff;
		}
		public function buffTargetPosition():Var {
			var buff:Var = buff();
			var binder:GLBinder = new GLBinder(buff);
			binds.push(binder.bindTargetPositionBuff);
			return buff;
		}
		public function buffUV2():Var {
			var buff:Var = buff();
			var binder:GLBinder = new GLBinder(buff);
			binds.push(binder.bindUV2Buff);
			return buff;
		}
		public function buffJoints():Var {
			var buff:Var = buff();
			var binder:GLBinder = new GLBinder(buff);
			binds.push(binder.bindJointsBuff);
			return buff;
		}
		public function buffQuatJoints():Var {
			var buff:Var = buff();
			var binder:GLBinder = new GLBinder(buff);
			binds.push(binder.bindQuatJointsBuff);
			return buff;
		}
		public function buffWeights():Var {
			var buff:Var = buff();
			var binder:GLBinder = new GLBinder(buff);
			binds.push(binder.bindWeightsBuff);
			return buff;
		}
		public function buffCpuSkinPos():Var {
			var buff:Var = buff();
			var binder:GLBinder = new GLBinder(buff);
			binds.push(binder.bindCpuSkinPosBuff);
			return buff;
		}
		
	}

}