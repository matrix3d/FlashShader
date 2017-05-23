package gl3d.core.renders 
{
	import gl3d.core.Camera3D;
	import gl3d.core.Light;
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
		public var agalVersion:int = 2;
		public var collects:Vector.<Node3D> = new Vector.<Node3D>;
		//public var lights:Vector.<Light> = new Vector.<Light>;
		private var _visible:Boolean = true;
		private var endScissorRectangle
		public function Render(view:View3D) 
		{
			this.view = view;
			
		}
		
		public function init():void {
			
		}
		
		public function render(camera:Camera3D,scene:Node3D):void {
			
		}
		
		public function collect(node:Node3D):void {
			if (node.visible){
				if(node.material||node.controllers){
					collects.push(node);
				}
				if (node is Light) {
					view.lights.push(node);
				}
				for each(var c:Node3D in node.children) {
					collect(c);
				}
			}
		}
		
		public function sort():void {
			//collects.sort(sortFun);
		}
		public function get visible():Boolean 
		{
			return _visible;
		}
		
		public function set visible(value:Boolean):void 
		{
			_visible = value;
		}
	}

}