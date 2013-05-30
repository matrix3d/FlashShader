package  
{
  import flash.display.Sprite;
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author lizhi http://matrix3d.github.io/
	 */
	public class TestAgal extends Sprite
	{
		private var consts:Vector.<Vector3D> = new Vector.<Vector3D>;
		private var constsCounter:Vector.<int> = new Vector.<int>;
		private var vars:Vector.<Object> = new Vector.<Object>;
		public function TestAgal() 
		{
			trace("mov", "op", mul(add(new Vector3D(1, 2, 3, 4), 1), add(1, 2)));
			trace("");
			trace("consts");
			for each(var v:Vector3D in consts) {
				trace(v.x,v.y,v.z,v.w);
			}
		}
		
		public function add(a:Object, b:Object):String {
			var namea:String = getString(a);
			var nameb:String = getString(b);
			var ret:String = getVar();
			trace("add", ret,namea,nameb);
			return ret;
		}
		
		public function mul(a:Object, b:Object):String {
			var namea:String = getString(a);
			var nameb:String = getString(b);
			var ret:String = getVar();
			trace("mul", ret,namea,nameb);
			return ret;
		}
		
		public function getString(a:Object):String {
			if (a is int) {
				return addConst(a);
			}else if (a is Number) {
				return addConst(a);
			}else if (a is Vector3D) {
				return addConst(a);
			}
			return a+"";
		}
		
		public function getVar():String {
			vars.push( { } );
			return "vt" + (vars.length - 1);
		}
		
		public function addConst(v:Object):String {
			if (v is int || v is Number) {
				consts.push(new Vector3D(Number(v)));
			}else if (v is Vector3D) {
				consts.push(v.clone());
			}else {
				trace("error");
			}
			var v3d:Vector3D = consts[consts.length - 1];
			var name:String = "vc" + (consts.length - 1);
			return name;
		}
	}

}

