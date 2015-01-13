package gl3d.shaders 
{
	import flash.display3D.Context3DProgramType;
	import flash.display3D.textures.Texture;
	import flShader.FlShader;
	import flShader.Var;
	import gl3d.core.Material;
	import gl3d.core.TextureSet;
	/**
	 * ...
	 * @author lizhi
	 */
	public class PhongVertexShader extends FlShader
	{
		private var material:Material;
		public var model:Var = matrix();
		public var world2local:Var = matrix();
		public var view:Var = matrix();
		public var perspective:Var = matrix();
		public var lightPos:Var = uniform();
		public var joints:Var;
		public function PhongVertexShader(material:Material) 
		{
			super(Context3DProgramType.VERTEX);
			this.material = material;
		}
		
		override public function build():void {
			var pos:Var = VA();
			var norm:Var = VA(1);
			if (material.gpuSkin) {
				joints = matrixArray(material.node.skin.joints.length);
				var weight:Var = VA(5);
				var xyzw:String = "xyzw";
				for (var i:int = 0; i < material.node.skin.maxWeight; i++ ) {
					var c:String = xyzw.charAt(i % 4);
					var joint:Var = VA(6).c(c);
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
			
			var uv:Var = VA(2);
			var tangent:Var = VA(3);
			var targetPosition:Var = VA(4);
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
					mov(eyeDirection, V(2));
				}
				if (material.normalMapAble) {
					var posLight:Var = nrm(m33(sub(lightPos, worldPos),world2local));
				}else {
					posLight = nrm(sub(lightPos, worldPos));
				}
				mov(posLight, V());
				
				if (material.normalMapAble) {
					mov(norm, V(1));
				}else {
					var modelNormal:Var = nrm(m33(norm, model));
					mov(modelNormal, V(1));
				}
				
				if (material.normalMapAble) {
					mov(tangent,V(4))
				}
			}
			
			if (material.textureSets.length>0) {
				mov(uv, V(3));
			}
			if (material.wireframeAble) {
				mov(targetPosition,V(4));
			}
		}
	}

}