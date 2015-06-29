package gl3d.shaders 
{
	import as3Shader.AS3Shader;
	import flash.display3D.Context3DProgramType;
	import gl3d.core.Camera3D;
	import gl3d.core.Drawable3D;
	import gl3d.core.GL;
	import gl3d.core.shaders.GLAS3Shader;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.core.shaders.GLShader;
	import gl3d.core.TextureSet;
	import gl3d.core.View3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class DeferredGLShader extends GLShader
	{
		public var diff:TextureSet;
		public function DeferredGLShader() 
		{
			
		
		}
		
		override public function preUpdate(material:Material):void {
			super.preUpdate(material);
			textureSets[0] = material.diffTexture;
			var drawable:Drawable3D = material.node.drawable;
			buffSets[0] = drawable.pos;
			buffSets[1] = drawable.uv;
			//buffSets[2] = drawable.norm;
		}
		
		override public function update(material:Material):void 
		{
			super.update(material);
			var context:GL = material.view.gl3d;
			if (programSet) {
				var view:View3D = material.view;
				var camera:Camera3D = material.camera;
				var node:Node3D = material.node;
				var drawable:Drawable3D = material.node.drawable;
			
				context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, node.world, true);
				context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 4, camera.view, true);
				context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 8, camera.perspective, true);
				context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, vs.constMemLen, vs.constPoolVec);
				context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, fs.constMemLen, fs.constPoolVec);
				context.drawTriangles(drawable.index.buff);
			}
		}
		
		override public function getVertexShader(material:Material):GLAS3Shader {
			return new DeferredVertexShader(material);
		}
		
		override public function getFragmentShader(material:Material):GLAS3Shader {
			return new DeferredFragmentShader(material);
		}
		
	}

}
import as3Shader.AS3Shader;
import as3Shader.Var;
import flash.display3D.Context3DProgramType;
import gl3d.core.Material;
import gl3d.core.shaders.GLAS3Shader;

class DeferredVertexShader extends GLAS3Shader {
	private var m:Material;
	public function DeferredVertexShader(m:Material) 
	{
		super();
		this.m = m;
		
	}
	override public function build():void {
		var pos:Var = VA();
		var uv:Var = VA(1);
		var norm:Var = VA(2);
		
		var model:Var = C(0,4);
		var view:Var = C(4,4);
		var perspective:Var = C(8,4);
		
		pos = m44(pos, model);
		pos = m44(pos, view);
		pos = m44(pos, perspective);
		
		op = pos;
		
		mov(uv, V());
	}
}
class DeferredFragmentShader extends GLAS3Shader {
	private var m:Material;
	public function DeferredFragmentShader(m:Material) 
	{
		super( Context3DProgramType.FRAGMENT);
		this.m = m;
	}
	
	override public function build():void {
		tex(V(),FS(), oc);
	}
}
