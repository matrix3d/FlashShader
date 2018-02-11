package gl3d.core.skin 
{
	import gl3d.core.Node3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class SkinAnimTimeLine 
	{
		private var scripts:Array = [];
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
		
		public function update(t:Number/*,ctrl:SkinAnimationCtrl,anim:SkinAnimation,node:Node3D*/,funs:Array):void{
			//trace("update");
			for (var i:int = scripts.length-1; i >= 0;i-- ){
				var s:SkinAnimFrameScript = scripts[i];
				if (!s.exeover&&s.time<=t){
					s.exeover = true;
					funs.push(s);
					
					//*if (*//*s.exec()/*/
						//exitTime = s.time;
						//if(anim==ctrl.anim){
						//	ctrl.time = ctrl.startTime+anim.maxTime * 1000 * exitTime;
						//	anim.update(exitTime*anim.maxTime,node);
						//}
						//return true;
					//}
				}
			}
			//return false;
		}
		
		public function addFrameScript(script:SkinAnimFrameScript):void{
			scripts.unshift(script);
		}
		
	}

}