package gl3d.core 
{
	import flash.display.BlendMode;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DFillMode;
	import flash.display3D.Context3DTriangleFace;
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class MaterialBase 
	{
		public var castShadow:Boolean = true;
		public var gpuSkin:Boolean = false;
		public var lightAble:Boolean = true;
		public var vertexColorAble:Boolean = false;
		public var fogAble:Boolean = true;
		private var _writeDepth:Boolean = false;
		public var ambientAble:Boolean = true;
		public var specularAble:Boolean = true;
		public var ambient:Vector3D =new Vector3D(0, 0, 0, 0);
		public var specularPower:Number = 50;
		private var _toonAble:Boolean = false;
		public var toonStep:Number = 2;
		public var receiveShadows:Boolean = true;
		public var alphaThreshold:Number = 0;
		public var blurSize:int = 0;
		
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
		public var gray:Boolean = false;
		public var uvMuler:Array;
		public var uvAdder:Array;
		private var _wireframeAble:Boolean = false;
		public var isDistanceField:Boolean = false;
		public var wireframeColor:Vector3D =new Vector3D(.5, 0, .5, 0);
		public var terrainScale:Vector3D =new Vector3D(10,10,10,10);
		public var invalid:Boolean = true;
		private var _normalMapAble:Boolean;
		
		public var sourceFactor:String = Context3DBlendFactor.ONE; 
		public var destinationFactor:String = Context3DBlendFactor.ZERO;
		public var passCompareMode:String = Context3DCompareMode.LESS;
		public var culling:String = Context3DTriangleFace.FRONT;
		public var depthMask:Boolean = true;
		public var border:Boolean = false;
		public var borderColor:Vector3D = new Vector3D(1, 0, 0, 1);
		public var isBillbard:Boolean = false;
		public var fillMode:String = "solid";//Context3DFillMode.SOLID;
		//public var isStretched:Boolean = false;//基于速度缩放
		public function MaterialBase() 
		{
			
		}
		
		public function draw(node:Node3D,view:View3D):void {
			
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
		
		public function set blendMode(value:String):void {
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