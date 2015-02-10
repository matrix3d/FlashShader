package gl3d.q3bsp.collision 
{
	import flash.geom.Vector3D;
	import parser.Q3BSP.Q3BSPPlane;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Q3BSPCollisionData 
	{
		public var type:int;
        public var ratio:Number;
        public var collisionPoint:Vector3D;
        public var startOutside:Boolean;
        public var inSolid:Boolean;
        public var startPosition:Vector3D;
        public var endPosition:Vector3D;
        public var sphereRadius:Number;
        public var boxMinimums:Vector3D;
        public var boxMaximums:Vector3D;
        public var boxExtents:Vector3D;
		public var plane:Q3BSPPlane;
		public function Q3BSPCollisionData() 
		{
			
		}
		
	}

}