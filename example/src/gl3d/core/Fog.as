package gl3d.core 
{
	/**
	 * http://www.cppblog.com/lovedday/archive/2008/05/11/49513.html
	 * @author lizhi
	 */
	public class Fog 
	{
		public static const FOG_NONE:int = 0;
		/**exp(d*density)*/
		public static const FOG_EXP:int = 1;
		/**exp((d*density)^2)*/
		public static const EXP2:int = 2;
		/**(end-d*density)/(end-start)*/
		public static const LINEAR:int = 3;
		
		public var mode:int;
		/**密度*/
		public var density:Number = 1;
		public var start:Number = 0;
		public var end:Number = 1;
		public function Fog() 
		{
			
		}
		
	}

}