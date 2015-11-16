package 
{
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.display3D.Context3DTriangleFace;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
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
		private var curve:Node3D;
		private var p0:Sprite;
		private var c:Sprite;
		private var p1:Sprite;
		public function TestCurve() 
		{
			
		}
		
		override public function initNode():void 
		{
			addSky();
			
			curve = new Node3D();
			curve.material = new Material;
			curve.material.shader = new CurveShader;
			curve.material.culling = Context3DTriangleFace.NONE;
			curve.material.blendModel = BlendMode.LAYER;
			curve.drawable = Meshs.createDrawable(new <uint>[0,1,2],new <Number>[0,0,0,0,0,0,0,0,0],new <Number>[0,0,.5,0,1,1]);
			
			view.scene.addChild(curve);
			p0=addPoint(100, 100);
			c=addPoint(400, 100);
			p1=addPoint(500, 500);
			
			stats.visible = false;
		}
		
		private function addPoint(x:Number, y:Number):Sprite {
			var s:Sprite = new Sprite;
			s.graphics.beginFill(0xff0000);
			s.graphics.lineStyle(0);
			s.graphics.drawCircle(0, 0, 10);
			addChild(s);
			s.x = x;
			s.y = y;
			s.buttonMode = true;
			s.addEventListener(MouseEvent.MOUSE_DOWN, s_mouseDown);
			return s;
		}
		
		private function s_mouseDown(e:MouseEvent):void 
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUp);
			var s:Sprite = e.currentTarget as Sprite;
			s.startDrag();
		}
		
		private function stage_mouseUp(e:MouseEvent):void 
		{
			stopDrag();
		}
		
		private function d2d3(s:Sprite):Point {
			return new Point(s.x/view.stage3dWidth*2-1,1-s.y/view.stage3dHeight*2);
		}
		
		override public function enterFrame(e:Event):void 
		{
			curve.drawable.pos.data[0] = d2d3(p0).x;
			curve.drawable.pos.data[1] = d2d3(p0).y;
			curve.drawable.pos.data[3] = d2d3(c).x;
			curve.drawable.pos.data[4] = d2d3(c).y;
			curve.drawable.pos.data[6] = d2d3(p1).x;
			curve.drawable.pos.data[7] = d2d3(p1).y;
			curve.drawable.pos.invalid = true;
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
	public function CurveShader() 
	{
		debug = true;
	}
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
		
		oc = vec4(1,1,1,alpha);
	}
}

class CurveVShader extends GLAS3Shader {
	public var uv:Var;
	public function CurveVShader() 
	{
		super(Context3DProgramType.VERTEX);
		op = buffPos();//m44(m44(m44(buffPos(), uniformModel()), uniformView()), uniformPerspective());
		uv = varying();
		mov(buffUV(), uv);
	}
}

