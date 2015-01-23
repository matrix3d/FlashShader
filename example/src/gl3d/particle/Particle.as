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
		public var isBillboard:Boolean = false;
		public var count:int = 16;
		public var shapeID:int = 3;
		public var randomTimeLife:Boolean = true;
		public var timeLifeMin:Number = 10000;
		public var timeLifeMax:Number = 10000;
		public var scaleMin:Number = 0.2;
		public var scaleMax:Number = 0.2;
		public var posScaleMin:Number = 3;
		public var posScaleMax:Number = 3;
		public var rotation:Number = 0;
		public var uv:Vector3D = new Vector3D(10, 10,10,10);
		public var colorMin:Vector.<Number>=new <Number>[1,1,1,1];
		public var colorMax:Vector.<Number>=new <Number>[1,1,0,0];
		public function Particle() 
		{
			
		}
		
		override public function update(view:View3D):void 
		{
			if (invalid) {
				if(isBillboard){
					var bb:Drawable3D = Meshs.billboard();
					drawable = Meshs.mul(bb, count);
				}else {
					if (shapeID==0) {
						var shape:Drawable3D = Meshs.cube();
					}else if (shapeID==1) {
						shape = Meshs.teapot(2);
					}else if (shapeID==2) {
						shape = Meshs.plane();
					}else {
						shape = Meshs.sphere(10, 10);
					}
					drawable = Meshs.mul(shape, count);
					drawable.randomStep = shape.pos.data.length / 3;
				}
				material = new Material;
				material.color = new <Number>[1,0,0,0];
				material.diffTexture = new TextureSet(Utils.createBlurSphere());
				material.blendModel = BlendMode.ADD;
				material.passCompareMode = Context3DCompareMode.ALWAYS;
				material.shader = new ParticleGLShader;
				
				invalid = false;
			}
			super.update(view);
		}
		
	}

}