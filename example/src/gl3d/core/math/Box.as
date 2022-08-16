package gl3d.core.math 
{
	import Vector;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Box 
	{
		public var vec:Vector.<Number>;
		private static var tempPos:Vector3D = new Vector3D;
		public function Box() 
		{
			reset();
		}
		
		public function reset():void{
			vec = new <Number>[int.MAX_VALUE,int.MAX_VALUE,int.MAX_VALUE,int.MIN_VALUE,int.MIN_VALUE,int.MIN_VALUE];
		}
		
		public function doTransform(m:Matrix3D,out:Box):void{
			//6个顶点
			for ( var i:uint = 0; i < 8; i++ )
			{
				//trace( 0 + !!(i & 1),2 + !!(i & 2),4 + ! !(i & 4));
				tempPos.x = vec[ 0 + !!(i & 1)];
				tempPos.y = vec[ 2 + !!(i & 2)];
				tempPos.z = vec[ 4 + ! !(i & 4)];
				tempPos= m.transformVector(tempPos);
				out.intersectionPos(tempPos.x,tempPos.y,tempPos.z);
			}
		}
		
		public function intersectionPos(x:Number,y:Number,z:Number):void
		{
			if (vec[0]>x){
				vec[0] =x;
			}
			if (vec[1]>y){
				vec[1] = y;
			}
			if (vec[2]>z){
				vec[2] = z;
			}
			
			if (vec[3]<x){
				vec[3] = x;
			}
			if (vec[4]<y){
				vec[4] = y;
			}
			if (vec[5]<z){
				vec[5] = z;
			}
		}
		
		public function intersection(toIntersect:Box):void
		{
			if (vec[0]>toIntersect.vec[0]){
				vec[0] = toIntersect.vec[0];
			}
			if (vec[1]>toIntersect.vec[1]){
				vec[1] = toIntersect.vec[1];
			}
			if (vec[2]>toIntersect.vec[2]){
				vec[2] = toIntersect.vec[2];
			}
			
			if (vec[3]<toIntersect.vec[3]){
				vec[3] = toIntersect.vec[3];
			}
			if (vec[4]<toIntersect.vec[4]){
				vec[4] = toIntersect.vec[4];
			}
			if (vec[5]<toIntersect.vec[5]){
				vec[5] = toIntersect.vec[5];
			}
		}
		
		public function toString():String{
			return vec + " size:" + (vec[3] - vec[0]) + "," + (vec[4] - vec[1]) + "," + (vec[5] - vec[2]);
		}
	}

}