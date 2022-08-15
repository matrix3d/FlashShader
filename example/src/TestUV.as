package 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import gl3d.core.Drawable;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.core.TextureSet;
	import gl3d.meshs.Meshs;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestUV extends BaseExample
	{
		
		public function TestUV() 
		{
			
		}
		
		override public function initNode():void 
		{
			var node:Node3D = new Node3D;
			node.material = new Material;
			[Embed(source = "assets/comic_source.png")]var c:Class;
			var b:BitmapData = (new c as Bitmap).bitmapData;
			node.drawable = plane();
			view.scene.addChild(node);
			node.material.diffTexture = new TextureSet(b);
		}
		
		public static function plane(r:Number=1):Drawable
		{
			var vs:Vector.<Number> = Vector.<Number>([
			-r, -r, 0,
			r, -r, 0,
			-r, r, 0,
			r, r, 0]);
			var uv:Vector.<Number> = Vector.<Number>([
				1/16, 2/16, //x,y
				2/16, 2/16, 
				1/16, 1/16, 
				2 / 16, 1 / 16
				]);
			var ins:Vector.<uint> = Vector.<uint>([
			0, 1, 2, 
			1, 3, 2]);
			return Meshs.createDrawable(ins, vs, uv, null);
		}
		
	}

}