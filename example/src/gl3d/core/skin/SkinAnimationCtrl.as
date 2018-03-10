package gl3d.core.skin 
{
	import flash.geom.Matrix3D;
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
		public var transitionAnim:SkinAnimation;
		private var waitAnimAfterTransition:String;//过渡后需要播放的动画
		public function SkinAnimationCtrl() 
		{
			
		}
		
		override public function update(time:int,node:Node3D):void 
		{
			if (anim) {
				var funs:Array = [];
				if(playing){
					this.time = time;
				}
				if (startTime==-1){
					startTime = this.time;
				}
				
				var t:Number = (this.time-startTime) / 1000;
				if (playing&&t >= anim.maxTime){
					///*if (*///{//如果脚本中断操作，则退出
						//return;
					//}
					//anim.timeline.nextloop();
					//超过一圈
					//startTime += anim.maxTime * 1000;
					//t -= anim.maxTime;
					anim.timeline.update(1, funs);
					anim.timeline.nextloop();
					startTime = -1;
					t = anim.maxTime;
				}else{
					anim.timeline.update(t/anim.maxTime, funs);
				}
				///*if (*/anim.timeline.update(t / anim.maxTime/*,this,anim,node*/,funs)//){
					//this.time = startTime+anim.maxTime * 1000 * anim.timeline.exitTime;
					//anim.update(anim.timeline.exitTime*anim.maxTime, node);
				//}
				anim.update(t, node);
				for each(var fun:SkinAnimFrameScript in funs){
					fun.exec();
				}
			}
		}
		
		/**
		 * 
		 * @param	name
		 * @param	transitionTime 过渡时间s
		 * @return
		 */
		public function play(name:String,transitionTime:Number):SkinAnimation{
			startTime =-1;
			var fanim:SkinAnimation;
			for each(var a:SkinAnimation in anims){
				if (a.name==name){
					fanim = a;
					break;
				}
			}
			playing = true;
			
			if (fanim){
				if (transitionTime>0&&anim/*&&anim.tracks.length&&fanim.tracks.length*/){
					if (transitionAnim==null){
						transitionAnim = new SkinAnimation;
						transitionAnim.isCache = false;
						transitionAnim.name = "__transition";
						transitionAnim.targetNames = fanim.targetNames;
						//transitionAnim.tracks = {};//new Vector.<Track>;//fanim.tracks;
						transitionAnim.timeline.addFrameScript(new SkinAnimFrameScript(1,
							function ():void{
								play(waitAnimAfterTransition, 0);
							}
						));
						/*for each(var t:Track in fanim.tracks){//过渡只需要2帧，先初始化放进去，等下调整时间和矩阵
							var t2:Track = new Track;
							t2.targetName = t.targetName;
							var f2:TrackFrame = new TrackFrame;
							f2.time = 0;
							f2.matrix = new Matrix3D;
							t2.frames.push(f2);
							
							f2 = new TrackFrame;
							f2.time = 0;
							f2.matrix = new Matrix3D;
							t2.frames.push(f2);
							transitionAnim.tracks[t2.targetName] = t2;//.push(t2);
						}*/
					}
					transitionAnim.timeline.nextloop();
					for (var tname:String in fanim.tracks){
						var t:Track = transitionAnim.tracks[tname];
						if (t==null){
							t = new Track;
							t.targetName = tname;
							var f2:TrackFrame = new TrackFrame;
							f2.time = 0;
							f2.matrix = new Matrix3D;
							t.frames.push(f2);
							
							f2 = new TrackFrame;
							f2.time = 0;
							f2.matrix = new Matrix3D;
							t.frames.push(f2);
							transitionAnim.tracks[tname] = t;
						}
						
						var t2:Track = anim.tracks[tname];
						if (t2){
							if(t2.target){
								f2 = t.frames[0];
								f2.matrix.copyFrom(t2.target.matrix);
							}
						}
						
						t2 = fanim.tracks[tname];
						if(t2){
							f2 = t.frames[1];
							f2.matrix.copyFrom(t2.frames[0].matrix);
							f2.time = transitionTime;
						}
					}
					transitionAnim.maxTime = transitionTime;
					anim = transitionAnim;
					waitAnimAfterTransition = name;
				}else{
					anim = fanim;
				}
			}
			
			return fanim;
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