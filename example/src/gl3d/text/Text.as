package gl3d.text 
{
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DTriangleFace;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextLineMetrics;
	import gl3d.core.Drawable;
	import gl3d.core.DrawableSource;
	import gl3d.core.IndexBufferSet;
	import gl3d.core.Material;
	import gl3d.core.MaterialBase;
	import gl3d.core.Node3D;
	import gl3d.core.TextureSet;
	import gl3d.core.VertexBufferSet;
	import gl3d.core.View3D;
	import gl3d.meshs.Meshs;
	import gl3d.util.MathUtil;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Text extends Node3D
	{
		private var drawablePool:Object = {};
		private var size:int;
		private var pin:Vector.<Number> = new <Number>[0,0,0,1,0,0,0,1,0];
		private var pout:Vector.<Number> = new Vector.<Number>(9);
		private var _border:Boolean = false;
		private var _borderColor:uint = 0;
		public var charSet:CharSet;
		public function Text(font:String=null,fontSize:int=12) 
		{
			charSet = new CharSet(font, fontSize);
			size = charSet.size;
			pin[7] = size;
			material = new Material;
			material.lightAble = false;
			material.blendModel = BlendMode.LAYER;
			material.culling = Context3DTriangleFace.NONE;
			material.passCompareMode = Context3DCompareMode.ALWAYS;
		}
		
		override public function update(view:View3D, material:MaterialBase = null):void 
		{
			var num:int = 0;
			var charCount:int = 0;
			var clen:int = children.length;
			for (i = 0; i < clen;i++ ){
				var line:TextLine = children[i] as TextLine;
				if (line&&line.chars){
					num += line.chars.length;
					if (line.textDirty){
						line.textDirty = false;
						charSet.add(line.chars);
					}
				}
			}
			charSet.update();
			var pow2num:int = MathUtil.getNextPow2(num);
			var da:Drawable = drawablePool[pow2num];
			if (da==null){
				da = drawablePool[pow2num] = new Drawable;
				da.index = new IndexBufferSet(new Vector.<uint>(pow2num*6));
				da.pos = new VertexBufferSet(new Vector.<Number>(pow2num * 4 * 3), 3);
				da.uv = new VertexBufferSet(new Vector.<Number>(pow2num * 4 * 2), 2);
				var indexd:Vector.<uint> = da.index.data;
				for (var i:int = 0; i < pow2num;i++ ){
					indexd[i * 6] = i * 4;
					indexd[i * 6+1] = i * 4+2;
					indexd[i * 6+2] = i * 4+1;
					indexd[i * 6+3] = i * 4;
					indexd[i * 6+4] = i * 4+3;
					indexd[i * 6 + 5] = i * 4 + 2;
				}
			}
			this.material.diffTexture = charSet.tset;
			//update
			da.pos.dataInvalid = true;
			da.uv.dataInvalid = true;
			var posd:Vector.<Number> = da.pos.data;
			var uvd:Vector.<Number> = da.uv.data;
			var k:int = 0;
			var chars:Object = charSet.chars;
			for (i = 0; i < clen;i++ ){
				line = children[i] as TextLine;
				var cs:Array = line.chars;
				if (cs&&cs.length){
					line.matrix.transformVectors(pin, pout);
					pout[3] -= pout[0];
					pout[4] -= pout[1];
					pout[5] -= pout[2];
					var tx:int = 0;
					var tlen:int = cs.length;
					for (var j:int = 0; j < tlen; j++ ){
						var txt:String = cs[j];
						var char:Char = chars[txt];
						
						var b:TextLineMetrics = char.linem;
						//var cix:int = char.tx;
						//var ciy:int = char.ty;
						var ts:int = tx + b.width;
						
						posd[k * 12] = pout[0] + tx * pout[3];
						posd[k * 12 + 1] = pout[1] +tx* pout[4];
						posd[k * 12 + 2] = pout[2] + tx * pout[5];
						
						posd[k * 12 + 3] = pout[0] + ts * pout[3];
						posd[k * 12 + 4] = pout[1] + ts * pout[4];
						posd[k * 12 + 5] = pout[2] + ts * pout[5];
						
						posd[k * 12 + 6] = pout[6] + ts * pout[3];
						posd[k * 12 + 7] = pout[7] + ts * pout[4];
						posd[k * 12 + 8] = pout[8] + ts * pout[5];
						
						posd[k * 12 + 9] = pout[6] + tx * pout[3];
						posd[k * 12 + 10] = pout[7] + tx * pout[4];
						posd[k * 12 + 11] = pout[8] + tx * pout[5];
						
						uvd[k * 8] = uvd[k * 8 + 6] = char.u0;
						uvd[k * 8 + 1] = uvd[k * 8 + 3] = char.v0;
						uvd[k * 8 + 2] = uvd[k * 8 + 4] = char.u1;
						uvd[k * 8 + 5] = uvd[k * 8 + 7] = char.v1;
						
						tx = ts;
						k++;
					}
				}
			}
			drawable = da;
			drawable.index.numTriangles = num*2;
			super.update(view, material);
		}
		
		public function get border():Boolean 
		{
			return _border;
		}
		
		public function set border(value:Boolean):void 
		{
			_border = value;
			material.border = value;
		}
		
		public function get borderColor():uint 
		{
			return _borderColor;
		}
		
		public function set borderColor(value:uint):void 
		{
			_borderColor = value;
		}
	}

}