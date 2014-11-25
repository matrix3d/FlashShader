package gl3d.core {
	import com.adobe.utils.PerspectiveMatrix3D;
	import flash.display3D.Context3D;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Camera3D extends Node3D
	{
		public var perspective:PerspectiveMatrix3D = new PerspectiveMatrix3D;
		public var view:Matrix3D = new Matrix3D;
		public function Camera3D(name:String=null ) 
		{
			super(name);
		}
		
		override public function update(v:View3D):void {
			super.update(v);
			view.copyFrom(world);
			view.invert();
		}
		
		public function computePickRayDirectionMouse( mouseX:Number, mouseY:Number,viewWidth:Number,viewHeight:Number ,rayOrigin:Vector3D, rayDirection:Vector3D, pixelPos:Vector3D=null ):void
		{
			var x:Number =  (mouseX - viewWidth *.5) / viewWidth *2;
			var y:Number = -(mouseY - viewHeight * .5) / viewHeight * 2;
			return computePickRayDirection(x, y, rayOrigin, rayDirection, pixelPos);
		}
		
		public function computePickRayDirection( x:Number, y:Number, rayOrigin:Vector3D, rayDirection:Vector3D, pixelPos:Vector3D=null ):void
		{
			// unproject
			// screen -> camera -> world
			
			var prjPos:Vector3D=new Vector3D( x, y, 0 ); // clip space
			var unprjMatrix:Matrix3D = view.clone();
			unprjMatrix.append(perspective);
			unprjMatrix.invert();
			
			// screen -> camera -> world
			var pos:Vector3D = unprjMatrix.transformVector(prjPos);
			
			
			if ( pixelPos!=null )
				pixelPos.setTo( pos.x, pos.y, pos.z );
			
			rayOrigin.setTo( this.x, this.y, this.z );
			
			// compute ray
			rayDirection.setTo(	pos.x - this.x,
				pos.y - this.y,
				pos.z - this.z );
			rayDirection.normalize();
		}
		
	}

}