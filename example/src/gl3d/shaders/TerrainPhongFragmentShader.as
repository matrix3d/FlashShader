package gl3d.shaders 
{
	import as3Shader.Var;
	import gl3d.core.Material;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TerrainPhongFragmentShader extends PhongFragmentShader
	{
		public function TerrainPhongFragmentShader() 
		{
		}

		override public function getDiffColor():Var {
			var uv:Var = (vs as PhongVertexShader).uvVarying;
			//repeat,miplinear
			var map:Var = tex(uv, samplerDiff(), null, material.diffTexture.flags);
			//mov(sub2([1,map.x,map.y,map.z]),map.w);
			var diffColor0:Var = tex(mul(uv,uniformTerrainScaleVar().x), samplerTerrains(0),null,material.terrainTextureSets[0].flags);
			var diffColor1:Var = tex(mul(uv,uniformTerrainScaleVar().y), samplerTerrains(1),null,material.terrainTextureSets[1].flags);
			var diffColor2:Var = tex(mul(uv,uniformTerrainScaleVar().z), samplerTerrains(2),null,material.terrainTextureSets[2].flags);
			//var diffColor3:Var = tex(mul(uv,uniformTerrainScaleVar().w), samplerTerrains(3),null,material.terrainTextureSets[3].flags);
			var diffColor:Var=
						add2([
							mul(diffColor0,map.x),
							mul(diffColor1,map.y),
							mul(diffColor2,map.z)/*,
							mul(diffColor3,map.z)*/
						]);
			mov(1,diffColor.w);//diffColor.w = 1;
			return diffColor;
		}
	}

}