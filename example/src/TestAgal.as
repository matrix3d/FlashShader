package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.core.View3D;
	import gl3d.meshs.Meshs;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestAgal extends Sprite
	{
		private var view1:View3D;
		
		public function TestAgal() 
		{
			view1 = new View3D(0);
			view1.stage3dWidth = view1.stage3dHeight = 400;
			addChild(view1);
			addEventListener(Event.ENTER_FRAME, enterFrame);
			
			var n1:Node3D = new Node3D;
			n1.drawable = Meshs.cube(1,1,1);
			n1.material = new Material(new AGALShader1);
			n1.material.lightAble = false;
			//n1.material = new Material;
			view1.scene.addChild(n1);
			view1.camera.perspective.perspectiveFieldOfViewLH(Math.PI / 4, view1.stage3dWidth/ view1.stage3dHeight, .1, 4000);
			view1.camera.z = -10;
			//view1.lights[0].z = -1000;
			view1.scene.addChild(n1);
		}
		
		private function enterFrame(e:Event):void 
		{
			view1.render();
		}
		
	}

}
import flash.display3D.Context3DProgramType;
import gl3d.core.Material;
import gl3d.core.renders.GL;
import gl3d.shaders.AGALShader;



class AGALShader1 extends AGALShader {
	public function AGALShader1() 
	{
		super("m44 vt0,va0,vc0\nm44 vt0,vt0,vc4\nm44 op,vt0,vc8",
		"mov oc fc0");
	}
	
	override public function update(material:Material):void 
	{
		var gl:GL = material.view.renderer.gl3d;
		material.node.drawable.pos.update(gl);
		material.node.drawable.pos.bind(gl, 0);
		gl.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, material.node.world, true);
		gl.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 4, material.camera.world2local, true);
		gl.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 8, material.camera.perspective, true);
		gl.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, new <Number>[1,0,1,1]);
		super.update(material);
	}
}