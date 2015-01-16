package  
{
	import com.bit101.components.PushButton;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import gl3d.core.InstanceMaterial;
	import gl3d.ctrl.Ctrl;
	import gl3d.ctrl.FirstPersonCtrl;
	import gl3d.ctrl.FollowCtrl;
	import gl3d.core.Material;
	import gl3d.meshs.Meshs;
	import gl3d.core.Node3D;
	import gl3d.parser.DAEParser;
	import gl3d.pick.TerrainPicking;
	import gl3d.shaders.TerrainPhongGLShader;
	import gl3d.core.TextureSet;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestTerrain extends BaseExample
	{
		private var terrain:Node3D;
		private var player:Node3D;
		private var targetCube:Node3D;
		private var gameModeBtn:PushButton;
		private var pix:Vector3D = new Vector3D;
		private var moving:Boolean = true;
		private var isClick:Boolean = false;
		private var players:Array = [];
		private var p:DAEParser;
		private var materialInstance:InstanceMaterial = new InstanceMaterial;
		public function TestTerrain() 
		{
		}
		
		override public function initUI():void 
		{
			super.initUI();
			gameModeBtn = new PushButton(this, 125, 5, "game mode", gameModeBtnClick);
			gameModeBtn.toggle = true;
			gameModeBtn.selected = true;
		}
		
		private function gameModeBtnClick(e:Event):void 
		{
			initCtrl();
		}
		
		override public function initCtrl():void 
		{
			if (gameModeBtn.selected) {
				view.ctrls=Vector.<Ctrl>([new FollowCtrl(player,view.camera)]);
			}else {
				view.ctrls=Vector.<Ctrl>([new FirstPersonCtrl(view.camera,stage)]);
			}
			
		}
		
		override public function initNode():void {
			view.camera.z = -40;
			view.camera.y = 10;
			view.camera.rotationX = 20 * Math.PI / 180;
			view.lights[0].y = 2000;
			view.lights[0].x = 0;
			view.lights[0].z = -1000;
			//view.light.lightPower = 2;
			
			[Embed(source = "assets/unityterraintexture/Cliff (Layered Rock).jpg")]var c0:Class;
			[Embed(source = "assets/unityterraintexture/GoodDirt.jpg")]var c1:Class;
			[Embed(source = "assets/unityterraintexture/Grass (Hill).jpg")]var c2:Class;
			[Embed(source = "assets/unityterraintexture/Grass&Rock.jpg")]var c3:Class;
			
			var bmd:BitmapData = new BitmapData(128, 128, false, 0xff0000);
			bmd.perlinNoise(30, 30, 10, 1, false, false);
			var byte:ByteArray = bmd.getPixels(bmd.rect);
			for (var i:int = 0; i < byte.length;i+=4 ) {
				var a:uint = byte[i];
				var r:uint = byte[i+1];
				var g:uint = byte[i+2];
				var b:uint = byte[i + 3];
				var rgb:uint = r + g + b;
				if (rgb > 0xff) {
					b = 0;
				}
				rgb = r + g;
				if (rgb > 0xff) {
					g = 0;
				}
				byte[i + 1] = r;
				byte[i + 2] = g;
				byte[i + 3] = b
			}
			byte.position = 0;
			bmd.setPixels(bmd.rect, byte);
			
			var texture:TextureSet=new TextureSet(bmd);
			//material.color = Vector.<Number>([.6, .6, .6, 1]);
			material.shininess = 1.5;
			material.normalMapAble = false;
			material.textureSets = [texture, getTerrainTexture(c0), getTerrainTexture(c1), getTerrainTexture(c2), getTerrainTexture(c3)];
			material.shader = new TerrainPhongGLShader();
			
			terrain = new Node3D;
			terrain.material = material;
			terrain.drawable = Meshs.terrain(64,new Vector3D(350,350,350));
			view.scene.addChild(terrain);
			terrain.picking = new TerrainPicking(terrain);
			
			targetCube = new Node3D;
			targetCube.material = new Material;
			targetCube.material.color[1] = 0;
			targetCube.drawable = Meshs.teapot();
			targetCube.scaleX = targetCube.scaleY = targetCube.scaleZ = .3;
			view.scene.addChild(targetCube);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, stage_mouseDown);
			
			[Embed(source = "assets/astroBoy_walk_Max.dae", mimeType = "application/octet-stream")]var c:Class;
			var ba:ByteArray = new c as ByteArray;
			p = new DAEParser;
			p.load(null, ba);
			player = new Node3D;
			player.addChild(p.root);
			p.root.scaleX = p.root.scaleY = p.root.scaleZ = 1;
			p.root.rotationX = -Math.PI/2 ;
			p.root.rotationY = 0;// -Math.PI;
			view.scene.addChild(player);
			addNode(30);
		}
		
		private function addNode(num:int):void {
			while(num-->0){
				var d:int = 3;
				var clone:Node3D = player.clone();
				players.push(clone);
				
				changeMaterial(clone);
				view.scene.addChild(clone);
			}
		}
		
		private function stage_mouseDown(e:MouseEvent):void 
		{
			stage.addEventListener(Event.ENTER_FRAME, stage_mouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUp);
		}
		
		private function stage_mouseUp(e:MouseEvent):void 
		{
			stage.removeEventListener(Event.ENTER_FRAME, stage_mouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUp);
		}
		
		private function stage_mouseMove(e:Event):void 
		{
			isClick = true;
		}
		
		private function doClick():void {
			var rayOrigin:Vector3D = new Vector3D;
			var rayDirection:Vector3D = new Vector3D;
			var pix:Vector3D = new Vector3D;
			view.camera.computePickRayDirectionMouse(mouseX, mouseY, stage.stageWidth, stage.stageHeight, rayOrigin, rayDirection);
			
			if (terrain.rayMeshTest(rayOrigin, rayDirection,pix)) {
				moving = true;
				targetCube.x = pix.x;
				targetCube.y = pix.y;
				targetCube.z = pix.z;
				this.pix.copyFrom(pix);
			}
		}
		
		private function getTerrainTexture(c:Class):TextureSet {
			var bmd:BitmapData =  (new c as Bitmap).bitmapData;
			return new TextureSet(bmd);
		}
		
		override public function enterFrame(e:Event):void
		{
			if (isClick) {
				doClick();
				isClick = false;
			}
			if (moving) {
				var distance:Number = Vector3D.distance(pix, player.world.position);
				var speed:Number = .1;
				if (distance<speed) {
					player.x = pix.x;
					player.z = pix.z;
					moving = false;
				}else {
					var v:Vector3D = pix.subtract(player.world.position);
					v.normalize();
					v.scaleBy(speed);
					player.x += v.x;
					player.z += v.z;
				}
				player.y = (terrain.picking as TerrainPicking).getHeight(player.x, player.z);
				if (v) {
					player.rotationY = Math.atan2( -v.z, v.x)+Math.PI/2;
				}
				var last:Node3D = player;
				for each(var clone:Node3D in players) {
					v = last.world.position.subtract(clone.world.position);
					v.scaleBy(.03);
					clone.x += v.x;
					clone.z += v.z;
					clone.y = (terrain.picking as TerrainPicking).getHeight(clone.x, clone.z);
					clone.rotationY = Math.atan2( -v.z, v.x)+Math.PI/2;
					last = clone;
				}
			}
			super.enterFrame(e);
		}
		
		private function changeMaterial(node:Node3D):void {
			if (node.material) {
				materialInstance.wireframeAble = node.material.wireframeAble;
				node.material = materialInstance;
			}
			for each(var child:Node3D in node.children) {
				changeMaterial(child);
			}
		}
	}

}