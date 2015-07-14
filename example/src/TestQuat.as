package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import gl3d.core.Node3D;
	import gl3d.core.Quat;
	import gl3d.core.View3D;
	import gl3d.parser.DAEParser;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestQuat extends BaseExample
	{
		public function TestQuat() 
		{
		}
		
		override public function initNode():void 
		{
			super.initNode();
			teapot.y = -3;
			//teapot.material.shader = new  QuatShader();
			teapot.parent.removeChild(teapot);
			
			//skybox.parent.removeChild(skybox);
			
			[Embed(source = "assets/astroBoy_walk_Max.dae", mimeType = "application/octet-stream")]var c:Class;
			var b:ByteArray = new c as ByteArray;
			var p:DAEParser = new DAEParser;
			p.load(null, b);
			view.scene.addChild(p.root);
			p.root.scaleX = p.root.scaleY = p.root.scaleZ = 0.5;
			p.root.setRotation( -90, 180, 0);
			p.root.y = -1.5;
			
			trace(p.root.children[0].children[0].children[1].material);
			var boy:Node3D = p.root.children[0].children[0].children[1];
			boy.material.shader = new QuatShader(boy.skin);
		}
		
	}

}