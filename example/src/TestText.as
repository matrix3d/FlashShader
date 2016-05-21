package 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import gl3d.core.Node3D;
	import gl3d.meshs.Meshs;
	import gl3d.text.Text;
	import gl3d.text.TextLine;
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
			
			text = new Text(null,30);
			text.scaleY =-1;
			var line:TextLine;
			for (var i:int = 0; i < 100;i++ ){
				line = new TextLine;
				//u4E00 - u9FFF
				var r:Number = Math.random();
				line.text = String.fromCharCode(0x4E00 + int(Math.random()*(0x9FFF-0x4E00)));
				line.x = int(stage.stageWidth*Math.random());
				line.y = int(stage.stageHeight * Math.random());
				line.setRotation(360 * Math.random(), 360 * Math.random(), 360 * Math.random());
				text.addChild(line);
			}
			view.scene.addChild(text);
			//addChild(bmp);
		}
		
		override public function initCtrl():void 
		{
		}
		
		override public function enterFrame(e:Event):void 
		{
			text.x = mouseX;
			text.y = stage.stageHeight - mouseY;
			for each(var line:TextLine in text.children){
				line.matrix.appendRotation(1, Vector3D.Y_AXIS,line.matrix.position);
				line.updateTransforms();
			}
			super.enterFrame(e);
			
			bmp.bitmapData = text.material.diffTexture.data as BitmapData;
		}
		
		override protected function stage_resize(e:Event = null):void
		{
			super.stage_resize(e);
			view.camera.perspective.orthoOffCenterLH( 0, stage.stageWidth, 0, stage.stageHeight, -1000, 1000);
		}
	}

}