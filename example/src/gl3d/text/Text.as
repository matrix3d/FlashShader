package gl3d.text 
{
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display3D.Context3DBufferUsage;
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
		private var pin:Vector.<Number> = new <Number>[0,0,0,1,0,0,0,1,0];
		private var pout:Vector.<Number> = new Vector.<Number>(9);
		private var _border:Boolean = false;
		private var _borderColor:uint = 0;
		public var charSet:CharSet;
		public function Text() 
		{
			charSet = new CharSet();
			material = new Material;
			material.vertexColorAble = true;
			material.lightAble = false;
			material.blendMode = BlendMode.LAYER;
			material.culling = Context3DTriangleFace.NONE;
			material.passCompareMode = Context3DCompareMode.ALWAYS;
		}
		
		override public function update(view:View3D, material:MaterialBase = null):void 
		{
			//添加新的字符串
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
			if (num==0){
				return;
			}
			//更新字符集
			charSet.update();
			
			//更新char相对位置
			for (i = 0; i < clen;i++ ){
				line = children[i] as TextLine;
				var cs:Array = line.chars;
				if (cs && cs.length){
					var tx:int = 0;
					var ty:int = 0;
					var tlen:int = cs.length;
					for (var j:int = 0; j < tlen; j++ ){
						var txt:Char = cs[j];
						var char:CharInstance = txt.instance;
						//tx为文字起始点 ts为文字末尾点
						if (line.wordWrap){
							if (line.autoSize==TextFieldAutoSize.NONE){
								// todo :
							}else{
								// todo :
							}
							if ((tx+char.width)>line.width){
								//break;
								tx = 0;
								ty += char.height;
							}
						}else{
							if (line.autoSize==TextFieldAutoSize.LEFT){
								
							}else if (line.autoSize==TextFieldAutoSize.RIGHT){
								// todo :
							}else if (line.autoSize==TextFieldAutoSize.CENTER){
								// todo :
							}else{
								if ((tx+char.width)>line.width){
									break;
								}
							}
						}
						
						txt.x0 = tx;
						txt.x1 = tx+char.width;
						txt.y0 = ty - char.ascent;
						txt.y1 = txt.y0 + char.height;
						tx += char.xadvance;	
					}
				}
			}
			
			//新建vertex index
			var pow2num:int = MathUtil.getNextPow2(num);
			var da:Drawable = drawablePool[pow2num];
			if (da==null){
				da = drawablePool[pow2num] = new Drawable;
				da.index = new IndexBufferSet(new Vector.<uint>(pow2num*6),"dynamicDraw");
				da.pos = new VertexBufferSet(new Vector.<Number>(pow2num * 4 * 3), 3,"dynamicDraw");
				da.uv = new VertexBufferSet(new Vector.<Number>(pow2num * 4 * 2), 2,"dynamicDraw");
				da.color = new VertexBufferSet(new Vector.<Number>(pow2num * 4 * 4), 4,"dynamicDraw");
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
			//更新vertex index
			da.pos.dataInvalid = true;
			da.uv.dataInvalid = true;
			da.color.dataInvalid = true;
			var posd:Vector.<Number> = da.pos.data;
			var uvd:Vector.<Number> = da.uv.data;
			var colord:Vector.<Number> = da.color.data;
			var k:int = 0;
			for (i = 0; i < clen;i++ ){
				line = children[i] as TextLine;
				cs = line.chars;
				if (cs && cs.length){
					//pin为三个点 (原点坐标,单位x坐标,单位y坐标)
					//转换到pout 然后原点坐标 减去单位坐标 得到单位x ,单位y
					line.matrix.transformVectors(pin, pout);
					pout[3] -= pout[0];
					pout[4] -= pout[1];
					pout[5] -= pout[2];
					pout[6] -= pout[0];
					pout[7] -= pout[1];
					pout[8] -= pout[2];
					tlen = cs.length;
					for (j = 0; j < tlen; j++ ){
						txt = cs[j];
						char = txt.instance;
						
						
						posd[k * 12] = pout[0] + txt.x0 *pout[3]+txt.y0 * pout[6];
						posd[k * 12 + 1] = pout[1] +txt.x0* pout[4]+txt.y0 * pout[7];
						posd[k * 12 + 2] = pout[2] + txt.x0 * pout[5]+txt.y0 * pout[8];
						
						posd[k * 12 + 3] = pout[0] + txt.x1 * pout[3]+txt.y0 * pout[6];
						posd[k * 12 + 4] = pout[1] + txt.x1 * pout[4]+txt.y0 * pout[7];
						posd[k * 12 + 5] = pout[2] + txt.x1 * pout[5]+txt.y0 * pout[8];
						
						posd[k * 12 + 6] = pout[0]  + txt.x1 * pout[3]+txt.y1 * pout[6];
						posd[k * 12 + 7] = pout[1] + txt.x1 * pout[4]+txt.y1 * pout[7];
						posd[k * 12 + 8] = pout[2] + txt.x1 * pout[5]+txt.y1 * pout[8];
						
						posd[k * 12 + 9] = pout[0] + txt.x0 * pout[3]+txt.y1 * pout[6];
						posd[k * 12 + 10] = pout[1] + txt.x0 * pout[4]+txt.y1 * pout[7];
						posd[k * 12 + 11] = pout[2] + txt.x0 * pout[5]+txt.y1 * pout[8];
						
						uvd[k * 8] = uvd[k * 8 + 6] = char.u0;
						uvd[k * 8 + 1] = uvd[k * 8 + 3] = char.v0;
						uvd[k * 8 + 2] = uvd[k * 8 + 4] = char.u1;
						uvd[k * 8 + 5] = uvd[k * 8 + 7] = char.v1;
						
						colord[k * 16] = colord[k * 16 + 4] = colord[k * 16 + 8] = colord[k * 16 + 12] = txt.r;
						colord[k * 16 + 1] = colord[k * 16 + 5] = colord[k * 16 + 9] = colord[k * 16 + 13] = txt.g;
						colord[k * 16 + 2] = colord[k * 16 + 6] = colord[k * 16 + 10] = colord[k * 16 + 14] = txt.b;
						colord[k * 16 + 3] = colord[k * 16 + 7] = colord[k * 16 + 11] = colord[k * 16 + 15] = 1;
						
						k++;
					}
				}
			}
			drawable = da;
			drawable.index.numTriangles = num * 2;
			//绘制
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