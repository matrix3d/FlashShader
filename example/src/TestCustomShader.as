package 
{
	import as3Shader.Var;
	import flash.display.Sprite;
	import flash.display3D.Context3DProgramType;
	import flash.events.Event;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.core.View3D;
	import gl3d.core.shaders.GLAS3Shader;
	import gl3d.core.shaders.GLShader;
	import gl3d.meshs.Meshs;
	import gl3d.shaders.PhongFragmentShader;
	import gl3d.shaders.PhongVertexShader;
	import gl3d.util.HFloat;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestCustomShader extends Sprite
	{
		private var view1:View3D;
		
		public function TestCustomShader() 
		{
			view1 = new View3D(0);
			view1.stage3dWidth = view1.stage3dHeight = 400;
			addChild(view1);
			addEventListener(Event.ENTER_FRAME, enterFrame);
			
			var n1:Node3D = new Node3D;
			var shader:GLShader = new GLShader;
			n1.material = new Material(shader);
			n1.drawable = Meshs.cube(1, 1, 1);
			
			///////////////////////////////////////////
			var vs:GLAS3Shader = new GLAS3Shader();
			var pos:Var = vs.buffPos();
			var m:Var = vs.uniformModel();
			var v:Var = vs.uniformView();
			var p:Var = vs.uniformPerspective();
			vs.op = vs.m44(vs.m44(vs.m44(pos,m),v),p);
			
			var fs:GLAS3Shader = new GLAS3Shader(Context3DProgramType.FRAGMENT);
			fs.oc =
			fs.div(
			fs.half2float2(fs.mov(HFloat.toHalfFloat2(.001, .001)))[0]
			,.002);
			//fs.mov([1, 0, 1, 1]);
			///////////////////////////////////////////
			
			shader.vs = vs;
			shader.fs = fs;
			view1.scene.addChild(n1);
			view1.camera.perspectiveFieldOfViewLH(Math.PI / 4, view1.stage3dWidth/ view1.stage3dHeight, .1, 4000);
			view1.camera.z = -10;
			view1.scene.addChild(n1);
		}
		
		private function enterFrame(e:Event):void 
		{
			view1.render();
		}
		
	}

}
