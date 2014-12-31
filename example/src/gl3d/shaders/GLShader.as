package gl3d.shaders 
{
	import com.adobe.utils.AGALMiniAssembler;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flShader.AGALByteCreator;
	import flShader.FlShader;
	import flShader.GLCodeCreator;
	import gl3d.core.Camera3D;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.core.ProgramSet;
	import gl3d.core.TextureSet;
	import gl3d.util.Utils;
	import gl3d.core.VertexBufferSet;
	import gl3d.core.View3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class GLShader 
	{
		public var invalid:Boolean = true;
		public var vs:FlShader;
		public var fs:FlShader;
		public var programSet:ProgramSet;
		public var textureSets:Vector.<TextureSet>;
		public var buffSets:Vector.<VertexBufferSet>;
		public var debug:Boolean = true;
		public function GLShader() 
		{
			textureSets = new Vector.<TextureSet>;
			buffSets = new Vector.<VertexBufferSet>;
		}
		
		public function getProgram(material:Material):ProgramSet {
			vs = getVertexShader(material);
			fs = getFragmentShader(material);
			
			if (debug) {
				var agalMiniAssembler:AGALMiniAssembler = new AGALMiniAssembler;
				trace(this);
				var code:String = vs.code;
				trace("vcode "+vs+" numline",vs.lines.length);
				trace(code);
				agalMiniAssembler.assemble(vs.programType, code);
				code = fs.code;
				trace("fcode "+fs+" numline",fs.lines.length);
				trace(code);
				agalMiniAssembler.assemble(fs.programType, code);
				trace();
				
				//vs.creator = new GLCodeCreator();
				//fs.creator = new GLCodeCreator();
				//trace("glvcode "+vs);
				//trace(vs.code);
				//trace("glfcode "+fs);
				//trace(fs.code);
			}
			vs.creator = new AGALByteCreator(material.view.agalVersion);
			fs.creator = new AGALByteCreator(material.view.agalVersion);
			programSet = new ProgramSet(vs.code2 as ByteArray, fs.code2 as ByteArray);
			return programSet;
		}
		
		public function getVertexShader(material:Material):FlShader {
			return null;
		}
		
		public function getFragmentShader(material:Material):FlShader {
			return null;
		}
		
		public function preUpdate(material:Material):void {
			var context:Context3D = material.view.context;
			for (var i:int = 0; i < 8;i++ ) {
				context.setTextureAt(i, null);
				context.setVertexBufferAt(i, null);
			}
		}
		
		public function update(material:Material):void 
		{
			if (invalid) {
				programSet = getProgram(material);
				invalid = false;
			}
			
			if(textureSets)
			for (var i:int = 0; i < textureSets.length;i++ ) {
				var textureSet:TextureSet = textureSets[i];
				if (textureSet) {
					textureSet.update(material.view);
					textureSet.bind(material.view.context, i);
				}
			}
			if(buffSets)
			for (i = 0; i < buffSets.length;i++ ) {
				var buffSet:VertexBufferSet = buffSets[i];
				if (buffSet) {
					buffSet.update(material.view.context);
					buffSet.bind(material.view.context, i);
				}
			}
			
			if (programSet) {
				programSet.update(material.view.context);
				material.view.context.setProgram(programSet.program);
			}
		}
	}

}