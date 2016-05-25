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
	public class Material 
	{
		public var gpuSkin:Boolean = false;
		
		public var lightAble:Boolean = true;
		public var fogAble:Boolean = true;
		private var _writeDepth:Boolean = false;
		private var lastNumLight:int = -1;
		public var ambientAble:Boolean = true;
		public var specularAble:Boolean = true;
		public var ambient:Vector3D =new Vector3D(.1, .1, .1, .1);
		public var specularPower:Number = 50;
		private var _toonAble:Boolean = false;
		public var toonStep:Number = 2;
		public var castShadow:Boolean = true;
		public var receiveShadows:Boolean = true;
		public var alphaThreshold:Number = 0;
		
		public var view:View3D;
		public var camera:Camera3D;
		public var materialCamera:Camera3D;
		public var node:Node3D;
		//
		public var diffTexture:TextureSet;
		public var normalmapTexture:TextureSet;
		public var lightmapTexture:TextureSet;
		public var reflectTexture:TextureSet;
		public var terrainTextureSets:Array = [];
		public var color:Vector3D = new Vector3D(1, 1, 1, 1);
		public var uvMuler:Array;
		public var uvAdder:Array;
		private var _wireframeAble:Boolean = false;
		public var isDistanceField:Boolean = false;
		public var wireframeColor:Vector3D =new Vector3D(.5, 0, .5, 0);
		public var invalid:Boolean = true;
		private var _normalMapAble:Boolean;
		public var shader:GLShader;
		
		public var sourceFactor:String = Context3DBlendFactor.ONE; 
		public var destinationFactor:String = Context3DBlendFactor.ZERO;
		public var passCompareMode:String = Context3DCompareMode.LESS;
		public var culling:String = Context3DTriangleFace.FRONT;
		public var depthMask:Boolean = true;
		public var border:Boolean = false;
		public var borderColor:Vector3D = new Vector3D(1, 0, 0, 1);
		public function Material(shader:GLShader=null) 
		{
			this.shader = shader||new PhongGLShader();
		}
		
		public function draw(node:Node3D,view:View3D):void {
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
		
		public function get normalMapAble():Boolean 
		{
			return _normalMapAble;
		}
		
		public function set normalMapAble(value:Boolean):void 
		{
			_normalMapAble = value;
		}
		
		public function get wireframeAble():Boolean 
		{
			return _wireframeAble;
		}
		
		public function set wireframeAble(value:Boolean):void 
		{
			_wireframeAble = value;
			invalid = true;
		}
		
		public function set blendModel(value:String):void {
			switch (value) {
				case BlendMode.NORMAL:
					sourceFactor = Context3DBlendFactor.ONE;
					destinationFactor = Context3DBlendFactor.ZERO;
					break;
				case BlendMode.LAYER:
					sourceFactor = Context3DBlendFactor.SOURCE_ALPHA;
					destinationFactor = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
					break;
				case BlendMode.MULTIPLY:
					sourceFactor = Context3DBlendFactor.ZERO;
					destinationFactor = Context3DBlendFactor.SOURCE_COLOR;
					break;
				case BlendMode.ADD:
					sourceFactor = Context3DBlendFactor.SOURCE_ALPHA;
					destinationFactor = Context3DBlendFactor.ONE;
					break;
				case BlendMode.ALPHA:
					sourceFactor = Context3DBlendFactor.ZERO;
					destinationFactor = Context3DBlendFactor.SOURCE_ALPHA;
					break;
			}
		}
		
		public function get toonAble():Boolean 
		{
			return _toonAble;
		}
		
		public function set toonAble(value:Boolean):void 
		{
			_toonAble = value;
			invalid = true;
		}
		
		public function get alpha():Number 
		{
			return color.w;
		}
		
		public function set alpha(value:Number):void 
		{
			color.w=value;
		}
		
		public function get writeDepth():Boolean 
		{
			return _writeDepth;
		}
		
		public function set writeDepth(value:Boolean):void 
		{
			_writeDepth = value;
			if (value) {
				lightAble = false;
				fogAble = false;
			}
		}
	}
}

