package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import gl3d.Drawable3D;
	import gl3d.Material;
	import gl3d.meshs.Meshs;
	import gl3d.Node3D;
	import gl3d.pick.TerrainPicking;
	import gl3d.shaders.TerrainPhongGLShader;
	import gl3d.TextureSet;
	import gl3d.View3D;
	import ui.AttribSeter;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestTerrain extends Sprite
	{
		private var view:View3D;
		private var material:Material = new Material;
		
		private var terrain:Node3D
		private var cube:Node3D;
		
		private var aui:AttribSeter = new AttribSeter;
		private var _useTexture:Boolean = true;
		private var texture:TextureSet;
		private var debug:TextField = new TextField;
		public function TestTerrain() 
		{
			view = new View3D;
			addChild(view);
			
			view.camera.z = -40;
			view.camera.y = 10;
			view.camera.rotationX = 20 * Math.PI / 180;
			view.light.y = 2000;
			view.light.lightPower = 2;
			
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
			
			texture=new TextureSet(bmd);
			material.textureSets = Vector.<TextureSet>([texture]);
			material.color = Vector.<Number>([.6, .6, .6, 1]);
			
			material.textureSets = Vector.<TextureSet>([texture, getTerrainTexture(c0), getTerrainTexture(c1), getTerrainTexture(c2), getTerrainTexture(c3)]);
			material.shader = new TerrainPhongGLShader();
			
			terrain = new Node3D;
			terrain.material = material;
			terrain.drawable = Meshs.terrain(64,new Vector3D(50,50,50));
			view.scene.addChild(terrain);
			terrain.picking = new TerrainPicking(terrain);
			
			cube = new Node3D;
			cube.material = new Material
			cube.drawable = Meshs.cube();
			view.scene.addChild(cube);
			
			addEventListener(Event.ENTER_FRAME, enterFrame);
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(Event.RESIZE, stage_resize);
			stage_resize();
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_click);
			addChild(debug);
			debug.autoSize = "left";
			debug.background = true;
			debug.backgroundColor = 0xffffff;
		}
		
		private function stage_click(e:MouseEvent):void 
		{
			var rayOrigin:Vector3D = new Vector3D;
			var rayDirection:Vector3D = new Vector3D;
			var pix:Vector3D = new Vector3D;
			view.camera.computePickRayDirectionMouse(mouseX, mouseY, stage.stageWidth, stage.stageHeight, rayOrigin, rayDirection);
			
			/*var time:Number = getTimer();
			var c:int = 1000;
			while(c-->0)
			terrain.rayMeshTest(rayOrigin, rayDirection,pix)
			debug.text = (getTimer() - time) + "ms";*/
			
			if (terrain.rayMeshTest(rayOrigin, rayDirection,pix)) {
				//var tpick:TerrainPicking = new TerrainPicking(terrain);
				//trace(tpick.getHeight(pix.x,pix.z),pix.y);
				//pix.y = tpick.getHeight(pix.x, pix.z);
				cube.x = pix.x;
				cube.y = pix.y;
				cube.z = pix.z;
			}
			
			
		}
		
		private function getTerrainTexture(c:Class):TextureSet {
			var bmd:BitmapData =  (new c as Bitmap).bitmapData;
			return new TextureSet(bmd);
		}
		
		private function stage_resize(e:Event=null):void 
		{
			view.invalid = true;
			var w:Number = stage.stageWidth;
			var h:Number = stage.stageHeight;
			
			view.camera.perspective.perspectiveFieldOfViewLH(Math.PI / 4, stage.stageWidth / stage.stageHeight, 1, 4000);
		}
		
		private function enterFrame(e:Event):void 
		{
			view.render();
			
			aui.update();
		}
		
		public function get useTexture():Boolean 
		{
			return _useTexture;
		}
		
		public function set useTexture(value:Boolean):void 
		{
			if (value != _useTexture) {
				_useTexture = value;
				material.invalid = true;
				material.textureSets = value?Vector.<TextureSet>([texture]):new Vector.<TextureSet>;
			}
		}
		
	}

}