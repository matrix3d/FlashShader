package gl3d.parser 
{
	/**
	 * ...
	 * @author lizhi
	 */
	public class ColladaDecoder 
	{
		private var xml:XML;
		
		public function ColladaDecoder(txt:String) 
		{
			txt = txt.replace(/xmlns=[^"]*"[^"]*"/g,"");
			xml = new XML(txt);
			var asset:XMLList = xml.asset;
			var scene:XMLList = xml.scene.instance_visual_scene;
			
			
			var animations:Object = parserLibrary("library_animations","animation");
			var lights:Object = parserLibrary("library_lights","light");
			var images:Object = parserLibrary("library_images","image");
			var materials:Object =parserLibrary("library_materials","material");
			var effects:Object =parserLibrary("library_effects","effect");
			var geometries:Object =parserLibrary("library_geometries","geometry");
			var controllers:Object =parserLibrary("library_controllers","controller"); 
			var visualScenes:Object = parserLibrary("library_visual_scenes","visual_scene"); 
		}
		
		private function parserLibrary(libname:String, name:String):Object {
			var obj:Object = { };
			var list:XMLList = xml[libname][name];
			for each(var c:XML in list) {
				obj[c.@id] = c;
			}
			return  obj;
		}
		
	}

}