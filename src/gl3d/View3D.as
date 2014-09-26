package gl3d 
{
	import flash.display.Sprite;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DRenderMode;
	import flash.display3D.Context3DTriangleFace;
	import flash.events.Event;
	/**
	 * ...
	 * @author lizhi
	 */
	public class View3D extends Sprite
	{
		public var context:Context3D;
		public var scene:Node3D = new Node3D;
		public var camera:Camera3D = new Camera3D;
		public var light:Light = new Light;
		public var invalid:Boolean = true;
		public function View3D() 
		{
			scene.addChild(camera);
			scene.addChild(light);
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, stage_context3dCreate);
			stage.stage3Ds[0].requestContext3D(Context3DRenderMode.AUTO);
		}
		
		private function stage_context3dCreate(e:Event):void 
		{
			context = stage.stage3Ds[0].context3D;
			
			context.setCulling(Context3DTriangleFace.NONE);
			context.enableErrorChecking = true;
			//context.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
		}
		
		public function render():void {
			if (context) {
				if(invalid)
					context.configureBackBuffer(stage.stageWidth, stage.stageHeight, 2);
				context.clear();
				scene.update(this,camera);
				context.present();
			}
		}
	}

}