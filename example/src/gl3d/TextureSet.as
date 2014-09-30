package gl3d 
{
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TextureSet 
	{
		private var invalid:Boolean = true;
		private var data:BitmapData;
		private var texture:Texture;
		public function TextureSet(data:BitmapData) 
		{
			this.data = data;
			
		}
		
		public function update(context:Context3D):void {
			if (invalid) {
				texture = context.createTexture(data.width, data.height, Context3DTextureFormat.BGRA, false);
				texture.uploadFromBitmapData(data);
				invalid = true;
			}
		}
		
		public function bind(context:Context3D, i:int):void {
			context.setTextureAt(i, texture);
		}
		
	}

}