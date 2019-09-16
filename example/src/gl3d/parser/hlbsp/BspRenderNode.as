package gl3d.parser.hlbsp 
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import gl3d.core.Material;
	import gl3d.core.MaterialBase;
	import gl3d.core.Node3D;
	import gl3d.core.View3D;
	import gl3d.ctrl.Ctrl;
	/**
	 * ...
	 * @author lizhi
	 */
	public class BspRenderNode extends Node3D
	{
		private var culling:Boolean;
		public var bsp:Bsp;
		public var view:View3D;
		public var render:BspRender;
		public function BspRenderNode(b:ByteArray,view:View3D,culling:Boolean=true) 
		{
			this.culling = culling;
			this.view = view;
			bsp=new Bsp;
			if(bsp.loadBSP(b)){
				render = new BspRender(this);
				render.preRender();
				if(culling){
					controllers = new Vector.<Ctrl>();
				}else{
					addChild(render.renderAll());
				}
			}
			
		}
		override public function update(view:View3D, material:MaterialBase = null):void  
		{
			if (!culling) return;
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