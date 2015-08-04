package gl3d.core.renders 
{
	import gl3d.core.Node3D;
	import gl3d.core.Camera3D;
	import gl3d.core.View3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class GraphicsRender extends Render
	{
		
		public function GraphicsRender(view:View3D) 
		{
			super(view);
			gl3d = new GraphicsGL;
		}
		
		override public function render(camera:Camera3D, scene:Node3D):void 
		{
			super.render(camera, scene);
			collects.length = 0;
			view.drawTriangleCounter = 0;
			view.drawCounter = 0;
			collect(scene);
			for each(var node:Node3D in collects) {
				node.update(view);
			}
		}
		
	}

}