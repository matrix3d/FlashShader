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
		public var startTime:Number = 0;
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
				var t:Number = ((this.time-startTime) / 1000) % anim.maxTime;
				if (isNaN(t)) {
					t = 0;
				}
				anim.update(t,node);
			}
		}
		
		public function add(anim:SkinAnimation):void {
			this.anim = anim;
			anims.push(anim);
		}
		
		override public function clone():Ctrl 
		{
			var c:SkinAnimationCtrl = new SkinAnimationCtrl;
			c.add(anim.clone());
			c.startTime = 1000 * Math.random();
			return c;
		}
	}

}