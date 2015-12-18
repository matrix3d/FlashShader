package gl3d.core.math{
	import flash.geom.Matrix3D;
	import flash.geom.Orientation3D;
	import flash.geom.Vector3D;
	import gl3d.util.Matrix3DUtils;

	/**
	 * ...
	 * @author lizhi
	 */
	public class Quaternion extends Vector3D
	{
		public var tran:Vector3D = new Vector3D(0, 0, 0, 1);
		public var scale:Vector3D = new Vector3D(1, 1, 1);
		private var vec:Vector.<Vector3D> = new Vector.<Vector3D>;
		public function Quaternion(x:Number=0,y:Number=0,z:Number=0,w:Number=1) 
		{
			super(x, y, z, w);
			vec.push(tran);
			vec.push(this);
			vec.push(scale);
		}
		
		public function computeW ():void{
			var t:Number = 1 - lengthSquared;
			w = t < 0?0: -Math.sqrt(t);
		}
		
		public function rotatePoint(vector:Vector3D,target:Vector3D=null):Vector3D {
			if (target == null) target = new Vector3D();
			var x2:Number = vector.x;
			var y2:Number = vector.y;
			var z2:Number = vector.z;
			var w1:Number = -x*x2 - y*y2 - z*z2;
			var x1:Number = w*x2 + y*z2 - z*y2;
			var y1:Number = w*y2 - x*z2 + z*x2;
			var z1:Number = w*z2 + x*y2 - y*x2;
			
			target.x = -w1*x + x1*w - y1*z + z1*y;
			target.y = -w1*y + x1*z + y1*w - z1*x;
			target.z = -w1*z - x1*y + y1*x + z1*w;
			
			return target;
		}
		
		public function fromMatrix(matrix:Matrix3D):void
		{
			Matrix3DUtils.decompose(matrix,Orientation3D.QUATERNION,vec);
		}
		
		public function fromAxisAngle(axis:Vector3D, angle:Number):void {
			var sin:Number = Math.sin(angle / 2);
			setTo(axis.x * sin, axis.y * sin, axis.z * sin);
			w = Math.cos(angle / 2);
		}
		
		public function toMatrix(matr:Matrix3D=null):Matrix3D {
			if (matr == null) matr = new Matrix3D();
			matr.recompose(vec, Orientation3D.QUATERNION);
			return matr;
		}
		
		public function cloneQuaternion():Quaternion {
			var q:Quaternion = new Quaternion(x, y, z, w);
			q.tran.copyFrom(tran);
			q.scale.copyFrom(scale);
			return q;
		}
		
		public function lerpTo(q:Quaternion, num:Number):void
        {
			if (num==-Infinity) {
				
			}else if (num==Infinity) {
				x = q.x;
				y = q.y;
				z = q.z;
				w = q.w;
				tran.x = q.tran.x;
				tran.y = q.tran.y;
				tran.z = q.tran.z;
				tran.w = q.tran.w;
				scale.x = q.scale.x;
				scale.y = q.scale.y;
				scale.z = q.scale.z;
			}else{
				var num2:Number = 1 - num;
				if ((x * q.x + y * q.y + z * q.z + w * q.w) >= 0)
				{
					x = num2 * x + num * q.x;
					y = num2 * y + num * q.y;
					z = num2 * z + num * q.z;
					w = num2 * w + num * q.w;
				}
				else
				{
					x = num2 * x - num * q.x;
					y = num2 * y - num * q.y;
					z = num2 * z - num * q.z;
					w = num2 * w - num * q.w;
				}
				
				var num4:Number = x * x + y * y + z * z + w * w;
				var num3:Number = 1 / Math.sqrt(num4);
				x *= num3;
				y *= num3;
				z *= num3;
				w *= num3;
				
				scale.x = num2 * scale.x + num * q.scale.x;
				scale.y = num2 * scale.y + num * q.scale.y;
				scale.z = num2 * scale.z + num * q.scale.z;
				
				tran.x = num2 * tran.x + num * q.tran.x;
				tran.y = num2 * tran.y + num * q.tran.y;
				tran.z = num2 * tran.z + num * q.tran.z;
				tran.w = num2 * tran.w + num * q.tran.w;
			}
        }
		
		override public function toString():String {
			return "Quaternion(" +x+","+y+","+z+","+w+ ")";
		}
	}
}