package gl3d.core 
{
	/**
	 * http://www.cppblog.com/lovedday/archive/2008/05/11/49513.html
	 * @author lizhi
	 */
	public class Fog 
	{
		public static const FOG_NONE:int = 0;
		/**1/exp(d*density)*/
		public static const FOG_EXP:int = 1;
		/**1/exp((d*density)^2)*/
		public static const FOG_EXP2:int = 2;
		/**(end-d)/(end-start)*/
		public static const FOG_LINEAR:int = 3;
		
		public var mode:int = FOG_NONE;
		/**密度*/
		public var density:Number = 0.03;
		public var start:Number = 10;
		public var end:Number = 100;
		public var fogColor:Array = [1,1,1];
		public function Fog() 
		{
			
		}
		
	}

}