package gl3d.shaders 
{
	import as3Shader.AS3Shader;
	import as3Shader.Var;
	import gl3d.core.shaders.GLAS3Shader;
	/**
	 * ...
	 * @author lizhi
	 */
	public class SkyBoxVertexShader extends GLAS3Shader
	{
		public var dir:Var;
		public var pos:Var;
		public var v:Var;
		public var p:Var;
		public var m:Var;
		public function SkyBoxVertexShader() 
		{
			pos = buffPos();
			dir = varying();
			mov(pos, dir);
			m = uniformModel();
			v = uniformView();
			p = uniformPerspective();
			var wpos:Var = mov(pos);
			m33(m33(wpos,m,wpos.xyz), v, wpos.xyz);
			op = m44(wpos,p);
			
		}
		
	}

}