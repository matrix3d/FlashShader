package gl3d.core 
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import gl3d.core.renders.GL;
	import gl3d.shaders.PhongVertexShader;
	/**
	 * ...
	 * @author lizhi
	 */
	public class InstanceMaterial extends Material
	{
		public function InstanceMaterial() 
		{
			
		}
		
		override public function draw(node:Node3D, view:View3D):void 
		{
			var context:GL = view.renderer.gl3d;
			var pvs:PhongVertexShader = (node.copyfrom.material as Material).shader.vs as PhongVertexShader
			if(pvs){
				context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, pvs.model.index, node.world, true);
				if (normalMapAble) {
					context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, pvs.world2local.index, node.world2local, true);
				}
				
				node = node.copyfrom || node;
				if (wireframeAble) {
					context.drawTriangles(node.drawable.unpackedDrawable.index,0,-1,false);
				}else {
					context.drawTriangles(node.drawable.index,0,-1,false);
				}
			}
		}
		
	}

}