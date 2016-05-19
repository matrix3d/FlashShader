package gl3d.core {
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.CubeTexture;
	import flash.display3D.textures.RectangleTexture;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import gl3d.core.renders.GL;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TextureSet 
	{
		public var name:String;
		public var invalid:Boolean = true;
		public var data:Object;
		public var texture:TextureBase;
		private var context:GL;
		public var isRect:Boolean;
		public var isCube:Boolean=false;
		private var optimizeForRenderToTexture:Boolean;
		public var mipmap:Boolean;
		private var async:Boolean;
		private var filter:String;
		private var repeat:Boolean;
		public var width:int;
		public var height:int;
		public var ready:Boolean = true;
		public var isDXT1:Boolean;
		public var isDXT5:Boolean;
		public function TextureSet(data:Object = null, isRect:Boolean = false,repeat:Boolean=true, optimizeForRenderToTexture:Boolean = false, mipmap:Boolean = true, async:Boolean = true, filter:String="anisotropic16x") 
		{
			this.repeat = repeat;
			this.filter = filter;
			this.async = async;
			this.mipmap = mipmap;
			this.optimizeForRenderToTexture = optimizeForRenderToTexture;
			this.isCube = data is Array;
			this.isRect = isRect;
			this.data = data;
			updateATF(null, false);
			if (data is String) {
				ready = false;
			}
		}
		
		private function getNextPow2(v:int):int {
			var r:int = 1;
			while (r < v) {
				r *= 2;
			}
			return r;
		}
		
		public function updateRect(context:GL):void {
			var bmd:BitmapData = data as BitmapData;
			if (bmd) {
				texture = context.createRectangleTexture(bmd.width, bmd.height , Context3DTextureFormat.BGRA, optimizeForRenderToTexture);
				uploadFromBitmapData(texture, bmd, 0);
			}
		}
		
		public function updateBMDTexture(w:int, h:int, bmd:BitmapData, texture:TextureBase, side:uint = 0):void {
			width = w;
			height = h;
			var temp:BitmapData;
			var level:int = 0;
			if (w!=bmd.width||h!=bmd.height) {
				var bak:BitmapData = bmd;
				bmd = new BitmapData(w, h, bak.transparent, 0);
				bmd.draw(bak, new Matrix(w / bak.width, 0, 0, h / bak.height), null, null, null,true);
			}
			while (w > 0||h>0) {
				if (level == 0) {
					uploadFromBitmapData(texture, bmd, side, level);
					
					if (!mipmap) {
						break;
					}
				}else {
					temp = new BitmapData(Math.max(w,1), Math.max(h,1), bmd.transparent, 0);
					temp.draw(bmd, new Matrix(temp.width / bmd.width, 0, 0, temp.height / bmd.height));
					uploadFromBitmapData(texture, temp, side, level);
					temp.dispose();
				}
				level++;
				w /= 2;
				h /= 2;
			}
		}
		
		private function uploadFromBitmapData (texture:TextureBase, source:BitmapData, side:uint, miplevel:uint = 0) : void {
			var byte:ByteArray = new ByteArray;
			byte.endian = Endian.LITTLE_ENDIAN;
			source.copyPixelsToByteArray(source.rect, byte);
			if (texture is Texture) {
				(texture as Texture).uploadFromByteArray(byte, 0, miplevel);
				//(texture as Texture).uploadFromBitmapData(source, miplevel);
			}else if (texture is CubeTexture) {
				(texture as CubeTexture).uploadFromByteArray(byte,0, side, miplevel);
				//(texture as CubeTexture).uploadFromBitmapData(source, side, miplevel);
			}else if (texture is RectangleTexture) {
				(texture as RectangleTexture).uploadFromByteArray(byte, 0);
			}
		}
		
		public function updateBMD(context:GL):void {
			var bmd:BitmapData = data as BitmapData;
			if (data) {
				var w:int = getNextPow2(bmd.width);
				var h:int = getNextPow2(bmd.height);
				texture =context.createTexture(w, h, Context3DTextureFormat.BGRA,optimizeForRenderToTexture);
				updateBMDTexture(w,h,bmd,texture);
			}
		}
		
		public function updateBMDs(context:GL):void {
			var datas:Array = data as Array;
			if (datas) {
				
				var ct:CubeTexture = texture as CubeTexture;
				for (var s:int = 0; s < 6;s++ ) {
					var level:int = 0;
					var bmd:BitmapData = datas[s];
					var w:int = getNextPow2(Math.max(bmd.width,bmd.height));
					if(texture==null)texture = context.createCubeTexture(w, Context3DTextureFormat.BGRA, optimizeForRenderToTexture);
					updateBMDTexture(w, w, bmd, texture, s);
				}
			}
		}
		
		public function updateATF(context:GL,createTexture:Boolean=true):void {
			var atf:ByteArray = data as ByteArray;
			if (atf) {
				atf.position = 0;
				var sign:String = atf.readUTFBytes(3);
				if (sign != "ATF")
					throw "ATF parsing error, unknown format " + sign;
				
				if (atf[6] == 255)
					atf.position = 12; // new file version
				else
					atf.position = 6; // old file version
				
				var tdata:uint = atf.readUnsignedByte();
				var _type:int = tdata >> 7; // UB[1]
				var _format:int = tdata & 0x7f; // UB[7]
				var format:String=null;
				switch (_format) {
					case 0:
					case 1:
						format = Context3DTextureFormat.BGRA;
						break;
					case 2:
					case 3:
					case 12:
						format = Context3DTextureFormat.COMPRESSED;
						isDXT1 = true;
						break;
					case 4:
					case 5:
					case 13:
						format = Context3DTextureFormat.COMPRESSED_ALPHA;
						isDXT5 = true;
						break;
						// explicit string to stay compatible 
					// with older versions
					default:
						throw "Invalid ATF format";
				}
				
				switch (_type) {
					case 0:
						isCube = false;
						break;
					case 1:
						isCube = true;
				}
				width = int(Math.pow(2, data.readUnsignedByte()));
				height = int(Math.pow(2, data.readUnsignedByte()));
				var numTextures:int = data.readUnsignedByte();
				//mipmap = numTextures > 1;
				
				if(createTexture){
					texture = isCube?context.createCubeTexture(width,format,optimizeForRenderToTexture,0):context.createTexture(width, height, format, optimizeForRenderToTexture,0);
					if (isCube)
					(texture as CubeTexture).uploadCompressedTextureFromByteArray(atf, 0, async);
					else
					(texture as Texture).uploadCompressedTextureFromByteArray(atf, 0, async);
					
					ready = !async;
					if(async)
					(texture as Texture).addEventListener(Event.TEXTURE_READY, function():void { ready = true } );
				}
			}
		}
		
		public function update(view:View3D):void {
			var context:GL = view.renderer.gl3d;
			if (invalid||this.context!=context) {
				if (texture != null) texture.dispose();
				if (isRect) {
					updateRect(context);
				}else if (data is Array) {
					updateBMDs(context);
				}else if (data is BitmapData) {
					//data = new BitmapData(1, 1, true, 0x80ffffff);
					updateBMD(context);
				}else if (data is ByteArray) {
					updateATF(context);
				}else {
					//trace(this,"error")
				}
				invalid = false;
				this.context = context;
			}
		}
		
		public function bind(context:GL, i:int):void {
			context.setTextureAt(i, texture);
		}
		
		public function get flags():Array {
			var arr:Array = [];
			if (mipmap) arr.push("miplinear");
			if (isCube) {
				arr.push("cube");
			}
			if(repeat&&!isCube&&!isRect){
				arr.push("repeat");
			}
			if (isDXT1) {
				arr.push("dxt1");
			}else if (isDXT5) {
				arr.push("dxt5");
			}
			if(filter){
				arr.push(filter);
			}
			return arr;
		}
		
	}

}