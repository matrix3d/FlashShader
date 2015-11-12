package 
{
	import flash.display3D.Context3DTriangleFace;
	import flash.events.Event;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.core.shaders.GLShader;
	import gl3d.meshs.Meshs;
	/**
	 * http://http.developer.nvidia.com/GPUGems3/gpugems3_ch25.html
	 * @author lizhi
	 */
	public class TestCurve extends BaseExample
	{
		private var cube:Node3D;
		private var size:Number=2;
		private var ctrl:Node3D;
		
		public function TestCurve() 
		{
			
		}
		
		override public function initNode():void 
		{
			cube = new Node3D();
			cube.material = new Material;
			cube.material.shader = new CurveShader;
			cube.material.culling = Context3DTriangleFace.NONE;
			cube.drawable = Meshs.createDrawable(new <uint>[0,1,2],new <Number>[size,-size,0,size,size,0,-size,size,0],new <Number>[0,0,.5,0,1,1]);
			
			view.scene.addChild(cube);
			
			ctrl = new Node3D;
			ctrl.material = new Material;
			ctrl.drawable = Meshs.cube(.1, .1, .1);
			view.scene.addChild(ctrl);
		}
		
		override public function enterFrame(e:Event):void 
		{
			var x:Number=Math.sin(view.time/400)*size;
			var y:Number=Math.sin(view.time/600)*size;
			cube.drawable.pos.data[3] =ctrl.x= x;
			cube.drawable.pos.data[4] =ctrl.y= y;
			cube.drawable.pos.invalid = true;
			super.enterFrame(e);
		}
	}

}
import as3Shader.Var;
import flash.display3D.Context3DProgramType;
import gl3d.core.Material;
import gl3d.core.shaders.GLAS3Shader;
import gl3d.core.shaders.GLShader;

class CurveShader extends GLShader {
	override public function getFragmentShader(material:Material):GLAS3Shader 
	{
		return new CurveFShader(vs as CurveVShader);
	}
	
	override public function getVertexShader(material:Material):GLAS3Shader 
	{
		return new CurveVShader;
	}
}

class CurveFShader extends GLAS3Shader {
	public function CurveFShader(vshader:CurveVShader) 
	{
		super(Context3DProgramType.FRAGMENT);
		
		var p:Var = vshader.uv.xy;
		
		// Gradients
		var px:Var = ddx(p);
		var py:Var = ddy(p);
		
		// Chain rule
		var fx:Var = sub(mul2([2 , p.x,  px.x]) , px.y);
		var fy:Var = sub(mul2([2 , p.x,  py.x]) , py.y);
		
		// Signed distance
		var sd:Var = div(sub(mul(p.x , p.x) , p.y) , sqt(add(mul(fx , fx) , mul(fy , fy))));
		
		// Linear alpha
		var alpha:Var = sub(0.5 , sd);
		kil(alpha.x);
		
		alpha=sat(alpha);
		
		oc = alpha;
	}
}

class CurveVShader extends GLAS3Shader {
	public var uv:Var;
	public function CurveVShader() 
	{
		super(Context3DProgramType.VERTEX);
		op = m44(m44(m44(buffPos(), uniformModel()), uniformView()), uniformPerspective());
		uv = varying();
		mov(buffUV(), uv);
	}
}

