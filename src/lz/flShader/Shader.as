package lz.flShader 
{
	/**
	 * ...
	 * @author lizhi http://matrix3d.github.io/
	 */
	public class Shader 
	{
		private var consts:Vector.<Number> = new Vector.<Number>;
		private var tempCount:int = 0;
		public function Shader() 
		{
			
		}
		
		private function normFun(name:String, a:Object, b:Object):ShaderObject {
			trace(name,getObj(a),getObj(b));
			return getTemp();
		}
		
		private function getObj(a:Object):ShaderObject {
			if (a is int || a is uint|| a is Number||a is Array) {
				return addConst(a);
			}
			return a as ShaderObject;
		}
		
		private function getTemp():ShaderObject {
			return new ShaderObject(ShaderObject.TYPE_TEMP,tempCount++);
		}
		
		private function addConst(v:Object):ShaderObject {
			if (v is int||v is uint||v is Number) {
				consts.push(v, 0, 0, 0);
			}else if (v is Array) {
				for (var i:int = 0; i < 4;i++ ) {
					consts.push(Number(v[i]));
				}
			}
			return new ShaderObject(ShaderObject.TYPE_CONST,consts.length/4-1);
		}
		
		public function add(a:Object,b:Object):ShaderObject {
			return normFun("add",a,b);
		}
		public function mul(a:Object,b:Object):ShaderObject {
			return normFun("mul",a,b);
		}
	}

}