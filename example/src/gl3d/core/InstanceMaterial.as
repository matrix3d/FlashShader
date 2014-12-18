package gl3d.core 
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
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
			var context:Context3D = view.context;
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, node.world, true);
			context.drawTriangles(node.drawable.index.buff);
		}
		
	}

}