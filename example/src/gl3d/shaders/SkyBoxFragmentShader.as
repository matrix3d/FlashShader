package gl3d.shaders 
{
	import as3Shader.AS3Shader;
	import as3Shader.Var;
	import flash.display3D.Context3DProgramType;
	import gl3d.core.Fog;
	import gl3d.core.Material;
	import gl3d.core.shaders.GLAS3Shader;
	/**
	 * ...
	 * @author lizhi
	 */
	public class SkyBoxFragmentShader extends GLAS3Shader
	{
		private var svs:SkyBoxVertexShader;
		public function SkyBoxFragmentShader() 
		{
			super(Context3DProgramType.FRAGMENT);
			
		}
		
		override public function build():void 
		{
			svs = vs as SkyBoxVertexShader;
			var out:Var=tex(svs.dir, samplerDiff(),null,material.diffTexture.flags);
			if (material.fogAble){
				var fog:Fog = material.view.fog;
				if (fog.mode != Fog.FOG_NONE) {
					var d:Var = svs.dir.y;
					var low:Number = 0;
					var up:Number =30;
					var f:Var = sat(div(sub(d , low) , sub(up , low)));
					mix(material.view.fog.fogColor,out.xyz,f.x,out.xyz);
				}
			}
			mov(out, oc);
		}
		
	}

}