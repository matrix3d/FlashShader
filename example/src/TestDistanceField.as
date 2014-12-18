package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import gl3d.core.Node3D;
	import gl3d.core.TextureSet;
	import gl3d.meshs.Meshs;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestDistanceField extends BaseExample
	{
		
		public function TestDistanceField() 
		{
			
		}
		
		override public function initNode():void 
		{
			var node:Node3D = new Node3D;
			[Embed(source = "assets/comic_source.png")]
			var c:Class;
			var bmd:BitmapData = (new c as Bitmap).bitmapData;
			material.textureSets[0] = new TextureSet(bmd);
			material.isDistanceField = true;
			node.material = material;
			node.drawable = Meshs.cube(30,30,0)
			view.scene.addChild(node);
			
		}
		
		override public function initUI():void 
		{
		}
		
	}

}