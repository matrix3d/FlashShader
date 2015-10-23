package gl3d.parser.hlbsp 
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.core.View3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class BspRenderNode extends Node3D
	{
		public var bsp:Bsp;
		public var view:View3D;
		public var render:BspRender;
		public function BspRenderNode(b:ByteArray,view:View3D) 
		{
			this.view = view;
			bsp=new Bsp;
			bsp.loadBSP(b);
			render = new BspRender(this);
			render.preRender();
			
			//addChild(render.target);
		}
		
		override public function update(view:View3D, material:Material = null):void  
		{
			world.copyFrom(matrix);
			if (parent) {
				world.append(parent.world);
			}
			var campos:Vector3D = view.camera.matrix.position;
			//world --> model
			var model:Matrix3D = world.clone();
			model.invert();
			render.render(model.transformVector(campos));
		}
	}

}