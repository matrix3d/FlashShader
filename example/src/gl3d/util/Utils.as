package gl3d.util 
{
	import flash.display.BitmapData;
	import flash.external.ExternalInterface;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import gl3d.core.Drawable;
	import gl3d.core.Node3D;
	import gl3d.core.skin.Joint;
	import gl3d.core.skin.SkinAnimation;
	import gl3d.ctrl.Ctrl;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Utils 
	{
		
		public function Utils() 
		{
			
		}
		
		public static function getParameters():Object {
			var p:Object = { };
			if (ExternalInterface.available) {
				var search:String = decodeURI(ExternalInterface.call("function(){return window.location.search}"));
				if (search.length > 0) {
					var kvs:Array = search.substr(1).split("&");
					for each(var kv:String in kvs) {
						var i:int = kv.indexOf("=");
						p[kv.substr(0, i)] = kv.substr(i+1);
					}
				}
			}
			return p;
		}
		
		public static function randomSphere(vector:Vector3D=null,rotation:Vector3D=null):Vector3D {
			vector = vector || new Vector3D;
			var rvals:Number = 2 * Math.random() - 1;
			var elevation:Number = Math.asin(rvals);
			var azimuth:Number = 2 * Math.PI * Math.random();
			var radii:Number = Math.pow(3 * Math.random(), 1 / 3);
			vector.w = radii;
			if (rotation) {
				rotation.x = elevation;
				rotation.y = azimuth;
			}
			vector.setTo(Math.cos(azimuth) * Math.cos(elevation), Math.sin(elevation), Math.sin(azimuth) * Math.cos(elevation));
			return vector;
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
		
		public static function traceNode(node:Node3D,depth:int=0):void {
			var tab:String = "";
			for (var i:int = 0; i < depth;i++ ) {
				tab += "\t";
			}
			trace(tab+node.name+":"+node.type);
			for each(var c:Node3D in node.children) {
				traceNode(c, depth + 1);
			}
		}
	}

}
internal final class FakeClass { }