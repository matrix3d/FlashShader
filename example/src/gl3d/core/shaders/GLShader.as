package gl3d.core.shaders 
{
	import com.adobe.utils.AGALMiniAssembler;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import as3Shader.AGALByteCreator;
	import as3Shader.AS3Shader;
	import as3Shader.GLCodeCreator;
	import gl3d.core.Camera3D;
	import gl3d.core.GL;
	import gl3d.core.shaders.GLAS3Shader;
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
		public var vs:GLAS3Shader;
		public var fs:GLAS3Shader;
		public var programSet:ProgramSet;
		public var textureSets:Array=[];
		public var buffSets:Array;
		public var debug:Boolean = true;
		public function GLShader() 
		{
			textureSets = [];
			buffSets = [];
		}
		
		public function getProgram(material:Material):ProgramSet {
			vs = getVertexShader(material);
			fs = getFragmentShader(material);
			
			if (debug) {
				var agalMiniAssembler:AGALMiniAssembler = new AGALMiniAssembler;
				trace(this);
				var code:String = vs.code as String;
				trace("vcode "+vs+" numline",vs.lines.length);
				trace(code);
				agalMiniAssembler.assemble(vs.programType, code);
				code = fs.code as String;
				trace("fcode "+fs+" numline",fs.lines.length);
				trace(code);
				agalMiniAssembler.assemble(fs.programType, code);
				trace();
				
				vs.creator = new GLCodeCreator();
				fs.creator = new GLCodeCreator();
				trace("glvcode "+vs);
				trace(vs.code);
				//trace("glfcode "+fs);
				//trace(fs.code);
			}
			vs.creator = new AGALByteCreator(material.view.agalVersion);
			fs.creator = new AGALByteCreator(material.view.agalVersion);
			programSet = new ProgramSet(vs.code as ByteArray, fs.code as ByteArray);
			return programSet;
		}
		
		public function getVertexShader(material:Material):GLAS3Shader {
			return null;
		}
		
		public function getFragmentShader(material:Material):GLAS3Shader {
			return null;
		}
		
		public function preUpdate(material:Material):void {
			if (invalid) {
				programSet = getProgram(material);
				invalid = false;
			}
			if(programSet){
				vs.bind(this,material);
				fs.bind(this, material);
				
				material.view.gl3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, vs.constMemLen, vs.constPoolVec);
				material.view.gl3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, fs.constMemLen, fs.constPoolVec);
			}
		}
		
		public function update(material:Material):void 
		{
			if(textureSets)
			for (var i:int = 0; i < textureSets.length;i++ ) {
				var textureSet:TextureSet = textureSets[i];
				if (textureSet) {
					textureSet.update(material.view);
					textureSet.bind(material.view.gl3d, i);
				}
			}
			if(buffSets)
			for (i = 0; i < buffSets.length;i++ ) {
				var buffSet:VertexBufferSet = buffSets[i];
				if (buffSet) {
					buffSet.update(material.view.gl3d);
					buffSet.bind(material.view.gl3d, i);
				}
			}
			
			if (programSet) {
				programSet.update(material.view.gl3d);
				material.view.gl3d.setProgram(programSet.program);
				material.view.gl3d.setDepthTest(true, material.passCompareMode);
				material.view.gl3d.setBlendFactors(material.sourceFactor, material.destinationFactor);
				material.view.gl3d.setCulling(material.culling);
				material.view.gl3d.drawTriangles(material.node.drawable.index.buff);
			}
		}
	}

}