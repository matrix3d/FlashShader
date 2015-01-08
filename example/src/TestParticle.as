package  
{
	import flash.display.BlendMode;
	import flash.display3D.Context3DCompareMode;
	import flash.utils.getTimer;
	import gl3d.core.Drawable3D;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.core.TextureSet;
	import gl3d.meshs.Meshs;
	import gl3d.shaders.particle.ParticleGLShader;
	import gl3d.util.Utils;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestParticle extends BaseExample
	{
		
		public function TestParticle() 
		{
			
		}
		
		override public function initNode():void 
		{
			var particle:Node3D = new Node3D;
			view.scene.addChild(particle);
			var bb:Drawable3D = Meshs.billboard();
			particle.drawable =Meshs.mul(bb,1000);
			
			particle.material = material;
			particle.material.textureSets[0] = new TextureSet(Utils.createBlurSphere());
			particle.material.setBlendModel(BlendMode.ADD);
			particle.material.passCompareMode = Context3DCompareMode.ALWAYS;
			particle.material.textureSets.length = 1;
			particle.material.shader = new ParticleGLShader;
		}
		
	}

}