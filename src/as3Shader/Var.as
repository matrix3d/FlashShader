package as3Shader {
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	/**
	 * ...
	 * @author lizhi
	 */
	dynamic public class Var extends Proxy
	{
		public static const TYPE_C:int = 1;
		public static const TYPE_T:int = 2;
		public static const TYPE_VA:int = 3;
		public static const TYPE_V:int = 4;
		public static const TYPE_FS:int = 5;
		public static const TYPE_OC:int = 6;
		public static const TYPE_OP:int = 7;
		
		public var index:int;
		public var type:int;
		public var component:Object;
		public var componentOffset:int;
		
		public var data:Object;
		public var constLenght:int = 1;
		public var used:Boolean = false;
		public var name:String;
		public var parent:Var;
		public function Var(type:int,index:int=0) {
			this.type = type;
			this.index = index;
		}
		
		public function get root():Var {
			if (parent == null) return this;
			return parent.root;
		}
		
		public function c(value:Object,offset:int=0):Var {
			var v:Var = new Var(type, index);
			v.parent = this;
			if (component) {
				if (component is String&&value is String) {
					var v0:String = value as String;
					var v1:String = component as String;
					var value2:String = "";
					for (var i:int = 0; i < v0.length; i++ ) {
						var d:int = charCodeAt(v0,i) - charCodeAt("x",0);
						if (d<v1.length) {
							value2 += v1.charAt(d);
						}else {
							value2 += v0.charAt(i);
						}
					}
					value = value2;
				}else {
					throw "error";
				}
			}
			v.component = value;
			v.componentOffset = offset;
			v.constLenght = constLenght;
			return v;
		}
		
		private function charCodeAt(txt:String, i:int):int {
			if (txt.charAt(i)=="w") {
				return 123;
			}
			return txt.charCodeAt(i);
		}
		
		public function toString():String {
			return [type, index] + "";
		}
		
		override flash_proxy function getProperty(name:*):* 
		{
			return c(name.localName);
		}
	}

}