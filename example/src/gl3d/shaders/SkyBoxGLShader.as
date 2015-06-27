package gl3d.shaders 
{
	import flash.display3D.Context3DProgramType;
	import gl3d.core.Camera3D;
	import gl3d.core.GL;
	import gl3d.core.Material;
	import as3Shader.AS3Shader;
	import gl3d.core.Node3D;
	import gl3d.core.View3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class SkyBoxGLShader extends GLShader
	{
		
		public function SkyBoxGLShader() 
		{
			
		}
		override public function getVertexShader(material:Material):AS3Shader 
		{
			return new SkyBoxVertexShader;
		}
		
		override public function getFragmentShader(material:Material):AS3Shader 
		{
			return new SkyBoxFragmentShader(vs as SkyBoxVertexShader);
		}
		
		override public function preUpdate(material:Material):void 
		{
			super.preUpdate(material);
			textureSets.length = 0;
			textureSets[0] = material.diffTexture;
			buffSets.length = 0;
			buffSets[0] = material.node.drawable.pos;
		}
		
		override public function update(material:Material):void 
		{
			super.update(material);
			var context:GL = material.view.gl3d;
			if (programSet) {
				var view:View3D = material.view;
				var camera:Camera3D = material.camera;
				var node:Node3D = material.node;
				var svs:SkyBoxVertexShader = vs as SkyBoxVertexShader;
				var sfs:SkyBoxFragmentShader = fs as SkyBoxFragmentShader;
				context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, svs.m.index, node.world, true);
				context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, svs.v.index, camera.view, true);
				context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, svs.p.index, camera.perspective, true);
				context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, svs.camPos.index, new <Number>[camera.x,camera.y,camera.z,1]);
				context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, vs.constMemLen, vs.constPoolVec);
				context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, fs.constMemLen, fs.constPoolVec);
				context.drawTriangles(node.drawable.index.buff);
			}
		}
		
	}

}