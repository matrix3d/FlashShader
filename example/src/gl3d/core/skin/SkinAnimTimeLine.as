package gl3d.core.skin 
{
	/**
	 * ...
	 * @author lizhi
	 */
	public class SkinAnimTimeLine 
	{
		private static var scripts:Array = [];
		public var exitTime:Number;
		public function SkinAnimTimeLine() 
		{
			
		}
		
		public function clear():void{
			scripts = [];
		}
		
		public function nextloop():void{
			//trace("nextloop");
			for each(var script:SkinAnimFrameScript in scripts){
				script.exeover = false;
			}
		}
		
		public function update(t:Number):Boolean{
			//trace("update");
			for (var i:int = scripts.length-1; i >= 0;i-- ){
				var s:SkinAnimFrameScript = scripts[i];
				if (!s.exeover&&s.time<t){
					s.exeover = true;
					if (s.exec()){
						exitTime = s.time;
						return true;
					}
				}
			}
			return false;
		}
		
		public function addFrameScript(script:SkinAnimFrameScript):void{
			scripts.unshift(script);
		}
		
	}

}