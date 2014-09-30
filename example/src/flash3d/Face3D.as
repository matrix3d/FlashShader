package flash3d {
	import flash3d.V3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Face3D 
	{
		public var vs:Vector.<V3D> = new Vector.<V3D>;
		public var uv:Vector.<V3D> = new Vector.<V3D>;
		public var norm:Vector.<V3D> = new Vector.<V3D>;
		public var out:Vector.<V3D> = new Vector.<V3D>;
		public var ins:Vector.<int> = new Vector.<int>;
		public var scale:Number = 0;
		public var color:uint = 0xffffff * Math.random();
		public function Face3D() 
		{
			
		}
		
	}

}