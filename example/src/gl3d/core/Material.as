package gl3d.core {
	import flash.display.BlendMode;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTriangleFace;
	import flash.geom.Vector3D;
	import as3Shader.AS3Shader;
	import gl3d.core.renders.GL;
	import gl3d.core.skin.Skin;
	import gl3d.meshs.Meshs;
	import gl3d.core.shaders.GLShader;
	import gl3d.shaders.PhongGLShader;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Material extends MaterialBase
	{
		
		public var shader:GLShader;
		private var lastNumLight:int = -1;
		public function Material(shader:GLShader=null) 
		{
			this.shader = shader||new PhongGLShader();
		}
		
		override public function draw(node:Node3D,view:View3D):void {
			this.view = view;
			this.camera = materialCamera||view.camera;
			this.node = node;
			if (node.drawable&&shader) {
				var context:GL = view.renderer.gl3d;
				var hasSkin:Boolean = node.skin && node.skin.skinFrame&&!node.skin.useCpu;
				if (gpuSkin!=hasSkin) {
					invalid = true;
					gpuSkin = hasSkin;
				}
				if (lightAble&&lastNumLight!=view.lights.length) {
					invalid = true;
					lastNumLight = view.lights.length;
				}
				if (invalid) {
					shader.invalid = true;
					invalid = false;
				}
				shader.update(this);
			}
		}
		
		
	}
}

