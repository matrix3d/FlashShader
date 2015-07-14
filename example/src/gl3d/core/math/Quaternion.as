package gl3d.core.math{
	import flash.geom.Matrix3D;
	import flash.geom.Orientation3D;
	import flash.geom.Vector3D;

	/**
	 * ...
	 * @author lizhi
	 */
	public class Quaternion extends Vector3D
	{
		private static var HELP_VEC:Vector.<Vector3D> = new <Vector3D>[new Vector3D(), new Vector3D(), new Vector3D(1, 1, 1)];
		private static var HELP_MATRIX:Matrix3D = new Matrix3D();
		public var tran:Vector3D = new Vector3D;
		public function Quaternion(x:Number=0,y:Number=0,z:Number=0,w:Number=0) 
		{
			super(x, y, z, w);
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
		
		//http://molecularmusings.wordpress.com/2013/05/24/a-faster-quaternion-vector-multiplication/
        //t = 2 * cross(q.xyz, v)
        //v' = v + q.w * t + cross(q.xyz, t)
        public function rotatePoint2(vector:Vector3D):Vector3D {
            var t:Vector3D = cross(this, vector);
            t.scaleBy(2);
            var t2:Vector3D = t.clone();
            t2.scaleBy(w);
            return vector.add(t2).add(cross(this,t));
        }
		
		public function fromMatrix(matrix:Matrix3D):void
		{
			var temp:Vector.<Vector3D> = matrix.decompose(Orientation3D.QUATERNION);
			copyFrom(temp[1]);
			w = temp[1].w;
			tran.copyFrom(temp[0]);
		}
		
		public function fromAxisAngle(axis:Vector3D, angle:Number):void {
			var sin:Number = Math.sin(angle / 2);
			setTo(axis.x * sin, axis.y * sin, axis.z * sin);
			w = Math.cos(angle / 2);
		}
		
		public function toMatrix(matr:Matrix3D=null):Matrix3D {
			if (matr == null) matr = new Matrix3D();
			HELP_VEC[1] = this;
			matr.recompose(HELP_VEC,Orientation3D.QUATERNION);
			return matr;
		}
		
		public function cloneQuaternion():Quaternion {
			return new Quaternion(x, y, z, w);
		}
		
		public static function cross(v1:Vector3D, v2:Vector3D):Vector3D {
			return new Vector3D(
			v1.y * v2.z - v1.z * v2.y,
			v1.z * v2.x - v1.x * v2.z,
			v1.x * v2.y - v1.y * v2.x
			);
		}
		
		override public function toString():String {
			return "Quaternion(" +x+","+y+","+z+","+w+ ")";
		}
	}
}