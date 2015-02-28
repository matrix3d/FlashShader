package gl3d.shaders.particle {
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.geom.Vector3D;
	import as3Shader.AS3Shader;
	import gl3d.core.Camera3D;
	import gl3d.core.Drawable3D;
	import gl3d.core.GL3D;
	import gl3d.core.Material;
	import gl3d.meshs.Meshs;
	import gl3d.core.Node3D;
	import gl3d.shaders.GLShader;
	import gl3d.shaders.PhongFragmentShader;
	import gl3d.core.View3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class ParticleGLShader extends GLShader
	{
		
		public function ParticleGLShader() 
		{
			
		}
		
		override public function getVertexShader(material:Material):AS3Shader {
			return new ParticleVertexShader(material);
		}
		
		override public function getFragmentShader(material:Material):AS3Shader {
			return new ParticleFragmentShader(material,vs as ParticleVertexShader);
		}
		
		override public function preUpdate(material:Material):void {
			super.preUpdate(material);
			textureSets[0] = material.diffTexture;
			buffSets.length = 0;
			buffSets.length = 0;
			var drawable:Drawable3D = material.node.drawable;
			var pvs:ParticleVertexShader = vs as ParticleVertexShader;
			if (pvs.pos.used) {
				buffSets[pvs.pos.index] = drawable.pos;
			}
			if (pvs.norm.used) {
				buffSets[pvs.norm.index] = drawable.norm;
			}
			if (pvs.uv.used) {
				buffSets[pvs.uv.index] = drawable.uv;
			}
			if (pvs.random.used) {
				buffSets[pvs.random.index] = drawable.random;
			}
			if (pvs.sphereRandom.used) {
				buffSets[pvs.sphereRandom.index] = drawable.sphereRandom;
			}
		}
		
		override public function update(material:Material):void 
		{
			super.update(material);
			var context:GL3D = material.view.gl3d;
			if (programSet) {
				var view:View3D = material.view;
				var camera:Camera3D = material.camera;
				var node:Node3D = material.node;
				var alpha:Number = material.alpha;
				var color:Vector.<Number> = material.color;
				var pvs:ParticleVertexShader = vs as ParticleVertexShader;
				
				if (pvs.model.used) {
					context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, pvs.model.index, node.world, true);
				}
				if (pvs.view.used) {
					context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, pvs.view.index, camera.view, true);
				}
				if (pvs.perspective.used) {
					context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, pvs.perspective.index, camera.perspective, true);
				}
				if (pvs.time.used) {
					context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, pvs.time.index, Vector.<Number>([view.time,0,0,0]));
				}
				color[3] = alpha;
				context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, color);//color
				context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, vs.constMemLen, vs.constPoolVec);
				context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, fs.constMemLen, fs.constPoolVec);
				context.drawTriangles(node.drawable.index.buff);
			}
		}
	}

}