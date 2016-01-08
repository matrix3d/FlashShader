package 
{
	import flash.display3D.Context3DTextureFormat;
	import gl3d.core.Quat;
	import gl3d.core.TextureSet;
	import gl3d.shaders.DeferredGLShader;
	import gl3d.util.Utils;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestDeferred extends BaseExample
	{
		
		public function TestDeferred() 
		{
			
		}
		
		override public function initNode():void 
		{
			super.initNode();
			//var ds:DeferredGLShader = new DeferredGLShader;
			//teapot.material.shader = ds;
			//ds.diff = new TextureSet;
			//t1.needFormat = Context3DTextureFormat.RGBA_HALF_FLOAT;
			
			var quat:Quat = new Quat;
			quat.scaleX = quat.scaleY = .5;
			view.scene.addChild(quat);
			quat.material.diffTexture = material.diffTexture;
		}
		
	}

}