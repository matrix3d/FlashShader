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
	import gl3d.core.renders.GL;
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
		public var debug:Boolean = false;
		public function GLShader() 
		{
			textureSets = [];
			buffSets = [];
		}
		
		public function getProgram(material:Material):ProgramSet {
			vs = getVertexShader(material);
			fs = getFragmentShader(material);
			
			if (debug&&vs&&fs) {
				trace(this);
				var code:String = vs.code as String;
				trace("vcode "+vs+" numline",vs.lines.length);
				trace(code);
				vs.creator = new GLCodeCreator();
				trace(vs.code);
				code = fs.code as String;
				trace("fcode "+fs+" numline",fs.lines.length);
				trace(code);
				fs.creator = new GLCodeCreator();
				trace(fs.code);
				trace();
			}
			if(vs&&fs){
				vs.creator = new AGALByteCreator(material.view.renderer.agalVersion);
				fs.creator = new AGALByteCreator(material.view.renderer.agalVersion);
				programSet = new ProgramSet(vs.code as ByteArray, fs.code as ByteArray);
			}
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
				
				material.view.renderer.gl3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, vs.constMemLen, vs.constPoolVec);
				material.view.renderer.gl3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, fs.constMemLen, fs.constPoolVec);
			}
		}
		
		public function update(material:Material):void 
		{
			if(textureSets)
			for (var i:int = 0; i < textureSets.length;i++ ) {
				var textureSet:TextureSet = textureSets[i];
				if (textureSet) {
					textureSet.update(material.view);
					textureSet.bind(material.view.renderer.gl3d, i);
				}
			}
			if(buffSets)
			for (i = 0; i < buffSets.length;i++ ) {
				var buffSet:VertexBufferSet = buffSets[i];
				if (buffSet) {
					buffSet.update(material.view.renderer.gl3d);
					buffSet.bind(material.view.renderer.gl3d, i);
				}
			}
			
			if (programSet) {
				programSet.update(material.view.renderer.gl3d);
				material.view.renderer.gl3d.setProgram(programSet.program);
				material.view.renderer.gl3d.setDepthTest(true, material.passCompareMode);
				material.view.renderer.gl3d.setBlendFactors(material.sourceFactor, material.destinationFactor);
				material.view.renderer.gl3d.setCulling(material.culling);
				material.view.renderer.gl3d.drawTriangles(material.node.drawable.index.buff);
			}
		}
	}

}