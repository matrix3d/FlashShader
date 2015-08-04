package gl3d.shaders 
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import as3Shader.AS3Shader;
	import gl3d.core.Camera3D;
	import gl3d.core.Drawable3D;
	import gl3d.core.renders.GL;
	import gl3d.core.shaders.GLAS3Shader;
	import gl3d.core.shaders.GLShader;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.core.TextureSet;
	import gl3d.core.VertexBufferSet;
	import gl3d.core.View3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class PhongGLShader extends GLShader
	{
		private var drawable:Drawable3D;
		//private var lightPosVec:Vector.<Number> = Vector.<Number>([0,0,0,1]);
		//private var specularPowerVec:Vector.<Number> = Vector.<Number>([0,0,0,0]);
		public function PhongGLShader() 
		{
		}
		
		override public function getVertexShader(material:Material):GLAS3Shader {
			return new PhongVertexShader(material);
		}
		
		override public function getFragmentShader(material:Material):GLAS3Shader {
			return new PhongFragmentShader(material,vs as PhongVertexShader);
		}
		
		/*override public function preUpdate(material:Material):void {
			super.preUpdate(material);
			
			drawable = material.wireframeAble?material.node.unpackedDrawable:material.node.drawable;
			
			textureSets.length = 0;
			var fvs:PhongFragmentShader = fs as PhongFragmentShader;
			if (fvs.diffSampler.used) {
				textureSets[fvs.diffSampler.index] = material.diffTexture;
			}
			if (fvs.normalmapSampler.used) {
				textureSets[fvs.normalmapSampler.index] = material.normalmapTexture;
			}
			if (fvs.reflectSampler.used) {
				textureSets[fvs.reflectSampler.index] = material.reflectTexture;
			}
			buffSets.length = 0;
			var pvs:PhongVertexShader = vs as PhongVertexShader;
			if (pvs.pos.used) {
				buffSets[pvs.pos.index] = (material.node.skin&&material.node.skin.useCpu)?drawable.cpuSkinPos:drawable.pos;
			}
			if (pvs.norm.used) {
				buffSets[pvs.norm.index] = drawable.norm;
			}
			if (pvs.uv.used) {
				buffSets[pvs.uv.index] = drawable.uv;
			}
			if (pvs.tangent.used) {
				buffSets[pvs.tangent.index] = drawable.tangent;
			}
			if (pvs.targetPosition.used) {
				buffSets[pvs.targetPosition.index] = drawable.targetPosition;
			}
			if (pvs.joint.used) {
				buffSets[pvs.joint.index] = material.node.skin.useQuat?drawable.quatJoints:drawable.joints;
			}
			if (pvs.weight.used) {
				buffSets[pvs.weight.index] = drawable.weights;
			}
			if(drawable.joints&&drawable.joints.subBuffs){
				drawable.joints.subBuffs[0][0] = pvs.joint.index;
				drawable.joints.subBuffs[1][0] = pvs.joint2.index;
				drawable.quatJoints.subBuffs[0][0] = pvs.joint.index;
				drawable.quatJoints.subBuffs[1][0] = pvs.joint2.index;
				drawable.weights.subBuffs[0][0] = pvs.weight.index;
				drawable.weights.subBuffs[1][0] = pvs.weight2.index;
			}
		}*/
		
		/*override public function update(material:Material):void 
		{
			super.update(material);
			var context:GL = material.view.gl3d;
			if (programSet) {
				var view:View3D = material.view;
				var camera:Camera3D = material.camera;
				var node:Node3D = material.node;
				drawable = node.drawable;
				
				var pvs:PhongVertexShader = vs as PhongVertexShader;
				var pfs:PhongFragmentShader = fs as PhongFragmentShader;
				if (pvs.model.used) {
					context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, pvs.model.index, node.world, true);
				}
				if (pvs.world2local.used) {
					context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, pvs.world2local.index, node.world2local, true);
				}
				if (pvs.view.used) {
					context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, pvs.view.index, camera.view, true);
				}
				if (pvs.perspective.used) {
					context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, pvs.perspective.index, camera.perspective, true);
				}
				if (pvs.lightPos.used) {
					var lightPos:Vector3D = view.lights[0].world.position;
					lightPosVec[0] = lightPos.x;
					lightPosVec[1] = lightPos.y;
					lightPosVec[2] = lightPos.z;
					context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, pvs.lightPos.index, lightPosVec);//light pos
				}
				if (material.gpuSkin) {
					var jointStart:int = pvs.joints.index;
					if(node.skin.useQuat){
						context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, jointStart, node.skin.skinFrame.quaternions);
					}else {
						for (var i:int = 0; i < node.skin.skinFrame.matrixs.length;i++ ) {
							context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, jointStart+i*4, node.skin.skinFrame.matrixs[i], true);
						}
					}
					
				}
				
				if(pfs.diffColor.used){
					var alpha:Number = material.alpha;
					var color:Vector.<Number> = material.color;
					context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, pfs.diffColor.index, color);//color
				}
				if (material.lightAble) {
					if(pfs.lightColor.used){
						context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, pfs.lightColor.index, view.lights[0].color);//light color
					}
					if(pfs.ambientColor.used){
						context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, pfs.ambientColor.index, material.ambient);//ambient color 环境光
					}
					if(pfs.specular.used){
						specularPowerVec[0] = material.specularPower;
						context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, pfs.specular.index, specularPowerVec);//x:specular pow, y:2
					}
				}
				if(pfs.wireframeColor.used){
					context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, pfs.wireframeColor.index, material.wireframeColor);//x:specular pow, y:2
				}
				
				context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, vs.constMemLen, vs.constPoolVec);
				context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, fs.constMemLen, fs.constPoolVec);
				context.drawTriangles(drawable.index.buff);
			}
		}*/
		
	}

}