package gl3d.shaders.particle 
{
	import as3Shader.AS3Shader;
	import as3Shader.Var;
	import gl3d.core.Material;
	import gl3d.particle.Particle;
	/**
	 * ...
	 * @author lizhi
	 */
	public class ParticleVertexShader extends AS3Shader
	{
		private var material:Material;
		public var model:Var = matrix();
		public var view:Var = matrix();
		public var perspective:Var = matrix();
		public var time:Var = uniform();
		
		public var pos:Var = buff();
		public var norm:Var = buff();
		public var uv:Var = buff();
		public var random:Var = buff();
		public var sphereRandom:Var = buff();
		
		public var uvVarying:Var = varying();
		public var colorVarying:Var = varying();
		public function ParticleVertexShader(material:Material) 
		{
			this.material = material;
			
		}
		
		override public function build():void {
			var time:Var = mov(this.time);
			var pos:Var = mov(this.pos);
			
			var particle:Particle = material.node as Particle;
			var timeLife:Object = getValue(particle.timeLifeMin, particle.timeLifeMax, random.x);
			if (particle.randomTimeLife) {
				time = frc(add(random.y,div(time,timeLife))).x;
			}else {
				time = frc(div(time,timeLife)).x;
			}
			
			if (material.diffTexture) {
				if (particle.uv) {
					var newUv:Var = add(mul([particle.uv.z,particle.uv.w],uv), mul([particle.uv.x, particle.uv.y], time));
					mov(newUv, uvVarying);
				}else {
					mov(uv, uvVarying);
				}
			}
			
			add(pos.xyz, mul2([getValue(particle.posScaleMin,particle.posScaleMax,time),time,sphereRandom]).xyz,pos.xyz);
			var size:Object = getValue(particle.scaleMin,particle.scaleMax,time);
			var worldPos:Var = m44(pos, model);
			var viewPos:Var = m44(worldPos, view);
			
			if(particle.isBillboard){
				add(viewPos.xy, mul(sub(uv, .5), size).xy, viewPos.xy);
			}else {
				//mul(worldPos.xy, size, viewPos.xy);
			}
			
			op = m44(viewPos, perspective);
			var color:Object = getValue(particle.colorMin,particle.colorMax,time);
			mov(color, colorVarying);
		}
		
		public function getValue(min:Object, max:Object, v:Var):Object {
			if ((min+"") != (max+"")) {
				return mix(mov(min), max, v);
			}
			return min;
		}
	}

}