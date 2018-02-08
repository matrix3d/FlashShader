package gl3d.core.skin 
{
	import gl3d.core.Node3D;
	import gl3d.ctrl.Ctrl;
	/**
	 * ...
	 * @author lizhi
	 */
	public class SkinAnimationCtrl extends Ctrl
	{
		public var anim:SkinAnimation;
		public var anims:Array = [];
		private var startTime:Number = 0;
		public var time:Number = 0;
		public var animtime:Number = 0;
		public var playing:Boolean = true;
		public function SkinAnimationCtrl() 
		{
			
		}
		
		override public function update(time:int,node:Node3D):void 
		{
			if (anim) {
				if(playing){
					this.time = time;
				}
				if (startTime==-1){
					startTime = time;
				}
				
				var t:Number = (time-startTime) / 1000;
				while (t > anim.maxTime){
					startTime += anim.maxTime*1000;
					t -= anim.maxTime;
				}
				anim.update(t,node);
			}
		}
		
		public function play(name:String):void{
			startTime =-1;
			for each(var a:SkinAnimation in anims){
				if (a.name==name){
					anim = a;
					break;
				}
			}
			playing = true;
		}
		
		public function add(anim:SkinAnimation):void {
			this.anim = anim;
			anims.push(anim);
			play(null);
		}
		
		override public function clone():Ctrl 
		{
			var c:SkinAnimationCtrl = new SkinAnimationCtrl;
			c.add(anim.clone());
			return c;
		}
	}

}