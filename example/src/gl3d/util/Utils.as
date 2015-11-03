package gl3d.util 
{
	import flash.display.BitmapData;
	import flash.external.ExternalInterface;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import gl3d.core.Node3D;
	import gl3d.core.skin.Joint;
	import gl3d.core.skin.SkinAnimation;
	import gl3d.ctrl.Ctrl;
	import ui.Color;
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
			/*var p:Object = { };
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
			return p;*/
			return null;
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
		
		public static function createXorMap(b:BitmapData):void {
			for (var i:int = 0; i < b.height; i++){
				for (var k:int = 0; k < b.width; k++){
					b.setPixel(k,i, (i^k)<<16 | (i ^ k) << 8 | (i^k));
				}
			}
		}
		public static function createNormalMap(bmd:BitmapData,scale:Number=5,kUseTwoMaps:Boolean=true):BitmapData {
			var bmd2:BitmapData = bmd.clone();
			var valuePX:Color = new Color;
			var valueNX:Color = new Color;
			var valuePY:Color = new Color;
			var valueNY:Color = new Color;
			var neighbors:Color = new Color;
			var slope:Color = new Color;
			for (var x:int = 0; x < bmd.width;x++ ) {
				for (var y:int = 0; y < bmd.height; y++ ) {
					valuePX.fromHex(bmd.getPixel(x+1,y));
					valueNX.fromHex(bmd.getPixel(x-1,y));
					valuePY.fromHex(bmd.getPixel(x,y+1));
					valueNY.fromHex(bmd.getPixel(x,y-1));
					valuePX.scale(1 / 0xff);
					valueNX.scale(1 / 0xff);
					valuePY.scale(1 / 0xff);
					valueNY.scale(1 / 0xff);
					
					if (kUseTwoMaps) {
						var factor:Number = 1.0 / (2.0 * 255.0); // 255.0 * 2.0
						// Reconstruct the high-precision values from the low precision values
						valuePX.r += 255.0 * (valuePX.b - 0.5);
						valueNX.r += 255.0 * (valueNX.b - 0.5);
						valuePY.r += 255.0 * (valuePY.b - 0.5);
						valueNY.r += 255.0 * (valueNY.b - 0.5);
					}else {
						factor = 1.0 / 2.0;
					}
					// Take into account the boundary conditions in the pool
					
					neighbors.r = valuePX.r * (valuePX.g) + (1.0 - valuePX.g) * valueNX.r; // Enforce the boundary conditions as mirror reflections
					neighbors.g = valuePY.r * (valuePY.g) + (1.0 - valuePY.g) * valueNY.r; // Enforce the boundary conditions as mirror reflections
					neighbors.b = valueNX.r * (valueNX.g) + (1.0 - valueNX.g) * valuePX.r; // Enforce the boundary conditions as mirror reflections
					var w:Number = valueNY.r * (valueNY.g) + (1.0 - valueNY.g) * valuePY.r; // Enforce the boundary conditions as mirror reflections
					 
					slope.fromRGB(scale * (neighbors.b - neighbors.r) * factor, 
										   scale * (w - neighbors.g) * factor, 1.0);
					
					slope.r *= 5.0;
					slope.g *= 5.0;
					slope.r += .5;
					slope.g += .5;
					slope.scale(0xff);
					bmd2.setPixel(x,y,slope.toHex() );
				}
			}
			return bmd2;
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
		
		public static function exportNode(node:Node3D,geoms:Dictionary=null):Object {
			geoms = geoms||new Dictionary;
			var nodeObj:Object = { };
			if (node.name) {
				nodeObj.name = node.name;
				if (node is Joint) {
					node.type = "JOINT";
				}
				if (node.skin) {
					
				}
				if (node.drawable) {
					
				}
				if (node.controllers) {
					for each(var controller:Ctrl in node.controllers) {
						if (controller is SkinAnimation) {
							
						}
					}
				}
			}
			if (node.children.length) {
				nodeObj.children = [];
				for each(var child:Node3D in node.children) {
					nodeObj.children.push(exportNode(child, geoms));
				}
			}
			return {root:nodeObj,geoms:[]};
		}
		
	}

}
internal final class FakeClass { }