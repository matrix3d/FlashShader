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
					startTime = this.time;
				}
				
				var t:Number = (this.time-startTime) / 1000;
				while (playing&&t > anim.maxTime){
					if (anim.timeline.update(t / anim.maxTime)){//如果脚本中断操作，则退出
						this.time = startTime+anim.maxTime * 1000 * anim.timeline.exitTime;
						anim.update(anim.timeline.exitTime*anim.maxTime,node);
						return;
					}
					anim.timeline.nextloop();
					//超过一圈
					startTime += anim.maxTime * 1000;
					t -= anim.maxTime;
					if (anim.maxTime<=0){
						break;
					}
				}
				if (anim.timeline.update(t / anim.maxTime)){
					this.time = startTime+anim.maxTime * 1000 * anim.timeline.exitTime;
					anim.update(anim.timeline.exitTime*anim.maxTime, node);
				}else{
					anim.update(t, node);
				}
			}
		}
		
		public function play(name:String,transitionTime:int):SkinAnimation{
			startTime =-1;
			for each(var a:SkinAnimation in anims){
				if (a.name==name){
					anim = a;
					break;
				}
			}
			playing = true;
			return anim;
		}
		
		public function stop():void{
			playing = false;
		}
		
		public function add(anim:SkinAnimation):void {
			this.anim = anim;
			anims.push(anim);
			play(null,0);
		}
		
		override public function clone():Ctrl 
		{
			var c:SkinAnimationCtrl = new SkinAnimationCtrl;
			c.add(anim.clone());
			return c;
		}
	}

}