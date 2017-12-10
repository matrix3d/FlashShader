package gl3d.core.shaders 
{
	import as3Shader.AGALCodeCreator;
	import as3Shader.Var;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.geom.Vector3D;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	import as3Shader.AGALByteCreator;
	import as3Shader.AS3Shader;
	import as3Shader.GLCodeCreator;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import gl3d.core.Camera3D;
	import gl3d.core.IndexBufferSet;
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
		public var debug:Boolean = true;
		public static var PROGRAM_POOL:Object = { };
		public static var LastMaterial:Material;
		public function GLShader(vs:GLAS3Shader,fs:GLAS3Shader) 
		{
			this.vs = vs;
			this.fs = fs;
			textureSets = [];
			buffSets = [];
		}
		
		public function getProgram(material:Material):ProgramSet {
			vs = getVertexShader(material);
			fs = getFragmentShader(material);
			
			if (vs && fs){
				if (Capabilities.playerType == "spriteflexjs"){
					vs.creator = new GLCodeCreator();
					fs.creator = new GLCodeCreator();
				}else{
					vs.creator = new AGALByteCreator(material.view.renderer.agalVersion);
					fs.creator = new AGALByteCreator(material.view.renderer.agalVersion);
				}
				programSet = getProgramFromPool(material.view.id,vs.code, fs.code);
			}
			return programSet;
		}
		
		protected function getProgramFromPool(id:Object,vcode:Object, fcode:Object):ProgramSet {
			var classname:String = this+":"/*getQualifiedClassName(this)*/ + id;
			//air 18 bug
			var pobj:Object = PROGRAM_POOL[classname];
			if(pobj)
			var ps:Vector.<ProgramSet> = pobj as Vector.<ProgramSet>;
			if (ps) {
				for each(var p:ProgramSet in ps) {
					if (p.vcode is String){
						if (p.vcode==vcode&&p.fcode==fcode){
							return p;
						}
					}else{
						if (p.vcode.length!=vcode.length||p.fcode.length!=fcode.length) {
							continue;
						}
						var flag:Boolean = false;
						for (var i:int = p.vcode.length - 1; i >= 0;i-- ) {
							if (p.vcode[i] != vcode[i]) {
								flag = true;
								break;
							}
						}
						if (flag) {
							continue;
						}
						flag = false;
						for (i = p.fcode.length - 1; i >= 0;i-- ) {
							if (p.fcode[i] != fcode[i]) {
								flag = true;
								break;
							}
						}
						if (flag) {
							continue;
						}
						return p;
					}
				}
			}else {
				ps=PROGRAM_POOL[classname]=new Vector.<ProgramSet>
			}
			ps.push(new ProgramSet(vcode, fcode));
			
			if (debug&&vs&&fs) {
				trace(this);
				doDebug(vs);
				doDebug(fs);
				trace();
			}
			return ps[ps.length-1];
		}
		
		public function doDebug(gl:GLAS3Shader):void {
			gl.creator = new AGALCodeCreator();
			var code:String = gl.code as String;
			trace(code);
			trace("consts index",gl.constMemLen);
			trace("consts",gl.constPoolVec);
			for (var name:String in gl.namedVars) {
				var v:Var = gl.namedVars[name];
				if(v.used)
				trace(v.index, name);
			}
			//trace(vs);
			//gl.creator = new GLCodeCreator();
			//trace(gl.code);
			trace();
		}
		
		public function getVertexShader(material:Material):GLAS3Shader {
			vs.material = material;
			return vs;
		}
		
		public function getFragmentShader(material:Material):GLAS3Shader {
			fs.material = material;
			fs.vs = vs;
			return fs;
		}
		
		public function update(material:Material):void 
		{
			var isLastSameMaterial:Boolean = LastMaterial == material;
			if (invalid) {
				programSet = getProgram(material);
				invalid = false;
			}
			if (programSet) {
				programSet.update(material.view.renderer.gl3d);
				if(!isLastSameMaterial){
					material.view.renderer.gl3d.setProgram(programSet.program);
					material.view.renderer.gl3d.setDepthTest(material.depthMask, material.passCompareMode);
					material.view.renderer.gl3d.setBlendFactors(material.sourceFactor, material.destinationFactor);
					material.view.renderer.gl3d.setCulling(material.culling);
				}
			}
			if(vs&&fs){
				vs.bind(this,material,isLastSameMaterial);
				fs.bind(this, material,isLastSameMaterial);
				if(!isLastSameMaterial){
					if(vs.constPoolVec.length)material.view.renderer.gl3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, vs.constMemLen, vs.constPoolVec);
					if(fs.constPoolVec.length)material.view.renderer.gl3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, fs.constMemLen, fs.constPoolVec);
				}
			}
			var allTexReady:Boolean = true;
			if(textureSets)
			for (var i:int = 0; i < textureSets.length;i++ ) {
				var textureSet:TextureSet = textureSets[i];
				if (textureSet) {
					textureSet.update(material.view);
					if (!textureSet.ready) {
						allTexReady = false;
					}
				}
			}
			if (!allTexReady) {
				return;
			}else {
				if(textureSets)
				for (i = 0; i < textureSets.length;i++ ) {
					textureSet = textureSets[i];
					if (textureSet) {
						textureSet.bind(material.view.renderer.gl3d, i);
					}
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
				var index:IndexBufferSet = material.node.drawable.index;
				material.view.renderer.gl3d.drawTriangles(index,0,index.numTriangles);
			}
			LastMaterial = material;
		}
	}

}