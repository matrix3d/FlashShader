package 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import gl3d.core.Light;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.meshs.Meshs;
	import gl3d.text.Text;
	import gl3d.text.TextLine;
	import gl3d.util.MathUtil;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestText extends BaseExample
	{
		private var text:Text;
		private var bmp:Bitmap = new Bitmap;
		public function TestText() 
		{
		}
		
		override public function initNode():void 
		{
			view.background = 0x888888;
			
			text = new Text(null, 12);
			text.border = true;
			var line:TextLine;
			for (var i:int = 0; i < 1000;i++ ){
				line = new TextLine;
				addText((stage.stageWidth*Math.random()),(stage.stageHeight * Math.random()));
			}
			view.scene.addChild(text);
			addChild(bmp);
			stage.addEventListener(MouseEvent.CLICK, stage_click);
			
			for (i = 0; i < 10;i++ ){
				var cube:Node3D = new Node3D;
				cube.setRotation(Math.random() * 360, Math.random() * 360, Math.random() * 360);
				cube.drawable = Meshs.cube(50, 50, 50);
				cube.material = new Material;
				view.scene.addChild(cube);
				cube.x = stage.stageWidth*Math.random();
				cube.y = stage.stageHeight *Math.random();
			}
		}
		
		private function stage_click(e:MouseEvent):void 
		{
			addText(mouseX, mouseY);
		}
		
		private function addText(x:Number, y:Number):void{
			var line:TextLine = new TextLine(String.fromCharCode(0x4E00 + int(Math.random() * (0x9FFF - 0x4E00))));
			line.x = x;
			line.y = y;
			text.addChild(line);
		}
		
		override public function initCtrl():void 
		{
		}
		
		override public function enterFrame(e:Event):void 
		{
			super.enterFrame(e);	
			bmp.bitmapData = text.material.diffTexture.data as BitmapData;
		}
		
		override protected function stage_resize(e:Event = null):void
		{
			super.stage_resize(e);
			view.camera.perspective.orthoOffCenterRH( 0, stage.stageWidth, stage.stageHeight, 0, -1000, 1000);
		}
		override public function initLight():void {
			lights.push(new Light);
			view.scene.addChild(lights[0]);
			lights[0].x = stage.stageWidth/2;
			lights[0].y = stage.stageHeight/2;
			lights[0].z = 4005;
		}
	}

}