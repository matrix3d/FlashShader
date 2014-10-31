package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import gl3d.Material;
	import gl3d.meshs.Meshs;
	import gl3d.Node3D;
	import gl3d.pick.TerrainPicking;
	import gl3d.shaders.TerrainPhongGLShader;
	import gl3d.TextureSet;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestTerrain extends BaseExample
	{
		private var terrain:Node3D;
		private var cube:Node3D;
		public function TestTerrain() 
		{
		}
		
		override public function initNode():void {
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
			
			var texture:TextureSet=new TextureSet(bmd);
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
			stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_click);
		}
		
		private function stage_click(e:MouseEvent):void 
		{
			var rayOrigin:Vector3D = new Vector3D;
			var rayDirection:Vector3D = new Vector3D;
			var pix:Vector3D = new Vector3D;
			view.camera.computePickRayDirectionMouse(mouseX, mouseY, stage.stageWidth, stage.stageHeight, rayOrigin, rayDirection);
			
			if (terrain.rayMeshTest(rayOrigin, rayDirection,pix)) {
				cube.x = pix.x;
				cube.y = pix.y;
				cube.z = pix.z;
			}
		}
		
		private function getTerrainTexture(c:Class):TextureSet {
			var bmd:BitmapData =  (new c as Bitmap).bitmapData;
			return new TextureSet(bmd);
		}
		
	}

}