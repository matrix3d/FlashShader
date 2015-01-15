package gl3d.shaders 
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flShader.FlShader;
	import gl3d.core.Camera3D;
	import gl3d.core.Drawable3D;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.core.View3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class LightMapGLShader extends GLShader
	{
		private var drawable:Drawable3D;
		public function LightMapGLShader() 
		{
			
		}
		override public function getVertexShader(material:Material):FlShader {
			return new LightMapVertexShader;
		}
		
		override public function getFragmentShader(material:Material):FlShader {
			return new LightMapFragmentShader;
		}
		
		override public function preUpdate(material:Material):void {
			super.preUpdate(material);
			
			drawable = material.node.drawable;
			
			textureSets[0] = material.diffTexture;
			textureSets[1] = material.lightmapTexture;
			buffSets.length = 0;
			buffSets[0] = drawable.pos;
			buffSets[1] = drawable.uv;
			buffSets[2] = drawable.lightmapUV;
		}
		
		override public function update(material:Material):void 
		{
			super.update(material);
			var context:Context3D = material.view.context;
			if (programSet) {
				var view:View3D = material.view;
				var camera:Camera3D = material.camera;
				var node:Node3D = material.node;
				
				context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, node.world, true);
				context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 4, camera.view, true);
				context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 8, camera.perspective, true);
				context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, vs.constMemLen, vs.constPoolVec);
				context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, fs.constMemLen, fs.constPoolVec);
				context.drawTriangles(drawable.index.buff);
			}
		}
		
	}

}