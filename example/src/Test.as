package 
{
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.net.URLRequest;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Test extends Sprite
	{
		private var loader:Loader;
		
		public function Test() 
		{
			loader = new Loader;
			addChild(loader);
			loader.load(new URLRequest("red.atf"));
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_complete);
		}
		
		private function loader_complete(e:Event):void 
		{
			trace(loader.width);
			trace(loader.height);
		}
		
	}

}