package 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import gl3d.core.Light;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.meshs.Meshs;
	import gl3d.text.Text;
	import gl3d.text.TextField;
	import flash.text.engine.TextLine;
	import gl3d.util.MathUtil;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestText extends BaseExample
	{
		private var text:Text;
		private var bmp:Bitmap = new Bitmap;
		private var line:gl3d.text.TextField;
		public function TestText() 
		{
		}
		
		override public function initNode():void 
		{
			view.background = 0x888888;
			
			text = new Text();
			text.border = false;
			var line:gl3d.text.TextField;
			for (var i:int = 0; i < 1;i++ ){
				line = new gl3d.text.TextField;
				addText((stage.stageWidth*Math.random()),(stage.stageHeight * Math.random()));
			}
			view.scene.addChild(text);
			addChild(bmp);
			stage.addEventListener(MouseEvent.CLICK, stage_click);
			
			for (i = 0; i < 0;i++ ){
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
			line = new gl3d.text.TextField("1\r2\n3456789abcdefghi大小多少人口手上中下日月水火山石田土木竹迷住刀工车舟", "宋体", 20 * Math.random() + 10,0xffffff * Math.random());
			//line.autoSize = TextFieldAutoSize.LEFT;
			line.wordWrap = true;
			//line = new gl3d.text.TextLine(String.fromCharCode(0x4E00 + int(Math.random() * (0x9FFF - 0x4E00))) + "123abgA", "宋体", 20 * Math.random() + 10,0xffffff * Math.random());
			//line.htmlText = "<c><font size='22' color='#ff0000'>d</font>   <font size='300'>d</font></c>";
			//line.appendText(String.fromCharCode(0x4E00 + int(Math.random() * (0x9FFF - 0x4E00))) + "123a b gA", "宋体", 20 * Math.random() + 30,0xffffff * Math.random());
			line.x = x;
			//line.rotationX = 360 * Math.random();
			//line.rotationY = 360 * Math.random();
			//line.rotationZ = 360 * Math.random();
			line.y = y;
			text.addChild(line);
			/*var tf:TextField = new TextField;
			tf.defaultTextFormat = new TextFormat("_serif");
			tf.text = line.text;
			addChild(tf);
			tf.x = x;
			tf.y = y + 20;
			
			var block:TextBlock = new TextBlock;
			var te:TextElement = new TextElement(line.text, new ElementFormat(new FontDescription("_serif"), 12,0xffffff));
			block.content = te;
			var textline:flash.text.engine.TextLine = block.createTextLine();
			addChild(textline);
			textline.x = x;
			textline.y = y + 60;*/
		}
		
		override public function initCtrl():void 
		{
		}
		
		override public function enterFrame(e:Event):void 
		{
			//line.rotationZ++;
			//line.textMatrixDirty = true;
			//line.rotationX+=.5;
			super.enterFrame(e);
			if(text.material.diffTexture)
			bmp.bitmapData = text.material.diffTexture.data as BitmapData;
		}
		
		override protected function stage_resize(e:Event = null):void
		{
			super.stage_resize(e);
			view.camera.orthoOffCenterRH( 0, stage.stageWidth, stage.stageHeight, 0, -1000, 1000);
		}
		override public function initLight():void {
			lights.push(new Light);
			view.scene.addChild(lights[0]);
			lights[0].x = stage.stageWidth/2;
			lights[0].y = stage.stageHeight/2;
			lights[0].z = 100;
		}
	}

}