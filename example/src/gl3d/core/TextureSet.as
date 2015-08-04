package gl3d.core {
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.CubeTexture;
	import flash.display3D.textures.RectangleTexture;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Matrix;
	import gl3d.core.renders.GL;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TextureSet 
	{
		public var invalid:Boolean = true;
		public var data:BitmapData;
		public var datas:Vector.<BitmapData>;
		public var texture:TextureBase;
		private var context:GL;
		private var isRect:Boolean;
		private var isCube:Boolean;
		private var format:String;
		private var optimizeForRenderToTexture:Boolean;
		private var mipmap:Boolean;
		
		/*public var needWidth:int;
		public var needHeight:int;*/
		public var needFormat:String=Context3DTextureFormat.BGRA;
		public function TextureSet(data:BitmapData=null,isRect:Boolean=false,isCube:Boolean=false, optimizeForRenderToTexture:Boolean=false,mipmap:Boolean=true) 
		{
			this.mipmap = mipmap;
			this.optimizeForRenderToTexture = optimizeForRenderToTexture;
			this.format = format;
			this.isCube = isCube;
			this.isRect = isRect;
			this.data = data;
		}
		
		
		private function getNextPow2(v:int):int {
			var r:int = 1;
			while (r < v) {
				r *= 2;
			}
			return r;
		}
		
		public function update(view:View3D):void {
			var context:GL = view.renderer.gl3d;
			if (invalid||this.context!=context) {
				if (texture != null) texture.dispose();
				if (isRect) {
					if (data) {
						texture = context.createRectangleTexture(data.width, data.height , Context3DTextureFormat.BGRA, optimizeForRenderToTexture);
						(texture as RectangleTexture).uploadFromBitmapData(data);
					}
				}else if (isCube) {
					if (datas) {
						texture = context.createCubeTexture(datas[0].width, Context3DTextureFormat.BGRA, optimizeForRenderToTexture);
						var ct:CubeTexture = texture as CubeTexture;
						for (var s:int = 0; s < 6;s++ ) {
							var level:int = 0;
							var bmd:BitmapData = datas[s];
							var size:int = bmd.width;
							var temp:BitmapData;
							while (size > 0) {
								if (level == 0) {
									ct.uploadFromBitmapData(bmd, s, level);
								}else {
									if (temp==null) {
										temp = new BitmapData(size, size, bmd.transparent, 0);
									}
									if (temp.transparent) {
										temp.fillRect(temp.rect, 0);
									}
									temp.draw(bmd, new Matrix(size / bmd.width, 0, 0, size / bmd.height));
									ct.uploadFromBitmapData(bmd, s, level);
								}
								level++;
								size /= 2;
							}
						}
						if(temp){
							temp.dispose();
						}
					}
				}else {
					if (data) {
						var w:int = getNextPow2(data.width);
						var h:int = getNextPow2(data.height);
						if (w!=data.width||h!=data.height) {
							var bak:BitmapData = data;
							data = new BitmapData(w, h, bak.transparent, 0);
							data.draw(bak, new Matrix(w / bak.width, 0, 0, h / bak.height), null, null, null,true);
						}
						texture =context.createTexture(w, h, Context3DTextureFormat.BGRA,optimizeForRenderToTexture);
						
						level = 0;
						while (w > 0&&h>0) {
							if (level == 0) {
								(texture as Texture).uploadFromBitmapData(data, level);
							}else {
								if (temp==null) {
									temp = new BitmapData(w, h, data.transparent, 0);
								}
								if (temp.transparent) {
									temp.fillRect(temp.rect, 0);
								}
								temp.draw(data, new Matrix(w / data.width, 0, 0, h / data.height));
								(texture as Texture).uploadFromBitmapData(temp, level);
							}
							level++;
							w /= 2;
							h /= 2;
						}
						if(temp){
							temp.dispose();
						}
					}
				}
				
				invalid = false;
				this.context = context;
			}
		}
		
		public function bind(context:GL, i:int):void {
			context.setTextureAt(i, texture);
		}
		
	}

}