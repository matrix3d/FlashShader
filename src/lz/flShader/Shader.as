package lz.flShader 
{
	/**
	 * ...
	 * @author lizhi http://matrix3d.github.io/
	 */
	public class Shader 
	{
		private var consts:Vector.<ShaderObject> = new Vector.<ShaderObject>;
		private var vars:Vector.<ShaderObject> = new Vector.<ShaderObject>;
		private var attribs:Vector.<ShaderObject> = new Vector.<ShaderObject>;
		private var temps:Vector.<ShaderObject> = new Vector.<ShaderObject>;
		private var funs:Vector.<ShaderFun> = new Vector.<ShaderFun>;
		public function Shader() 
		{
			
		}
		
		public function addInput(name:String):ShaderObject {
			var so:ShaderObject = new ShaderObject(ShaderObject.TYPE_ATTRIB, attribs.length, 4, name);
			attribs.push(so);
			return so;
		}
		
		private function iCreateFloat(len:int, name:String):ShaderObject {
			var so:ShaderObject = new ShaderObject(ShaderObject.TYPE_VAR, vars.length, len, name);
			vars.push(so);
			return so;
		}
		
		public function createFloat(name:String):ShaderObject {
			return iCreateFloat(1, name);
		}
		public function createFloat2(name:String):ShaderObject {
			return iCreateFloat(2, name);
		}
		public function createFloat3(name:String):ShaderObject {
			return iCreateFloat(3, name);
		}
		public function createFloat4(name:String):ShaderObject {
			return iCreateFloat(4, name);
		}
		public function createMatrix44(name:String):ShaderObject {
			return iCreateFloat(16, name);
		}
		
		protected function normFun(name:String, a:Object, b:Object):ShaderObject {
			var sf:ShaderFun = new ShaderFun(name,new <ShaderObject>[getObj(a),getObj(b)],getTemp());
			funs.push(sf);
			return sf.ret;
		}
		
		private function getObj(a:Object):ShaderObject {
			if (a is int || a is uint|| a is Number||a is Array) {
				return addConst(a);
			}
			return a as ShaderObject;
		}
		
		private function getTemp():ShaderObject {
			var so:ShaderObject =new ShaderObject(ShaderObject.TYPE_TEMP, temps.length, 4);
			temps.push(so);
			return so;
		}
		
		private function addConst(v:Object):ShaderObject {
			var so:ShaderObject=new ShaderObject(ShaderObject.TYPE_CONST,consts.length,4);
			if (v is int || v is uint || v is Number) {
				consts.push(so);
			}else if (v is Array) {
				for (var i:int = 0; i < 4;i++ ) {
					//consts.push(Number(v[i]));
				}
				consts.push(so);
			}
			return so;
		}
		
		public function add(a:Object,b:Object):ShaderObject {
			return normFun("add",a,b);
		}
		public function mul(a:Object,b:Object):ShaderObject {
			return normFun("mul",a,b);
		}
		
		public function build():void {
			
		}
	}

}