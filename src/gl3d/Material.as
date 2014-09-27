package gl3d 
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.geom.Vector3D;
	import flShader.FlShader;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Material 
	{
		public var textureSet:TextureSet;
		public var programSet:ProgramSet;
		public var color:Vector.<Number> = Vector.<Number>([1,1,1,1]);
		public function Material() 
		{
			var vs:FlShader = new VShader;
			var fs:FlShader = new FShader;
			trace(vs.code);
			programSet = new ProgramSet(vs.code, fs.code);
		}
		
		public function draw(node:Node3D,camera:Camera3D,view:View3D):void {
			if (node.drawable) {
				var context:Context3D = view.context;
				node.drawable.update(context);
				if (textureSet) {
					textureSet.update(context);
				}
				if (programSet) {
					programSet.update(context);
					context.setProgram(programSet.program);
					
					context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, node.world, true);
					context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 4, camera.view, true);
					context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 8, camera.perspective, true);
					var lightPos:Vector3D = view.light.world.position;
					context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 12, Vector.<Number>([lightPos.x,lightPos.y,lightPos.z,1]));//light pos
					
					context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0,color);//color
					context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1,view.light.color);//light color
					context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2,view.light.ambient);//ambient color 环境光
					context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3,Vector.<Number>([view.light.specularPower,2,0,0]));//x:specular pow, y:2
					
					node.drawable.pos.bind(context, 0);
					node.drawable.norm.bind(context, 1);
					
					context.drawTriangles(node.drawable.index.buff);
				}
			}
		}
		
	}
}

import flash.display3D.Context3DProgramType;
import flShader.FlShader;
import flShader.Var;

class VShader extends FlShader {
	public function VShader() 
	{
		super(Context3DProgramType.VERTEX);
		var model:Var = C();
		var view:Var = C(4);
		var perspective:Var = C(8);
		var lightPos:Var = mov(C(12));
		var pos:Var = VA();
		var norm:Var = VA(1);
		var worldPos:Var = m44(pos, model);
		var viewPos:Var = m44(worldPos, view);
		m44(viewPos, perspective, op);
		
		var eyeDirection:Var = neg(viewPos, null);
		mov(eyeDirection, null, V(2));
		var viewPosLight:Var = add(m44(lightPos, view),eyeDirection,V());
		var viewNormal:Var = m33(norm, model);
		mov(viewNormal, null, V(1));
		
	}
}

class FShader extends FlShader {
	public function FShader() 
	{
		super(Context3DProgramType.FRAGMENT);
		var diffColor:Var = C();
		var lightColor:Var = C(1);
		var lightPower:Var = lightColor.w;
		var ambientColor:Var = C(2);
		var specularPow:Var = C(3).x;
		
		var n:Var = nrm(V(1));
		var l:Var = nrm(V());
		var cosTheta:Var = sat(dp3(n,l));
		
		var e:Var = nrm(V(2));
		var r:Var = nrm(sub(mul(mul(C(3).y, dp3(l, n)), n), l));
		var cosAlpha:Var = sat(dp3(e,r));
		
		var color:Var =add(ambientColor, mul(mul(mov(lightColor), add(cosTheta,pow(cosAlpha,specularPow))), lightPower));
		mul(color, diffColor, oc);
	}
}