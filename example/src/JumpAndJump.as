package 
{
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.getTimer;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.core.TextureSet;
	import gl3d.meshs.Meshs;
	/**
	 * ...
	 * @author lizhi
	 */
	public class JumpAndJump extends BaseExample
	{
		private var startTime:int = 0;
		private var jumping:Boolean = false;
		private var cube:Node3D;
		private var v:Number = 0;
		private var jumpv:Number = 0;
		private var moveX:Number = 1;
		private var moveY:Number = 2;
		private var startX:Number;
		private var startY:Number;
		public function JumpAndJump() 
		{
			
		}
		
		
		override public function initNode():void 
		{
			addSky();
			
			cube = new Node3D;
			cube.material = new Material;
			cube.drawable = Meshs.cube();
			view.scene.addChild(cube);
			
			var plane:Node3D = new Node3D;
			plane.rotationX = 90;
			plane.y =-.5;
			plane.drawable = Meshs.plane(100);
			plane.material = new Material;
			var bmd:BitmapData = new BitmapData(1024, 1024);
			bmd.perlinNoise(5, 5, 10, 1, true, true);
			plane.material.diffTexture = new TextureSet(bmd);
			view.scene.addChild(plane);
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, stage_mouseDown);
		}
		
		private function stage_mouseDown(e:MouseEvent):void 
		{
			if(!jumping){
				startTime = getTimer();
				stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUp);
			}
		}
		
		private function stage_mouseUp(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUp);
			var dtime:int = getTimer() - startTime;
			moveX = dtime / 300;
			jumping = true;
			jumpv = 0;
			v = 2 / 60;
			startX = cube.x;
			startY = cube.y;
		}
		
		override public function initCtrl():void 
		{
		}
		
		override public function enterFrame(e:Event):void 
		{
			if (jumping){
				jumpv += v;
				if (jumpv>=1){
					jumpv = 1;
					jumping = false;
				}
				cube.x = startX + moveX * jumpv;
				cube.y = moveY * (0.25 - (jumpv - .5) * (jumpv - .5)) / .25;
				cube.rotationZ = -360 * jumpv;
			}else{
				view.camera.x = view.camera.x + (cube.x - view.camera.x) * .03;
			}
			super.enterFrame(e);
		}
	}

}