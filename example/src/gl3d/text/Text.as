package gl3d.text 
{
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DTriangleFace;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import gl3d.core.Drawable;
	import gl3d.core.DrawableSource;
	import gl3d.core.IndexBufferSet;
	import gl3d.core.Material;
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
		private var texturePool:Object = {};
		public var font:String;
		private var size:int;
		public var chars:Object;
		public var charIndex:int = 0;
		private var tf:TextField = new TextField;
		private var helpMatr:Matrix = new Matrix;
		public var fontSize:int;
		private var pin:Vector.<Number> = new <Number>[0,0,0,1,0,0,0,1,0];
		private var pout:Vector.<Number> = new Vector.<Number>(9);
		public function Text(font:String=null,fontSize:int=12) 
		{
			this.fontSize = fontSize;
			this.font = font;
			tf.textColor = 0xffffff;
			tf.autoSize = TextFieldAutoSize.LEFT;
			var tfm:TextFormat = new TextFormat(font, fontSize);
			tf.defaultTextFormat = tfm;
			tf.text = "A";
			this.size = tf.height;
			trace(size);
			material = new Material;
			material.lightAble = false;
			material.blendModel = BlendMode.LAYER;
			material.culling = Context3DTriangleFace.NONE;
			material.passCompareMode = Context3DCompareMode.ALWAYS;
		}
		
		override public function update(view:View3D, material:Material = null):void 
		{
			var num:int = 0;
			var clen:int = children.length;
			for (i = 0; i < clen;i++ ){
				var line:TextLine = children[i] as TextLine;
				if (line&&line.text){
					num += line.text.length;
				}
			}
			var pow2num:int = MathUtil.getNextPow2(num);
			var da:Drawable = drawablePool[pow2num];
			if (da==null){
				da = drawablePool[pow2num] = new Drawable;
				da.index = new IndexBufferSet(new Vector.<uint>(pow2num*6));
				da.pos = new VertexBufferSet(new Vector.<Number>(pow2num * 4 * 3), 3);
				da.uv = new VertexBufferSet(new Vector.<Number>(pow2num * 4 * 2), 2);
				for (var i:int = 0; i < pow2num;i++ ){
					var indexd:Vector.<uint> = da.index.data;
					indexd[i * 6] = i * 4;
					indexd[i * 6+1] = i * 4+1;
					indexd[i * 6+2] = i * 4+2;
					indexd[i * 6+3] = i * 4;
					indexd[i * 6+4] = i * 4+2;
					indexd[i * 6 + 5] = i * 4 + 3;
				}
			}
			
			var sqrtPow2num:int = MathUtil.getNextSqrtPow2(num);
			var tsize:int = MathUtil.getNextPow2(sqrtPow2num * size);
			var tset:TextureSet = texturePool[tsize];
			if (tset==null){
				tset = texturePool[tsize] = new TextureSet(new BitmapData(tsize, tsize, true, 0),false,false,false,false,false,null);
				chars = {};
			}
			this.material.diffTexture = tset;
			var bmd:BitmapData = tset.data as BitmapData;
			
			//update
			da.pos.needUpload = true;
			da.uv.needUpload = true;
			var posd:Vector.<Number> = da.pos.data;
			var uvd:Vector.<Number> = da.uv.data;
			var k:int = 0;
			for (i = 0; i < clen;i++ ){
				line = children[i] as TextLine;
				var text:String = line.text;
				if (text && text.length){
					pin[7] = size;
					line.matrix.transformVectors(pin, pout);
					pout[3] -= pout[0];
					pout[4] -= pout[1];
					pout[5] -= pout[2];
					var tx:int = 0;
					var tlen:int = text.length;
					var cs:Array = line.chars;
					for (var j:int = 0; j < tlen; j++ ){
						var txt:String = cs[j];
						var char:Char = chars[txt];
						if (chars[txt] == null){
							char = new Char(txt);
							chars[txt] = char;
							tf.text = txt;
							char.tx = charIndex % sqrtPow2num;
							char.ty = int(charIndex / sqrtPow2num);
							helpMatr.tx = size * char.tx-1;
							helpMatr.ty = size * char.ty;
							bmd.draw(tf, helpMatr);
							char.index = charIndex;
							char.width = tf.textWidth;
							charIndex++;
							tset.needUpload = true;
						}
						var cix:int = char.tx;
						var ciy:int = char.ty;
						var cw:int = char.width;
						var ts:int = tx + cw;
						
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
						
						uvd[k * 8] = cix * size / tsize;
						uvd[k * 8 + 1] = ciy * size / tsize;
						uvd[k * 8 + 2] = (cix * size+cw) / tsize;
						uvd[k * 8 + 3] = ciy * size / tsize;
						uvd[k * 8 + 4] = (cix * size+cw) / tsize;
						uvd[k * 8 + 5] = (ciy + 1) * size / tsize;
						uvd[k * 8 + 6] = cix * size / tsize;
						uvd[k * 8 + 7] = (ciy + 1) * size / tsize;
						
						tx = ts;
						k++;
					}
				}
			}
			drawable = da;
			super.update(view, material);
		}
		
	}

}