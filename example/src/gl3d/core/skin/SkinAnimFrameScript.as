package gl3d.core.skin 
{
	/**
	 * ...
	 * @author lizhi
	 */
	public class SkinAnimFrameScript 
	{
		private var fun:Function;
		//private var isExit:Boolean;
		public var exeover:Boolean = false;
		public var time:Number = 0;
		public function SkinAnimFrameScript(time:Number,fun:Function/*,isExit:Boolean*/) 
		{
			//this.isExit = isExit;
			this.fun = fun;
			this.time = time;
		}
		
		public function exec():void{
			fun();
			//return isExit;
		}
		
	}

}