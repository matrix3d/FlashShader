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
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextLineMetrics;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import gl3d.core.BytesVertexBufferSet;
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
		private var charVersion:int = 1;
		private var drawablePool:Object = {};
		private var pin:Vector.<Number> = new <Number>[0,0,0,1,0,0,0,1,0];
		private var pout:Vector.<Number> = new Vector.<Number>(9);
		private var _border:Boolean = false;
		private var _borderColor:uint = 0;
		public static var charSet:CharSet = new CharSet;
		private var lineInfos:Array = [];
		public function Text() 
		{
			material = new Material;
			material.vertexColorAble = true;
			material.lightAble = false;
			material.blendMode = BlendMode.LAYER;
			material.culling = Context3DTriangleFace.NONE;
			material.passCompareMode = Context3DCompareMode.ALWAYS;
		}
		
		override public function update(view:View3D, material:MaterialBase = null):void 
		{
			view.enableErrorChecking = true;
			//添加新的字符串
			var num:int = 0;
			var charCount:int = 0;
			var clen:int = children.length;
			var changed:Boolean = false;
			for (i = 0; i < clen;i++ ){
				var line:TextField = children[i] as TextField;
				if (line&&line.chars){
					num += line.charsLength;
					if (line.textDirty){
						line.textDirty = false;
						line.textMatrixDirty = true;
						charSet.add(line.chars,line.charsLength);
					}
					if (line.textMatrixDirty){
						changed = true;
					}
				}
			}
			if (num==0){
				return;
			}
			//更新字符集
			charSet.update();
			
			if (changed){
				var currentLineNum:int = -1;
				num = 0;
				charVersion++;
				//更新char相对位置
				for (i = 0; i < clen;i++ ){
					line = children[i] as TextField;
					line.textMatrixDirty = false;
					var startLineNum:int = currentLineNum+1;
					var cs:Array = line.chars;
					if (cs && line.charsLength){
						currentLineNum++;
						var lineInfo:LineInfo = lineInfos[currentLineNum] = lineInfos[currentLineNum] || new LineInfo;
						lineInfo.maxFontSize = 0;
						lineInfo.maxAscent = 0;
						var tx:int=2;
						var ty:int=2;
						var tlen:int = line.charsLength;
						for (var j:int = 0; j < tlen; j++ ){
							var txt:Char = cs[j];
							txt.lineInfo = lineInfo;
							var char:CharInstance = txt.instance;
							if (txt.txt == "\n"){
								tx = 2;
								ty += lineInfo.maxFontSize;
								currentLineNum++;
								lineInfo = lineInfos[currentLineNum] = lineInfos[currentLineNum] || new LineInfo;
								lineInfo.maxFontSize = 0;
								lineInfo.maxAscent = 0;
								lineInfo.width = 0;
								continue;
							}
							//tx为文字起始点 ts为文字末尾点
							if (line.wordWrap){
								if ((tx + char.width) > line.width){
									tx = 2;
									ty += lineInfo.maxFontSize;
									currentLineNum++;
									lineInfo = lineInfos[currentLineNum] = lineInfos[currentLineNum] || new LineInfo;
									lineInfo.maxFontSize = 0;
									lineInfo.maxAscent = 0;
									lineInfo.width = 0;
								}
								if (line.autoSize==TextFieldAutoSize.NONE){
									if (ty>line.height){
										break;
									}
									// todo :
								}
							}else{
								if(line.autoSize==TextFieldAutoSize.NONE){
									if ((tx+char.width)>line.width){
										break;
									}
								}
							}
							
							if (lineInfo.maxFontSize < txt.fontSize) {
								lineInfo.maxFontSize = txt.fontSize;
							}
							if (lineInfo.maxAscent<char.ascent){
								lineInfo.maxAscent = char.ascent;
							}
							
							txt.charVersion = charVersion;
							txt.lineInfo = lineInfo;
							txt.x0 = tx;
							lineInfo.width = txt.x1 = tx + char.width;
							txt.y0 = ty - char.ascent;
							txt.y1 = txt.y0 + char.height;
							tx += char.xadvance;
							num++;
						}
						for (var j = startLineNum; j <= currentLineNum;j++ ){
							lineInfo = lineInfos[j];
							if (line.autoSize==TextFieldAutoSize.CENTER){
								lineInfo.offsetX = line.width / 2 - lineInfo.width / 2;
							}else if (line.autoSize==TextFieldAutoSize.RIGHT){
								lineInfo.offsetX = line.width - lineInfo.width;
							}else{
								lineInfo.offsetX = 0;
							}
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
					da.uv = new VertexBufferSet(new Vector.<Number>(pow2num * 4 * 2), 2, "dynamicDraw");
					var colord:ByteArray = new ByteArray;
					colord.endian = Endian.LITTLE_ENDIAN;
					colord.length = pow2num * 4*4;
					da.color = new BytesVertexBufferSet(colord/*new Vector.<Number>(pow2num * 4)*/, 1,"dynamicDraw");
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
				colord = da.color.bytedata;
				var k:int = 0;
				for (i = 0; i < clen;i++ ){
					line = children[i] as TextField;
					cs = line.chars;
					if (cs && line.charsLength){
						//pin为三个点 (原点坐标,单位x坐标,单位y坐标)
						//转换到pout 然后原点坐标 减去单位坐标 得到单位x ,单位y
						line.matrix.transformVectors(pin, pout);
						pout[3] -= pout[0];
						pout[4] -= pout[1];
						pout[5] -= pout[2];
						pout[6] -= pout[0];
						pout[7] -= pout[1];
						pout[8] -= pout[2];
						tlen = line.charsLength;
						for (j = 0; j < tlen; j++ ){
							txt = cs[j];
							if (txt.charVersion != charVersion){
								continue;
							}
							char = txt.instance;
							var maxFontSize:int = txt.lineInfo.maxAscent;
							var offsetX:int = txt.lineInfo.offsetX;
							
							posd[k * 12] = pout[0] + (txt.x0 +offsetX)*pout[3]+(txt.y0+maxFontSize) * pout[6];
							posd[k * 12 + 1] = pout[1] +(txt.x0+offsetX)* pout[4]+(txt.y0+maxFontSize) * pout[7];
							posd[k * 12 + 2] = pout[2] + (txt.x0+offsetX) * pout[5]+(txt.y0+maxFontSize) * pout[8];
							
							posd[k * 12 + 3] = pout[0] + (txt.x1+offsetX) * pout[3]+(txt.y0+maxFontSize) * pout[6];
							posd[k * 12 + 4] = pout[1] + (txt.x1+offsetX) * pout[4]+(txt.y0+maxFontSize) * pout[7];
							posd[k * 12 + 5] = pout[2] + (txt.x1+offsetX) * pout[5]+(txt.y0+maxFontSize) * pout[8];
							
							posd[k * 12 + 6] = pout[0]  + (txt.x1+offsetX) * pout[3]+(txt.y1+maxFontSize) * pout[6];
							posd[k * 12 + 7] = pout[1] + (txt.x1+offsetX) * pout[4]+(txt.y1+maxFontSize) * pout[7];
							posd[k * 12 + 8] = pout[2] + (txt.x1+offsetX) * pout[5]+(txt.y1+maxFontSize) * pout[8];
							
							posd[k * 12 + 9] = pout[0] + (txt.x0+offsetX) * pout[3]+(txt.y1+maxFontSize) * pout[6];
							posd[k * 12 + 10] = pout[1] + (txt.x0+offsetX) * pout[4]+(txt.y1+maxFontSize) * pout[7];
							posd[k * 12 + 11] = pout[2] + (txt.x0+offsetX) * pout[5]+(txt.y1+maxFontSize) * pout[8];
							
							uvd[k * 8] = uvd[k * 8 + 6] = char.u0;
							uvd[k * 8 + 1] = uvd[k * 8 + 3] = char.v0;
							uvd[k * 8 + 2] = uvd[k * 8 + 4] = char.u1;
							uvd[k * 8 + 5] = uvd[k * 8 + 7] = char.v1;
							
							colord[k * 16] = colord[k * 16 + 4] = colord[k * 16 + 8] = colord[k * 16 + 12] = txt.r*0xff;
							colord[k * 16 + 1] = colord[k * 16 + 5] = colord[k * 16 + 9] = colord[k * 16 + 13] =txt.g*0xff;
							colord[k * 16 + 2] = colord[k * 16 + 6] = colord[k * 16 + 10] = colord[k * 16 + 14] =txt.b*0xff;
							colord[k * 16 + 3] = colord[k * 16 + 7] = colord[k * 16 + 11] = colord[k * 16 + 15] = 0xff;
							//colord[k * 4] = colord[k * 4 + 1] = colord[k * 4 + 2] = colord[k * 4 + 3] = 0xff//txt.r*0;
							//colord[k * 16 + 1] = colord[k * 16 + 5] = colord[k * 16 + 9] = colord[k * 16 + 13] =0xffffffff// txt.g*0;
							//colord[k * 16 + 2] = colord[k * 16 + 6] = colord[k * 16 + 10] = colord[k * 16 + 14] =0xffffffff// txt.b*0;
							//colord[k * 16 + 3] = colord[k * 16 + 7] = colord[k * 16 + 11] = colord[k * 16 + 15] = 0xffffffff//0xff
							
							k++;
						}
					}
				}
				drawable = da;
				drawable.index.numTriangles = num * 2;
			}
			//绘制
			super.update(view, material);
		}
	}

}