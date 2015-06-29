package gl3d.shaders.posts 
{
	import flash.display3D.Context3DProgramType;
	import as3Shader.AS3Shader;
	import as3Shader.Var;
	import gl3d.core.shaders.GLAS3Shader;
	/**
	 * ...
	 * @author lizhi
	 */
	public class ShapeShader  extends GLAS3Shader
	{
		
		public function ShapeShader() 
		{
			super(Context3DProgramType.FRAGMENT);
			var outsideColor:Number = 0;
			var insideColor:Number = 1;
			var resolution:Var = mov(C().yz);
			
			var uv:Var = V();
			var cen:Array = [.5, .5];
			var dist:Var = sub(uv, cen);
			mul(dist.x, div(resolution.x, resolution.y), dist.x);
			dist = mul(dist, dist);
			dist = sqt(add(dist.x, dist.y).x);
			var distFromEdge:Var = sub(.2 , dist);
			
			var thresholdWidth:Var = fwidth(distFromEdge);
			
			var antialiasedCircle:Var = sat(add(div(distFromEdge , thresholdWidth) , 0.5));
			oc = mix(outsideColor, mov(insideColor), antialiasedCircle);
		}
		
	}

}