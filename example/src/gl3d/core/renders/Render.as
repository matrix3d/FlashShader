package gl3d.core.renders 
{
	import gl3d.core.Camera3D;
	import gl3d.core.renders.GL;
	import gl3d.core.Node3D;
	import gl3d.core.TextureSet;
	import gl3d.core.View3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Render 
	{
		public var gl3d:GL;
		public var view:View3D;
		public var agalVersion:int;
		public var collects:Vector.<Node3D> = new Vector.<Node3D>;
		public function Render(view:View3D) 
		{
			this.view = view;
			
		}
		
		public function init():void {
			
		}
		
		public function render(camera:Camera3D,scene:Node3D):void {
			
		}
		
		public function collect(node:Node3D):void {
			collects.push(node);
			if (node.drawable) {
				view.drawTriangleCounter += node.drawable.index.data.length / 3;
				view.drawCounter++;
			}
			for each(var c:Node3D in node.children) {
				collect(c);
			}
		}
		
		public function sort():void {
			//collects.sort(sortFun);
		}
	}

}