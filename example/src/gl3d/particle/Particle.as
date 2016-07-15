package gl3d.particle 
{
	import flash.display.BlendMode;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DTriangleFace;
	import flash.geom.Vector3D;
	import gl3d.core.Drawable;
	import gl3d.core.Material;
	import gl3d.core.MaterialBase;
	import gl3d.core.Node3D;
	import gl3d.core.TextureSet;
	import gl3d.core.View3D;
	import gl3d.meshs.Meshs;
	import gl3d.meshs.Teapot;
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
		public var isStretchedBillboard:Boolean = false;//拉伸广告板
		public var stretchedLength:Number = 10;//拉伸长度
		public var isVertexColor:Boolean = false;//顶点色
		
		public var count:int = 10000;
		public var timeLife:ParticleValue=new ParticleValue([1000],[2000]);
		public var isAddRandomLifeTime:Boolean = true;//是否增加随机生命周期
		
		public var loop:Number = 0;
		public var shapeID:int = 2;
		
		public var pos:ParticleValue = new ParticleValue([-20,-20,-20],[20,20,20]);;
		public var scale:ParticleValue=new ParticleValue([0],[1]);
		public var velocity:ParticleValue=new ParticleValue([0],[0]);
		public var rotation:ParticleValue;
		public var uv:ParticleValue;
		public var color:ParticleValue=new ParticleValue([1,0,0,1],[0,1,0,1]);
		public function Particle() 
		{
		}
		
		override public function update(view:View3D,material:MaterialBase=null):void 
		{
			if (invalid) {
				if(isBillboard){
					var bb:Drawable = Meshs.billboard();
					drawable = Meshs.mul(bb, count);
				}else {
					if (shapeID==0) {
						var shape:Drawable = Meshs.cube();
					}else if (shapeID==1) {
						shape = Teapot.teapot(2);
					}else if (shapeID==2) {
						shape = Meshs.plane(.1);
					}else {
						shape = Meshs.sphere(10, 10);
					}
					drawable = Meshs.mul(shape, count);
					drawable.randomStep = shape.pos.data.length / 3;
				}
				this.material = new Material;
				this.material.blendModel = BlendMode.ADD;
				this.material.culling = Context3DTriangleFace.NONE;
				this.material.depthMask = false;
				(this.material as Material).shader = new ParticleGLShader;
				invalid = false;
			}
			super.update(view);
		}
		
	}

}