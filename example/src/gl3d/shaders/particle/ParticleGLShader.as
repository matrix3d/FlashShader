package gl3d.shaders.particle {
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.geom.Vector3D;
	import flShader.FlShader;
	import gl3d.Camera3D;
	import gl3d.Material;
	import gl3d.meshs.Meshs;
	import gl3d.Node3D;
	import gl3d.shaders.GLShader;
	import gl3d.shaders.PhongFragmentShader;
	import gl3d.View3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class ParticleGLShader extends GLShader
	{
		
		public function ParticleGLShader() 
		{
			
		}
		
		override public function getVertexShader(material:Material):FlShader {
			return new ParticleVertexShader;
		}
		
		override public function getFragmentShader(material:Material):FlShader {
			return new ParticleFragmentShader;
		}
		
		override public function preUpdate(material:Material):void {
			super.preUpdate(material);
			textureSets= material.textureSets;
			buffSets.length = 0;
			buffSets[0] = material.node.drawable.pos;
			buffSets[1] = material.node.drawable.uv;
			if (material.node.drawable.random==null) {
				material.node.drawable.random = Meshs.computeRandom(material.node.drawable);
			}
			buffSets[2] = material.node.drawable.random;
		}
		
		override public function update(material:Material):void 
		{
			super.update(material);
			var context:Context3D = material.view.context;
			if (programSet) {
				var view:View3D = material.view;
				var camera:Camera3D = material.camera;
				var node:Node3D = material.node;
				var alpha:Number = material.alpha;
				var color:Vector.<Number> = material.color;
				
				context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, node.world, true);
				context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 4, camera.view, true);
				context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 8, camera.perspective, true);
				context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 12, Vector.<Number>([view.time,0,0,0]));
				color[3] = alpha;
				context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, color);//color
				
				context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, vs.constMemLen, Vector.<Number>(vs.constPool));
				context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, fs.constMemLen, Vector.<Number>(fs.constPool));
				context.drawTriangles(node.drawable.index.buff);
			}
		}
	}

}