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
		
		public function PhongVertexShader(material:Material) 
		{
			super(Context3DProgramType.VERTEX);
			this.material = material;
		}
		
		override public function build():void {
			var model:Var = C();
			var world2local:Var = C(12);
			var view:Var = C(4);
			var perspective:Var = C(8);
			var lightPos:Var = mov(C(16));
			var pos:Var = VA();
			var norm:Var = VA(1);
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