package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash3d.Node3D;
	import flash3d.View3D;
	import gl3d.meshs.Meshs;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestFlash3D extends Sprite
	{
		private var v3d:View3D;
		private var node:Node3D;
		
		public function TestFlash3D() 
		{
			v3d = new View3D;
			node = Node3D.fromDrawable(Meshs.cube(2,2,2));
			v3d.nodes.push(node);
			addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		private function enterFrame(e:Event):void 
		{
			node.rot.y += .1;
			v3d.render(graphics);
		}
		
	}

}