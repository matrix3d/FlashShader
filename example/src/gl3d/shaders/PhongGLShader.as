package gl3d.shaders 
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.geom.Vector3D;
	import flShader.FlShader;
	import gl3d.Camera3D;
	import gl3d.Material;
	import gl3d.Node3D;
	import gl3d.TextureSet;
	import gl3d.VertexBufferSet;
	import gl3d.View3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class PhongGLShader extends GLShader
	{
		public function PhongGLShader() 
		{
			textureSets = new Vector.<TextureSet>;
			buffSets = new Vector.<VertexBufferSet>;
		}
		
		override public function getVertexShader(material:Material):FlShader {
			return new PhongVertexShader(material);
		}
		
		override public function getFragmentShader(material:Material):FlShader {
			return new PhongFragmentShader(material);
		}
		
		override public function preUpdate(material:Material):void {
			super.preUpdate(material);
			textureSets= material.textureSets;
			buffSets[0] = material.node.drawable.pos;
			buffSets[1] = material.node.drawable.norm;
			buffSets[2] =textureSets.length?material.node.drawable.uv:null;
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
				
				programSet.update(context);
				context.setProgram(programSet.program);
				
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
				
				context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, fs.constMemLen, Vector.<Number>(fs.constPool));
				context.drawTriangles(node.drawable.index.buff);
			}
		}
		
	}

}