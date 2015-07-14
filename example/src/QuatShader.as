package 
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import gl3d.core.Material;
	import gl3d.core.math.Quaternion;
	import gl3d.core.Quat;
	import gl3d.core.shaders.GLAS3Shader;
	import gl3d.core.shaders.GLShader;
	import gl3d.core.skin.Skin;
	/**
	 * ...
	 * @author lizhi
	 */
	public class QuatShader extends GLShader
	{
		private var skin:Skin;
		public function QuatShader(skin:Skin) 
		{
			this.skin = skin;	
		}
		
		override public function getFragmentShader(material:Material):GLAS3Shader 
		{
			return new FShader(vs as VShader);
		}
		
		override public function getVertexShader(material:Material):GLAS3Shader 
		{
			return new VShader(skin)
		}
	}

}
import as3Shader.Var;
import flash.display3D.Context3DProgramType;
import gl3d.core.shaders.GLAS3Shader;
import gl3d.core.skin.Skin;

class FShader extends GLAS3Shader {
	private var vs:VShader;
	public function FShader(vs:VShader) 
	{
		super(Context3DProgramType.FRAGMENT);
		this.vs = vs;
		mov(vs.norm, oc);
	}
}

class VShader extends GLAS3Shader {
	public var quat:Var;
	public var norm:Var;
	public function VShader(skin:Skin) 
	{
		super(Context3DProgramType.VERTEX);
		
		var joints:Var = uniformJointsMatrix(skin.joints.length);
		var xyzw:String = "xyzw";
		var buffJoint:Var = buffJoints();
		var buffWeight:Var = buffWeights();
		var buffPos:Var = buffPos();
		debug("start sk");
		for (var i:int = 0; i < skin.maxWeight; i++ ) {
			var c:String = xyzw.charAt(i % 4);
			var joint:Var = buffJoint.c(c);
			if (skin.useQuat) {
				var value:Var = mul(buffWeight.c(c), q44(buffPos, mov(joints.c(joint)),mov(joints.c(joint,1))));
			}else {
				value = mul(buffWeight.c(c), m44(buffPos, joints.c(joint)));
			}
			
			if (i==0) {
				var result:Var = value;
			}else {
				result = add(result, value);
			}
		}
		debug("end sk");
		
		op = m44(m44(m44(result, uniformModel()), uniformView()), uniformPerspective());
		
		norm = varying();
		mov(buffNorm(), norm);
	}
	
	public function q44(pos:Var, quas:Var, tran:Object):Var {
		var temp:Var = add(q33(pos, quas), tran);
		mov(1, temp.w);
		return temp.xyzw;
	}
	
	public function q33(pos:Var, quas:Var):Var {
		var t:Var = mul(2 , crs(quas, pos));
		return add2([pos , mul(quas.w , t) , crs(quas, t)]);
	}
}