package gl3d 
{
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TextureSet 
	{
		private var invalid:Boolean = true;
		private var data:BitmapData;
		public var texture:Texture;
		public function TextureSet(data:BitmapData=null) 
		{
			this.data = data;
			
		}
		
		public function update(context:Context3D):void {
			if (invalid) {
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
						texture.uploadFromBitmapData(tmp, level);
						
						transform.scale(.5, .5);
						level++;
						size >>= 1;
						if (tmp.transparent)
							tmp.fillRect(tmp.rect, 0);
					}
					tmp.dispose();
				}else {
					texture = context.createTexture(1024, 1024, Context3DTextureFormat.BGRA, true);
				}
				invalid = false;
			}
		}
		
		public function bind(context:Context3D, i:int):void {
			context.setTextureAt(i, texture);
		}
		
	}

}