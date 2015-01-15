package gl3d.shaders 
{
	import flash.display3D.Context3DProgramType;
	import flash.display3D.textures.Texture;
	import as3Shader.AS3Shader;
	import as3Shader.Var;
	import gl3d.core.Material;
	import gl3d.core.TextureSet;
	/**
	 * ...
	 * @author lizhi
	 */
	public class PhongVertexShader extends AS3Shader
	{
		private var material:Material;
		public var model:Var = matrix();
		public var world2local:Var = matrix();
		public var view:Var = matrix();
		public var perspective:Var = matrix();
		public var lightPos:Var = uniform();
		public var joints:Var;
		
		
		public var pos:Var = buff();
		public var norm:Var = buff();
		public var uv:Var = buff();
		public var tangent:Var = buff();
		public var targetPosition:Var = buff();
		public var weight:Var = buff();
		public var joint:Var = buff();
		
		public var eyeDirectionVarying:Var = varying();
		public var posLightVarying:Var = varying();
		public var normVarying:Var = varying();
		public var tangentVarying:Var = varying();
		public var uvVarying:Var = varying();
		public var targetPositionVarying:Var = varying();
		public function PhongVertexShader(material:Material) 
		{
			super(Context3DProgramType.VERTEX);
			this.material = material;
		}
		
		override public function build():void {
			var norm:Var = this.norm;
			var pos:Var = this.pos;
			if (material.gpuSkin) {
				joints = matrixArray(material.node.skin.joints.length);
				var xyzw:String = "xyzw";
				for (var i:int = 0; i < material.node.skin.maxWeight; i++ ) {
					var c:String = xyzw.charAt(i % 4);
					var joint:Var = this.joint.c(c);
					var value:Var = mul(weight.c(c), m44(pos, joints.c(joint)));
					if (i==0) {
						var result:Var = value;
					}else {
						result = add(result, value);
					}
					if(material.lightAble){
						var valueNorm:Var = mul(weight.c(c), m33(norm, joints.c(joint)));
						if (i==0) {
							var resultNorm:Var = valueNorm;
						}else {
							resultNorm = add(resultNorm, valueNorm);
						}
					}
				}
				pos = result;
				if (material.lightAble) {
					norm = nrm(resultNorm);
				}
			}
			
			var worldPos:Var = m44(pos, model);
			var viewPos:Var = m44(worldPos, view);
			m44(viewPos, perspective, op);
			
			if (material.lightAble) {
				if(material.specularAble){
					if (material.normalMapAble) {
						var eyeDirection:Var = nrm(m33(neg(viewPos),world2local));
					}else {
						eyeDirection = nrm(neg(viewPos));
					}
					mov(eyeDirection, eyeDirectionVarying);
				}
				if (material.normalMapAble) {
					var posLight:Var = nrm(m33(sub(lightPos, worldPos),world2local));
				}else {
					posLight = nrm(sub(lightPos, worldPos));
				}
				mov(posLight, posLightVarying);
				
				if (material.normalMapAble) {
					mov(norm, normVarying);
				}else {
					var modelNormal:Var = nrm(m33(norm, model));
					mov(modelNormal, normVarying);
				}
				
				if (material.normalMapAble) {
					mov(tangent,tangentVarying)
				}
			}
			
			if (material.diffTexture) {
				mov(uv, uvVarying);
			}
			if (material.wireframeAble) {
				mov(targetPosition,targetPositionVarying);
			}
		}
	}

}