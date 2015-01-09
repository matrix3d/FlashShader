package gl3d.particle 
{
	import flash.display.BlendMode;
	import flash.display3D.Context3DCompareMode;
	import flash.geom.Vector3D;
	import gl3d.core.Drawable3D;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.core.TextureSet;
	import gl3d.core.View3D;
	import gl3d.meshs.Meshs;
	import gl3d.shaders.particle.ParticleGLShader;
	import gl3d.util.Utils;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Particle extends Node3D
	{
		public var invalid:Boolean = true;
		public var isBillboard:Boolean = true;
		public var shapeID:int = 0;
		public var timeLifeMin:Number = 1000;
		public var timeLifeMax:Number = 2000;
		public var velocityMin:Number = 1;
		public var velocityMax:Number = 2;
		public var scaleMin:Number = 1;
		public var scaleMax:Number = 2;
		public var rotation:Number = 0;
		public var uv:Vector3D;
		public var colorMin:Vector3D;
		public var colorMax:Vector3D;
		public function Particle() 
		{
			
		}
		
		override public function update(view:View3D):void 
		{
			if (invalid) {
				if(isBillboard){
					var bb:Drawable3D = Meshs.billboard();
					drawable = Meshs.mul(bb, 1000);
				}
				material = new Material;
				material.textureSets[0] = new TextureSet(Utils.createBlurSphere());
				material.blendModel = BlendMode.ADD;
				material.passCompareMode = Context3DCompareMode.ALWAYS;
				material.shader = new ParticleGLShader;
				
				invalid = false;
			}
			super.update(view);
		}
		
	}

}