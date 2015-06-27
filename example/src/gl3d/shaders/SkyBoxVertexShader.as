package gl3d.shaders 
{
	import as3Shader.AS3Shader;
	import as3Shader.Var;
	/**
	 * ...
	 * @author lizhi
	 */
	public class SkyBoxVertexShader extends AS3Shader
	{
		public var dir:Var;
		public var pos:Var;
		public var m:Var;
		public var v:Var;
		public var p:Var;
		public var camPos:Var;
		public function SkyBoxVertexShader() 
		{
			pos = buff();
			m = matrix();
			v = matrix();
			p = matrix();
			camPos = uniform();
			var wpos:Var = m44(pos, m);
			op = m44(m44(wpos,v),p);
			
			dir = varying();
			sub(wpos, camPos,dir);
		}
		
	}

}