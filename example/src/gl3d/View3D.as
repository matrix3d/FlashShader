package gl3d 
{
	import flash.display.Sprite;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DRenderMode;
	import flash.display3D.Context3DTriangleFace;
	import flash.events.Event;
	import gl3d.ctrl.Ctrl;
	import gl3d.post.PostEffect;
	import gl3d.util.Utils;
	/**
	 * ...
	 * @author lizhi
	 */
	public class View3D extends Sprite
	{
		public var context:Context3D;
		public var scene:Node3D = new Node3D("scene");
		public var camera:Camera3D = new Camera3D;
		public var light:Light = new Light;
		public var invalid:Boolean = true;
		public var collects:Vector.<Node3D> = new Vector.<Node3D>;
		public var ctrls:Vector.<Ctrl> = new Vector.<Ctrl>;
		public var posts:Vector.<PostEffect> = new Vector.<PostEffect>;
		public var postRTTs:Vector.<TextureSet> = Vector.<TextureSet>([new TextureSet,new TextureSet]);
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
			context.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
		}
		
		public function updateCtrl():void {
			for each(var ctrl:Ctrl in ctrls) {
				ctrl.update();
			}
		}
		
		public function render():void {
			if (context) {
				if(invalid)
					context.configureBackBuffer(stage.stageWidth, stage.stageHeight, 2);
				if (posts.length) {
					var len:int = posts.length>1?2:1;
					for (var i:int = 0; i < len;i++ ) {
						postRTTs[i].update(context);
					}
					context.setRenderToTexture(postRTTs[0].texture, true, 2);
				}else {
					context.setRenderToBackBuffer();
				}
				context.clear();
				collects.length = 0;
				collect(scene);
				for each(var node:Node3D in collects) {
					node.update(this);
				}
				if (posts.length) {
					for (i = 0; i < posts.length; i++ ) {
						var post:PostEffect = posts[i];
						post.update(this,i==posts.length-1);
						if (len==2) {
							var temp:TextureSet = postRTTs[0];
							postRTTs[0] = postRTTs[1];
							postRTTs[1] = temp;
						}
					}
				}
				context.present();
			}
		}
		
		private function collect(node:Node3D):void {
			collects.push(node);
			for each(var c:Node3D in node.children) {
				collect(c);
			}
		}
	}

}