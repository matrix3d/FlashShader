package 
{
	import flash.events.Event;
	import gl3d.core.renders.GraphicsRender;
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
			addSky();
			[Embed(source = "assets/miku.obj", mimeType = "application/octet-stream")]var c:Class;
			[Embed(source = "assets/miku.mtl", mimeType = "application/octet-stream")]var c2:Class;
			loader = new OBJParser(new c +"",true,new c2 +"");
			loader.target.children[0].material.reflectTexture = skyBoxTexture;
			view.scene.addChild(loader.target);
			loader.target.y = -2;
		}
	}

}