package gl3d.shaders 
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.geom.Vector3D;
	import flShader.FlShader;
	import gl3d.core.Camera3D;
	import gl3d.core.Drawable3D;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.core.TextureSet;
	import gl3d.core.VertexBufferSet;
	import gl3d.core.View3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class PhongGLShader extends GLShader
	{
		private var drawable:Drawable3D;
		public function PhongGLShader() 
		{
		}
		
		override public function getVertexShader(material:Material):FlShader {
			return new PhongVertexShader(material);
		}
		
		override public function getFragmentShader(material:Material):FlShader {
			return new PhongFragmentShader(material);
		}
		
		override public function preUpdate(material:Material):void {
			super.preUpdate(material);
			
			drawable = material.wireframeAble?material.node.unpackedDrawable:material.node.drawable;
			
			textureSets= material.textureSets;
			buffSets.length = 0;
			buffSets[0] = drawable.pos;
			buffSets[1] = drawable.norm;
			buffSets[2] =textureSets.length?drawable.uv:null;
			buffSets[3] = material.normalMapAble?drawable.tangent:null;
			buffSets[4] = material.wireframeAble?drawable.targetPosition:null;
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
				var lightPos:Vector3D = view.light.world.position;
				context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 12, Vector.<Number>([lightPos.x,lightPos.y,lightPos.z,1]));//light pos
				color[3] = alpha;
				context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, color);//color
				view.light.color[3] = view.light.lightPower;
				context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1,view.light.color);//light color
				context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2,view.light.ambient);//ambient color 环境光
				context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3,Vector.<Number>([view.light.specularPower,0,0,0]));//x:specular pow, y:2
				context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 5,material.wireframeColor);//x:specular pow, y:2
				
				context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, vs.constMemLen, Vector.<Number>(vs.constPool));
				context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, fs.constMemLen, Vector.<Number>(fs.constPool));
				context.drawTriangles(drawable.index.buff);
			}
		}
		
	}

}