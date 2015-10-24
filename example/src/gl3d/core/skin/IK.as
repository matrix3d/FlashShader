package gl3d.core.skin 
{
	/**
	 * ...
	 * @author lizhi
	 */
	public class IK 
	{
		public var effector:Joint;
		public var iteration:int;
		public var control:Number;
		public var links:Vector.<IKLink> = new Vector.<IKLink>;
		public function IK() 
		{
			
		}
		
	}

}