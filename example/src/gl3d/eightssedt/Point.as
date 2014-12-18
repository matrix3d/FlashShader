package gl3d.eightssedt 
{
	/**
	 * ...
	 * @author lizhi
	 */
	public class Point 
	{
		public var dx:int;
		public var dy:int;
		public function Point(dx:int,dy:int) 
		{
			this.dx = dx;
			this.dy = dy;
		}
		public function DistSq():int { return dx * dx + dy * dy };
		
	}

}