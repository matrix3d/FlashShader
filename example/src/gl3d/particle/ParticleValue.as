package gl3d.particle 
{
	import as3Shader.Var;
	import flash.geom.Vector3D;
	import gl3d.core.shaders.GLAS3Shader;
	/**
	 * ...
	 * @author ...
	 */
	public class ParticleValue 
	{
		public var max:Array;
		public var min:Array;
		public function ParticleValue(min:Array,max:Array) 
		{
			this.min = min;
			this.max = max;
		}
		
		public function getValue(shader:GLAS3Shader,v:Object):Object {
			if ((min+"") != (max+"")) {
				return shader.mix(min, max, v);
			}
			return min;
		}
	}

}