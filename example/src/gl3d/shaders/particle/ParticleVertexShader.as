package gl3d.shaders.particle 
{
	import as3Shader.AS3Shader;
	import as3Shader.Var;
	import flash.utils.getTimer;
	import gl3d.core.Material;
	import gl3d.particle.Particle;
	import gl3d.core.shaders.GLAS3Shader;
	/**
	 * ...
	 * @author lizhi
	 */
	public class ParticleVertexShader extends GLAS3Shader
	{
		private var material:Material;
		public var model:Var// = matrix();
		public var view:Var //= matrix();
		public var perspective:Var// = matrix();
		public var time:Var// = uniform();
		
		public var pos:Var //= buff();
		public var norm:Var //= buff();
		public var uv:Var //= buff();
		public var random:Var //= buff();
		public var sphereRandom:Var //= buff();
		
		public var uvVarying:Var = varying();
		public var colorVarying:Var = varying();
		public function ParticleVertexShader(material:Material) 
		{
			this.material = material;
			pos = buffPos();
			norm = buffNorm();
			uv = buffUV();
			random = buffRandom();
			sphereRandom = buffSphereRandom();
			
			model = uniformModel();
			view = uniformView();
			perspective = uniformPerspective();
			time = uniformTime();
		}
		
		override public function build():void {
			var particle:Particle = material.node as Particle;
			var time:Var = sub(mov(this.time),getTimer()).x;
			var pos:Var = mov(this.pos);
			var timeLife:Object = particle.timeLife.getValue(this, random.x);
			
			var trueTime:Var = div(time,timeLife);
			if (particle.isAddRandomLifeTime) {
				trueTime = sub(trueTime,random.y).x;
			}
			time = frc(trueTime).x;
			var size:Object;
			if (particle.scale) {
				size = particle.scale.getValue(this, time);
			}
			if (particle.loop>0) {
				var sizeMul:Var = slt(trueTime,particle.loop);
				if (size) {
					size = mul(sizeMul, size);
				}else {
					size = sizeMul;
				}
			}
			if (particle.isAddRandomLifeTime) {
				if (size) {
					size =mul(sge(trueTime, 0),size);
				}else {
					size = sge(trueTime, 0);
				}
			}
			if (size) {
				mul(size, pos,pos.xyz);
			}
			
			if (particle.pos) {
				add(pos, particle.pos.getValue(this,frc(mul(10, random.xyz))),pos.xyz);
			}
			
			var velocity:Object;
			if (particle.velocity) {
				
			}
			
			/*if (material.diffTexture) {
				if (particle.uv) {
					var newUv:Var = add(mul([particle.uv.z,particle.uv.w],uv), mul([particle.uv.x, particle.uv.y], time));
					mov(newUv, uvVarying);
				}else {
					mov(uv, uvVarying);
				}
			}*/
			
			//add(pos.xyz, mul2([getValue(particle.posScaleMin,particle.posScaleMax,time),time,sphereRandom]).xyz,pos.xyz);
			//var size:Object = getValue(particle.scaleMin,particle.scaleMax,time);
			var worldPos:Var = m44(pos, model);
			var viewPos:Var = m44(worldPos, view);
			
			//if(particle.isBillboard){
			//	add(viewPos.xy, mul(sub(uv, .5), size).xy, viewPos.xy);
			//}else {
				//mul(worldPos.xy, size, viewPos.xy);
			//}
			
			op = m44(viewPos, perspective);
			//var color:Object = getValue(particle.colorMin,particle.colorMax,time);
			mov(particle.color.getValue(this,time), colorVarying);
		}
		
		/*public function getValue(min:Object, max:Object, v:Var):Object {
			if ((min+"") != (max+"")) {
				return mix(mov(min), max, v);
			}
			return min;
		}*/
	}

}