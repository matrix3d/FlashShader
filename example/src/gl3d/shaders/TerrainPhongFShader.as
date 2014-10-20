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
			var scaledUV:Var = mul(V(3), F([10]));
			var map:Var = tex(uv, FS(), null, ["linear"]);
			mov(sub2([F([1]),map.x,map.y,map.z]),null,map.w);
			var flags:Array = ["repeat"];
			var diffColor0:Var = tex(scaledUV, FS(1),null,flags);
			var diffColor1:Var = tex(scaledUV, FS(2),null,flags);
			var diffColor2:Var = tex(scaledUV, FS(3),null,flags);
			var diffColor3:Var = tex(scaledUV, FS(4), null, ["repeat"]);
			var diffColor:Var=
						add2([
							mul(diffColor0,map.x),
							mul(diffColor1,map.y),
							mul(diffColor2,map.z),
							mul(diffColor3,map.w)
						]);
			mov(F([1]),null,diffColor.w);//diffColor.w = 1;
			return diffColor;
		}
	}

}