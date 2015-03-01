package gl3d.core {
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Matrix;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TextureSet 
	{
		public var invalid:Boolean = true;
		private var data:BitmapData;
		public var texture:TextureBase;
		private var context:GL;
		
		public var needWidth:int;
		public var needHeight:int;
		public var needFormat:String=Context3DTextureFormat.BGRA;
		public function TextureSet(data:BitmapData=null) 
		{
			this.data = data;
			
		}
		
		public function update(view:View3D):void {
			var context:GL = view.gl3d;
			if (invalid||this.context!=context) {
				if (texture != null) texture.dispose();
				if(data){
					var w:int = 2048;
					var h:int = 2048;
					var bmd:BitmapData = data;
					for (var i:int = 0; i < 12;i++) {
						var pow:int = Math.pow(2, i);
						if (pow>=bmd.width) {
							w = pow;
							break;
						}
					}
					for (i = 0; i < 12;i++) {
						pow = Math.pow(2, i);
						if (pow>=bmd.height) {
							h = pow;
							break;
						}
					}
					
					texture =context.createTexture(w, h, Context3DTextureFormat.BGRA,false);
					
					var level 		: int 			= 0;
					var size		: int 			= w > h ? w : h;
					var _bitmapData:BitmapData = new BitmapData(size, size, bmd.transparent, 0);
					_bitmapData.draw(bmd , new Matrix(size / bmd.width, 0, 0, size / bmd.height), null, null, null, true);
					var transform 	: Matrix 		= new Matrix();
					var tmp 		: BitmapData 	= new BitmapData(
						size,
						size,
						bmd.transparent,
						0
					);
					
					while (size >= 1)
					{
						tmp.draw(_bitmapData, transform, null, null, null, true);
						(texture as Texture).uploadFromBitmapData(tmp, level);
						
						transform.scale(.5, .5);
						level++;
						size >>= 1;
						if (tmp.transparent)
							tmp.fillRect(tmp.rect, 0);
					}
					tmp.dispose();
				}else {
					//texture = context.createTexture(1024, 1024, Context3DTextureFormat.BGRA, true);// .createTexture(1024, 1024, Context3DTextureFormat.BGRA, true);
					texture = context.createRectangleTexture(needWidth==0?view.stage3dWidth:needWidth,needHeight==0?view.stage3dHeight:needHeight , Context3DTextureFormat.BGRA, true);
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