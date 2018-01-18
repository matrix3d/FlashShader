package 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.getTimer;
	import gl3d.core.Drawable;
	import gl3d.core.Fog;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.core.TextureSet;
	import gl3d.core.shaders.GLShader;
	import gl3d.meshs.Meshs;
	import gl3d.meshs.Teapot;
	import gl3d.shaders.PhongVertexShader;
	import gl3d.shaders.TerrainPhongFragmentShader;
	/**
	 * ...
	 * @author lizhi
	 */
	public class JumpAndJump extends BaseExample
	{
		private var startTime:int = 0;
		private var jumping:Boolean = false;
		private var isPreJumping:Boolean = false;
		private var isGaming:Boolean = false;//是否游戏中
		private var isFalling:Boolean = false;//是否掉落中
		private var fallStartX:Number;
		private var fallTargetX:Number;
		private var fallTargetRot:Number;
		private var fallV:Number;
		private var cube:Node3D;
		private var v:Number = 0;
		private var jumpv:Number = 0;
		private var moveX:Number = 1;
		private var moveY:Number = 3;
		private var startX:Number;
		private var startY:Number;
		private var plane:Node3D;
		private var plane2:Node3D;
		private var planeHalfWidth:int = 100;
		private var cubes:Array = [];
		private var cubeWidth:Number = 2;
		private var cubeHeight:Number = 4;
		private var cubeDrawable:Drawable = Meshs.cube(cubeWidth,cubeHeight,cubeWidth);
		private var nextCubeX:Number = 0;
		private var score:int = 0;
		
		private var scoreLabel:TextField;
		private var startBtn:TextField;
		public function JumpAndJump() 
		{
			
		}
		
		
		override public function initNode():void 
		{
			addSky();
			
			view.camera.z =-15;
			view.camera.y = 5;
			view.camera.rotationX = Math.atan2(view.camera.y, -view.camera.z) * 180 / Math.PI;
			
			view.fog.mode = Fog.FOG_LINEAR;
			view.fog.start = 40;
			view.fog.end = 80;
			view.fog.fogColor =[0x84 / 0xff, 0x98 / 0xff, 0xbe / 0xff];
			view.background = 0x8498be;
			
			cube = new Node3D;
			cube.material = new Material;
			cube.material.reflectTexture = skyBoxTexture;
			cube.drawable = Meshs.cube();
			
			/*var tp:Node3D = new Node3D;
			tp.drawable = Teapot.teapot();
			tp.material = new Material;
			tp.material.reflectTexture = skyBoxTexture;
			cube.addChild(tp);
			
			tp.setScale(.3, .3, .3);
			tp.y =-.5;
			tp.x = 0;*/
			
			
			plane = new Node3D;
			plane.rotationX = 90;
			plane.y =-.5 - cubeHeight;
			plane.drawable = Meshs.plane(planeHalfWidth);
			plane.material = new Material;
			[Embed(source = "assets/unityterraintexture/GoodDirt.jpg")]var c0:Class;
			[Embed(source = "assets/unityterraintexture/Cliff (Layered Rock).jpg")]var c1:Class;
			[Embed(source = "assets/unityterraintexture/Grass (Hill).jpg")]var c2:Class;
			[Embed(source = "assets/unityterraintexture/Grass&Rock.jpg")]var c3:Class;
			plane.material.terrainTextureSets = [getTerrainTexture(c0), getTerrainTexture(c1), getTerrainTexture(c2), getTerrainTexture(c3)];
			(plane.material as Material).shader = new GLShader(new PhongVertexShader,new TerrainPhongFragmentShader);
			plane.material.terrainScale.setTo(50, 50, 50);
			var bmd:BitmapData = new BitmapData(256, 256);
			bmd.perlinNoise(20, 20, 10, 1,true, true);
			plane.material.diffTexture = new TextureSet(bmd);
			view.scene.addChild(plane);
			
			plane2 = plane.clone();
			view.scene.addChild(plane2);
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, stage_mouseDown);
		}
		
		private function addCube():void{
			var node:Node3D = new Node3D;
			node.drawable = cubeDrawable;
			node.material = new Material;
			view.scene.addChild(node);
			node.x = nextCubeX;
			node.y =-.5 - cubeHeight / 2;
			nextCubeX += 3 + 7 * Math.random();
			cubes.unshift(node);
			//对多显示10个cube
			while (cubes.length>5){
				node = cubes.pop();
				if (node.parent){
					node.parent.removeChild(node);
				}
			}
		}
		
		override public function initUI():void 
		{
			//super.initUI();
			scoreLabel = new TextField;
			scoreLabel.autoSize = "left";
			scoreLabel.defaultTextFormat = new TextFormat(null, 30, 0xffffff, true);
			scoreLabel.mouseEnabled = scoreLabel.mouseWheelEnabled = scoreLabel.selectable = false;
			addChild(scoreLabel);
			
			startBtn = new TextField;
			startBtn.mouseWheelEnabled = startBtn.selectable = false;
			startBtn.autoSize = "left";
			startBtn.defaultTextFormat = new TextFormat(null, 60, 0, true);
			startBtn.background = true;
			startBtn.backgroundColor = 0xffffff;
			startBtn.text = "start";
			startBtn.x = 200;
			addChild(startBtn);
			startBtn.addEventListener(MouseEvent.CLICK, startBtn_click);
			updateScore();
			stage_resize();
		}
		
		override protected function stage_resize(e:Event = null):void 
		{
			super.stage_resize(e);
			if (scoreLabel){
				var scaleUI:Number = stage.stageWidth / 1000;
				scoreLabel.scaleX = scoreLabel.scaleY = scaleUI;
				startBtn.scaleX = startBtn.scaleY = scaleUI;
				startBtn.x = stage.stageWidth / 2 - startBtn.width / 2;
				startBtn.y = stage.stageHeight / 2 - startBtn.height / 2;
			}
		}
		
		private function updateScore():void{
			scoreLabel.text = "score " + score;
		}
		
		private function startBtn_click(e:MouseEvent):void 
		{
			resetGame();
		}
		
		private function resetGame():void 
		{
			if (startBtn.parent){
				startBtn.parent.removeChild(startBtn);
			}
			view.scene.addChild(cube);
			jumping = false;
			isPreJumping = false;
			isGaming = true;
			score = 0;
			view.camera.x = 0;
			cube.rotationZ = 0;
			cube.x = 0;
			cube.y = 0;
			plane.x = 0;
			plane2.x = 0;
			nextCubeX = 0;
			while (cubes.length){
				var node:Node3D = cubes.pop();
				if (node.parent){
					node.parent.removeChild(node);
				}
			}
			
			addCube();
			addCube();
		}
		
		private function getTerrainTexture(c:Class):TextureSet {
			var bmd:BitmapData =  (new c as Bitmap).bitmapData;
			return new TextureSet(bmd);
		}
		
		private function stage_mouseDown(e:MouseEvent):void 
		{
			if (!jumping&&isGaming){
				isPreJumping = true;
				startTime = getTimer();
				stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUp);
			}
		}
		
		private function stage_mouseUp(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUp);
			var dtime:int = getTimer() - startTime;
			moveX = dtime / 100;
			moveY = dtime / 100;
			jumping = true;
			isPreJumping = false;
			jumpv = 0;
			v = 2 / 60;
			startX = cube.x;
			startY = cube.y;
			cube.scaleY = 1;
			cube.y = 0;
			
			var ncube:Node3D = cubes[1];
			ncube.scaleY = 1;
			ncube.y = -.5 - cubeHeight / 2;
			
			if (cube.x>plane.x){
				plane2.x = int(cube.x / (planeHalfWidth * 2)) * planeHalfWidth * 2;
				plane.x = plane2.x + planeHalfWidth * 2;
			}
		}
		
		override public function initCtrl():void 
		{
		}
		
		override public function enterFrame(e:Event):void 
		{
			if(isGaming){
				if (jumping){
					jumpv += v;
					if (jumpv>=1){
						jumpv = 1;
						jumping = false;
					}
					cube.x = startX + moveX * jumpv;
					cube.y = moveY * (0.25 - (jumpv - .5) * (jumpv - .5)) / .25;
					cube.rotationZ = -360 * jumpv;
					if (jumpv>=1){
						//判断成功失败
						var dx1:Number = cube.x - cubes[1].x;
						var dx0:Number = Math.abs(cube.x - cubes[0].x);
						if (dx1<=cubeWidth/2){
							trace("还在当前格子");
						}else{
							if (dx0<=cubeWidth/2){
								trace("成功 加分");
								if (dx0<cubeWidth/10){
									score+= 5;
								}else{
									score+= 1;
								}
								updateScore();
								addCube();
							}else{
								trace("失败，游戏结束");
								isFalling = true;
								isGaming = false;
								var dx:Number;
								if (dx1 < dx0){
									dx = dx1;
									var ncube:Node3D = cubes[1];
								}else{
									dx = dx0;
									ncube = cubes[0];
								}
								//根据ncube执行掉落
								fallStartX = cube.x;
								if (dx<(cubeWidth/2+.5)){
									trace("需要执行滚动掉落");
									if (cube.x>ncube.x){
										fallTargetX = ncube.x + cubeWidth / 2 + .5;
										fallTargetRot = -90;
									}else{
										fallTargetX = ncube.x - cubeWidth / 2 - .5;
										fallTargetRot = 90;
									}
								}else{
									fallTargetX = fallStartX;
									fallTargetRot = 0;
									trace("直接掉落");
								}
								fallV = 0;
							}
						}
					}
				}else{
					if (isPreJumping){
						var dtime:int = getTimer() - startTime;
						cube.scaleY = Math.max(.1, 1 - dtime / 1000);
						cube.y = -(1 - cube.scaleY) / 2- (1 - cube.scaleY) * cubeHeight;
						
						ncube = cubes[1];
						ncube.scaleY = cube.scaleY;
						ncube.y =-.5 - cubeHeight / 2 - (1 - cube.scaleY) / 2 * cubeHeight;
					}
					var cameraTargetX:Number = cubes[1].x;
					view.camera.x = view.camera.x + (cameraTargetX - view.camera.x) * .03;
				}
			}else{
				if (isFalling){
					fallV += 5 / 60;
					if (fallV>=1){
						fallV = 1;
						isFalling = false;
						trace("gameover 显示开始游戏ui");
						addChild(startBtn);
					}
					cube.y =-cubeHeight * fallV;
					cube.x = fallStartX + (fallTargetX - fallStartX) * fallV;
					cube.rotationZ = fallTargetRot * fallV;
				}
			}
			super.enterFrame(e);
		}
	}

}