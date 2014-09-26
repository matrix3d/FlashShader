package gl3d 
{
	import com.adobe.utils.PerspectiveMatrix3D;
	import flash.display3D.Context3D;
	import flash.geom.Matrix3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Camera3D extends Node3D
	{
		public var perspective:PerspectiveMatrix3D = new PerspectiveMatrix3D;
		public var view:Matrix3D = new Matrix3D;
		public function Camera3D() 
		{
			
		}
		
		override public function update(v:View3D,camera:Camera3D):void {
			super.update(v, camera);
			view.copyFrom(world);
			view.invert();
		}
		
	}

}