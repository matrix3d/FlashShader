package awayphysics 
{
	import awayphysics.math.AWPTransform;
	import flash.geom.Matrix3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Away3dObject extends AWPBase
	{
		/*public var scaleX:Number=1;
		public var scaleY:Number=1;
		public var scaleZ:Number = 1;
		public var rotationX:Number = 0;
		public var rotationY:Number = 0;
		public var rotationZ:Number = 0;*/
		private var _matrix:AWPTransform;
		public function Away3dObject() 
		{
			
		}
		
		public function get matrix():AWPTransform 
		{
			return _matrix;
		}
		
		public function set matrix(value:AWPTransform):void 
		{
			_matrix = value;
			//trace(value);
		}
		
	}

}