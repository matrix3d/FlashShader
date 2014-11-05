package gl3d.util 
{
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Utils 
	{
		
		public function Utils() 
		{
			
		}
		
		public static function tracebyte(byte:ByteArray,isTrace:Boolean=true):Array {
			var a:Array = [];
			for (var i:int = 0; i < byte.length;i++ ) {
				a.push(byte[i]);
			}
			if(isTrace)
			trace(a);
			return a;
		}
		
		public static function compareByte(b1:ByteArray, b2:ByteArray):Boolean {
			return (tracebyte(b1,false)+"")==(tracebyte(b2,false)+"")
		}
		
		public static function getID(obj:Object):String {
			try
			{
				FakeClass(obj);
			}
			catch (e:Error)
			{
				return String( e ).replace( /.*(@\w+).*/, "$1" );
			}
			return null;
		}
		
	}

}
internal final class FakeClass { }