package  
{
	import flash.events.Event;
	import gl3d.ctrl.FirstPersonCtrl;
	import gl3d.Material;
	import gl3d.meshs.Meshs;
	import gl3d.Node3D;
	import gl3d.shaders.GLShader;
	import gl3d.shaders.particle.ParticleGLShader;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Test extends BaseExample
	{
		private var teapot:Node3D;
		
		public function Test() 
		{
			
		}
		
		override public function initNode():void {
			view.camera.z = 0;
			view.camera.y = 10;
			view.camera.rotationX=Math.PI/2
			
			teapot = new Node3D;
			teapot.material = new Material;
			teapot.material.shader = new ParticleGLShader;
			teapot.drawable = Meshs.teapot(6);
			view.scene.addChild(teapot);
			teapot.scaleX = teapot.scaleY = teapot.scaleZ = 0.3;
		}
		
		override public function initUI():void {
		}
		override public function initCtrl():void {
		}
		
		override public function enterFrame(e:Event):void
		{
			var r:Number = Math.atan2(mouseY - stage.stageHeight / 2, mouseX - stage.stageWidth / 2);
			teapot.rotationY = r;
			super.enterFrame(e);
		}
	}

}