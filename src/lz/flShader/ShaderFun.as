package lz.flShader 
{
	/**
	 * ...
	 * @author lizhi http://matrix3d.github.io/
	 */
	public class ShaderFun 
	{
		private var name:String;
		private var parms:Vector.<ShaderObject>;
		public var ret:ShaderObject;
		
		public function ShaderFun(name:String,parms:Vector.<ShaderObject>,ret:ShaderObject) 
		{
			this.ret = ret;
			this.parms = parms;
			this.name = name;
			
		}
		
	}

}