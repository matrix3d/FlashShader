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
		public var dirty:Boolean = true;
		public var anim:SkinAnimation;
		public var anims:Array = [];
		public var startTime:Number = 0;
		public var time:Number = 0;
		public var animtime:Number = 0;
		public var playing:Boolean = true;
		public var transitionAnim:SkinAnimation;
		private var waitAnimAfterTransition:String;//过渡后需要播放的动画
		private var funs:Array;
		public function SkinAnimationCtrl() 
		{
			
		}
		
		override public function update(time:int,node:Node3D):void 
		{
			if (dirty){
				dirty = false;
				resetJoint(node);
				function resetJoint(j:Node3D):void{
					if (j is Joint){
						(j as Joint).reset();
					}
					for each(var c:Node3D in j.children){
						resetJoint(c);
					}
				}
			}
			for each(var fun:SkinAnimFrameScript in funs){
				fun.exec();
			}
			
			if (anim) {
				funs = [];
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
			}
		}
		
		public function playIndex(i:int,transitionTime:Number/*,startRatio:Number=0*/):SkinAnimation{
			dirty = true;
			var fanim:SkinAnimation = anims[i];
			if (fanim==null){
				return null;
			}
			startTime =-1;
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
							t.target = fanim.tracks[tname].target;
							//t.targetName = tname;
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
								var j:Joint = t2.target as Joint;
								var ms:Array = anim.jointMatrixs[j.name]//[0];
								if(ms){
									f2.matrix.copyFrom(ms[0]);
								}else{
									anim = fanim;
									return fanim;
								}
								//var m:Matrix3D = (anim.skin.cacheFrame || anim.skin.skinFrame).matrixs[j.msIndex];
								//f2.matrix.copyFrom(m);
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
					waitAnimAfterTransition = fanim.name;
				}else{
					//startTime = time-fanim.maxTime * (1-startRatio);
					anim = fanim;
				}
			}
			
			return fanim;
		}
		
		/**
		 * 
		 * @param	name
		 * @param	transitionTime 过渡时间s
		 * @return
		 */
		public function play(name:String,transitionTime:Number/*,startRatio:Number=0*/):SkinAnimation{
			var i:int = 0;
			for each(var a:SkinAnimation in anims){
				if (a.name==name){
					return playIndex(i, transitionTime/*,startRatio*/);
					break;
				}
				i++;
			}
			return null;
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
			for (var i:int = 0; i < anims.length;i++ ){
				var ac:SkinAnimation = anims[i].clone();
				c.add(ac);
			}
			c.play(anim.name, 0);
			return c;
		}
	}

}