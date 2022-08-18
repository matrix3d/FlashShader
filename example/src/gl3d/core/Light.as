package gl3d.core {
	import flash.geom.Vector3D;
	import gl3d.util.Matrix3DUtils;
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
		public var shadowMap:TextureSet = new TextureSet(null, false, false, true, false, false, null);
		public var shadowDistance:Number = 5;
		private var _shadowCamera:Camera3D = new Camera3D;
		public var distance:Number = 10;
		public var innerConeAngle:Number = Math.PI / 6;
		public var outerConeAngle:Number = Math.PI / 3;
		public function Light(lightType:int=1,name:String="light") 
		{
			this.lightType = lightType;
			super(name);
			
			switch(lightType){
				case DISTANT:
					_shadowCamera = new Camera3D;
					//_shadowCamera.perspective.
					break;
				case POINT:
					break;
				case SPOT:
					break;
			}
		}
		
		override public function dispose():void 
		{
			super.dispose();
			if (shadowMap&&shadowMap.texture) {
				shadowMap.texture.dispose();
			}
		}
		
		public function get shadowCamera():Camera3D 
		{
			//_shadowCamera.matrix.position = new Vector3D(.000001);
			//_shadowCamera.matrix.pointAt(new Vector3D(x, y, z), Vector3D.Z_AXIS, new Vector3D(0, -1, 0));
			
			return _shadowCamera;
		}
	}

}