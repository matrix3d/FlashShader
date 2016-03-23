package 
{
	import flash.display.Sprite;
	import flash.utils.Proxy;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Test extends Sprite
	{
		public function Test() 
		{
			var mv:MyVar = new MyVar;
			var k:Object={a:"1"}
			trace(mv[k]);
			trace(mv[k]);
			flash.utils.
		}
	}

}
import flash.utils.Proxy;
import flash.utils.flash_proxy;

dynamic class MyVar extends Proxy{
	override flash_proxy function getProperty(name:*):* 
	{
		trace(1);
		return null;
	}
	
	public function ddd():void{
		
	}
}