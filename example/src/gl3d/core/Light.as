package gl3d.core {
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Light extends Node3D
	{
		public static const AMBIENT:int = 0;
		public static const DISTANT:int = 1;
		public static const POINT:int = 2;
		public static const SPOT:int = 3;
		public var lightType:int;
		public var color:Vector3D = new Vector3D(1, 1, 1, 1);
		public var shadowMapEnabled:Boolean = false;
		public var shadowMapSize:int = 1024;
		public var distance:Number = 10;
		public var innerConeAngle:Number = 3.14 / 6;
		public var outerConeAngle:Number = 3.14 / 3;
		public function Light(lightType:int=DISTANT,name:String="light") 
		{
			this.lightType = lightType;
			super(name);
		}
		
	}

}