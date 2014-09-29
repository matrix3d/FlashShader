package gl3d 
{
	/**
	 * ...
	 * @author lizhi
	 */
	public class Light extends Node3D
	{
		public var color:Vector.<Number> = Vector.<Number>([.7,.7,.7,1]);
		public var ambient:Vector.<Number> = Vector.<Number>([.1, .1, .1, .1]);
		public var specularPower:Number = 500;
		public var lightPower:Number = 1;
		public function Light() 
		{
			
		}
		
	}

}