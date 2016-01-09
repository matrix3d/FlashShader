package awayphysics 
{
	import flash.geom.Matrix3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Away3dObject 
	{
		/*public var scaleX:Number=1;
		public var scaleY:Number=1;
		public var scaleZ:Number = 1;
		public var rotationX:Number = 0;
		public var rotationY:Number = 0;
		public var rotationZ:Number = 0;*/
		private var _matrix:Matrix3D;
		public function Away3dObject() 
		{
			
		}
		
		public function get matrix():Matrix3D 
		{
			return _matrix;
		}
		
		public function set matrix(value:Matrix3D):void 
		{
			_matrix = value;
			//trace(value);
		}
		
	}

}