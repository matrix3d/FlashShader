package gl3d.shaders 
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.geom.Vector3D;
	import flShader.FlShader;
	import gl3d.core.Camera3D;
	import gl3d.core.Drawable3D;
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
		private var lightPosVec:Vector.<Number> = Vector.<Number>([0,0,0,1]);
		private var specularPowerVec:Vector.<Number> = Vector.<Number>([0,0,0,0]);
		public function PhongGLShader() 
		{
		}
		
		override public function getVertexShader(material:Material):FlShader {
			return new PhongVertexShader(material);
		}
		
		override public function getFragmentShader(material:Material):FlShader {
			return new PhongFragmentShader(material);
		}
		
		override public function preUpdate(material:Material):void {
			super.preUpdate(material);
			
			drawable = material.wireframeAble?material.node.unpackedDrawable:material.node.drawable;
			
			textureSets= material.textureSets;
			buffSets.length = 0;
			buffSets[0] = drawable.pos;
			buffSets[1] = material.lightAble?drawable.norm:null;
			buffSets[2] =textureSets.length?drawable.uv:null;
			buffSets[3] = material.normalMapAble?drawable.tangent:null;
			buffSets[4] = material.wireframeAble?drawable.targetPosition:null;
			if (material.gpuSkin) {
				buffSets[5] = drawable.weights;
				buffSets[6] = drawable.joints;
			}
		}
		
		override public function update(material:Material):void 
		{
			super.update(material);
			var context:Context3D = material.view.context;
			if (programSet) {
				var view:View3D = material.view;
				var camera:Camera3D = material.camera;
				var node:Node3D = material.node;
				
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
					var lightPos:Vector3D = view.light.world.position;
					lightPosVec[0] = lightPos.x;
					lightPosVec[1] = lightPos.y;
					lightPosVec[2] = lightPos.z;
					context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, pvs.lightPos.index, lightPosVec);//light pos
				}
				if (material.gpuSkin) {
					var jointStart:int = pvs.joints.index;
					for (var i:int = 0; i < node.skin.skinFrame.matrixs.length;i++ ) {
						context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, jointStart+i*4, node.skin.skinFrame.matrixs[i], true);
					}
				}
				
				if(pfs.diffColor.used){
					var alpha:Number = material.alpha;
					var color:Vector.<Number> = material.color;
					color[3] = alpha;
					context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, pfs.diffColor.index, color);//color
				}
				if (material.lightAble) {
					if(pfs.lightColor.used){
						view.light.color[3] = material.shininess;
						context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, pfs.lightColor.index, view.light.color);//light color
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
		}
		
	}

}