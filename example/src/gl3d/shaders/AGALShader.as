package gl3d.shaders 
{
	import com.adobe.utils.AGALMiniAssembler;
	import flash.display3D.Context3DProgramType;
	import gl3d.core.Material;
	import gl3d.core.ProgramSet;
	import gl3d.core.renders.GL;
	import gl3d.core.shaders.GLShader;
	/**
	 * ...
	 * @author lizhi
	 */
	public class AGALShader extends GLShader
	{
		private var vcode:String;
		private var fcode:String;
		
		public function AGALShader(vcode:String,fcode:String) 
		{
			this.fcode = fcode;
			this.vcode = vcode;
		}
		
		override public function getProgram(material:Material):ProgramSet 
		{
			var am:AGALMiniAssembler = new AGALMiniAssembler;
			return getProgramFromPool(material.view.id, am.assemble(Context3DProgramType.VERTEX, vcode), am.assemble(Context3DProgramType.FRAGMENT, fcode));
		}
		
	}

}