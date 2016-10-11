package gl3d.shaders 
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import as3Shader.AS3Shader;
	import gl3d.core.Camera3D;
	import gl3d.core.Drawable;
	import gl3d.core.renders.GL;
	import gl3d.core.shaders.GLAS3Shader;
	import gl3d.core.shaders.GLShader;
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
		public function PhongGLShader() 
		{
		}
		
		override public function getVertexShader(material:Material):GLAS3Shader {
			return new PhongVertexShader(material);
		}
		
		override public function getFragmentShader(material:Material):GLAS3Shader {
			return new PhongFragmentShader(material,vs as PhongVertexShader);
		}
	}

}