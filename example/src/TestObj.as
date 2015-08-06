package 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.events.Event;
	import flash.geom.Point;
	import gl3d.core.Fog;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.core.renders.GraphicsRender;
	import gl3d.core.TextureSet;
	import gl3d.meshs.Meshs;
	import gl3d.parser.OBJParser;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestObj extends BaseExample
	{
		private var loader:OBJParser;
		
		public function TestObj() 
		{
			//view.renderer = new GraphicsRender(view);;
		}
		
		override public function initNode():void 
		{
			view.fog.mode = Fog.FOG_EXP;
			addSky();
			var p:Node3D = new Node3D();
			p.drawable = Meshs.plane(5000);
			p.y = -2;
			p.material = new Material;
			view.scene.addChild(p);
			p.rotationX = 90;
			[Embed(source = "assets/miku.obj", mimeType = "application/octet-stream")]var c:Class;
			//[Embed(source = "assets/bumblebee-transformer-animation.obj", mimeType = "application/octet-stream")]var c:Class;
			[Embed(source = "assets/miku.mtl", mimeType = "application/octet-stream")]var c2:Class;
			loader = new OBJParser(new c +"", true, new c2 +"");
			
			[Embed(source = "assets/RB_Bumblebee_TEXTSET_Color_NormX.jpg")]var bc:Class;
			loader.target.children[0].material.reflectTexture = skyBoxTexture;
			
			loader.target.children[0].material.diffTexture = new TextureSet(new BitmapData(1,1,false,0xBBBB00));
			view.scene.addChild(loader.target);
			loader.target.y = -2;
			//loader.target.scaleX = loader.target.scaleY = loader.target.scaleZ = .01;
		}
	}

}