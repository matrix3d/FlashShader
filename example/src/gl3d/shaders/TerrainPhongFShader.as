package gl3d.shaders 
{
	import flShader.Var;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TerrainPhongFShader extends PhongFShader
	{
		
		public function TerrainPhongFShader() 
		{
		}

		override public function getDiffColor():Var {
			var uv:Var = V(3);
			var scaledUV:Var = mul(V(3), F([20]));
			var map:Var = tex(uv, FS(),null,["repeat"]);
			var diffColor0:Var = tex(scaledUV, FS(1),null,["repeat"]);
			var diffColor1:Var = tex(scaledUV, FS(2),null,["repeat"]);
			var diffColor2:Var = tex(scaledUV, FS(3),null,["repeat"]);
			var diffColor3:Var = tex(scaledUV, FS(4), null, ["repeat"]);
			var diffColor:Var=mul(F([.25]),
						add2([
							mul(diffColor0,map.x),
							mul(diffColor1,map.y),
							mul(diffColor2,map.z),
							mul(diffColor3,map.w)
						])
			);
			mov(F([1]),null,diffColor.w);//diffColor.w = 1;
			return diffColor;
		}
	}

}