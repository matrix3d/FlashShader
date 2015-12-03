package gl3d.core.renders 
{
	import flash.display.BitmapData;
	import flash.display.Stage3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.CubeTexture;
	import flash.display3D.textures.RectangleTexture;
	import flash.display3D.textures.Texture;
	import flash.geom.Matrix;
	import flash.utils.Dictionary;
	import gl3d.core.Light;
	import gl3d.core.Node3D;
	import flash.display3D.Context3DProfile;
	import flash.display3D.Context3DRenderMode;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import gl3d.core.Camera3D;
	import gl3d.core.renders.GL;
	import gl3d.core.TextureSet;
	import gl3d.core.View3D;
	import gl3d.post.PostEffect;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Stage3DRender extends Render
	{
		public var renderTarget:TextureSet;
		public var stage3d:Stage3D;
		public function Stage3DRender(view:View3D) 
		{
			super(view);
		}
		
		override public function init():void 
		{
			super.init();
			stage3d = view.stage.stage3Ds[view.id];
			stage3d.addEventListener(Event.CONTEXT3D_CREATE, stage_context3dCreate);
			stage3d.addEventListener(ErrorEvent.ERROR, stage3Ds_error);
			//stage.stage3Ds[0].requestContext3D(Context3DRenderMode.AUTO, Context3DProfile.STANDARD);
			var pfs:Vector.<String> = new <String>[Context3DProfile.STANDARD,Context3DProfile.STANDARD_CONSTRAINED,Context3DProfile.BASELINE_EXTENDED,Context3DProfile.BASELINE,Context3DProfile.BASELINE_CONSTRAINED];
			for (var i:int = pfs.length - 1; i >= 0;i-- ) {
				if (pfs[i]==null) {
					pfs.splice(i, 1);
				}
			}
			stage3d.requestContext3DMatchingProfiles(pfs);
		}
		private function stage3Ds_error(e:ErrorEvent):void 
		{
			stage3d.requestContext3D(Context3DRenderMode.AUTO);
		}
		
		private function stage_context3dCreate(e:Event):void 
		{
			gl3d = new GL(stage3d.context3D);
			view.profile = stage3d.context3D.profile;
			view.driverInfo = gl3d.driverInfo;
			if (view.profile==Context3DProfile.STANDARD||view.profile==Context3DProfile.STANDARD_CONSTRAINED) {
				agalVersion = 2;
			}else {
				agalVersion = 1;
			}
		}
		
		override public function render(camera:Camera3D, scene:Node3D):void 
		{
			super.render(camera, scene);
			
			if (gl3d) {
				if(gl3d.driverInfo == "Disposed"){
					view.invalid = true;
					return;
				}
				if (view.invalid) {
					stage3d.x = view.x;
					stage3d.y = view.y;
					gl3d.configureBackBuffer(view.stage3dWidth, view.stage3dHeight, view.antiAlias);
				}
				if (view.posts.length) {
					var len:int = view.posts.length>1?2:1;
					for (var i:int = 0; i < len; i++ ) {
						if (view.invalid||view.postRTTs[i].texture==null) {
							view.postRTTs[i].update(view);
							view.postRTTs[i].texture = gl3d.createRectangleTexture(view.stage3dWidth, view.stage3dHeight,Context3DTextureFormat.BGRA, true);
							view.postRTTs[i].invalid = false;
						}
					}
					renderTarget = view.postRTTs[0];
					//gl3d.setRenderToTexture(view.postRTTs[0].texture, true, view.antiAlias);
				}else {
					renderTarget = null;
					//gl3d.setRenderToBackBuffer();
				}
				if (renderTarget) {
					gl3d.setRenderToTexture(renderTarget.texture, true, view.antiAlias);
				}else {
					gl3d.setRenderToBackBuffer();
				}
				view.invalid = false;
				gl3d.clear((view.background>>16&0xff)/0xff,(view.background>>8&0xff)/0xff,(view.background&0xff)/0xff);
				collects.length = 0;
				gl3d.drawTriangleCounter = 0;
				gl3d.drawCounter = 0;
				collect(scene);
				sort();
				for each(var light:Light in view.lights) {
					if (light.shadowMapEnabled) {
						for each(var node:Node3D in collects) {
							node.update(view);
						}
					}
				}
				
				for each(node in collects) {
					node.update(view);
				}
				if (view.posts.length) {
					for (i = 0; i < view.posts.length; i++ ) {
						var post:PostEffect = view.posts[i];
						post.update(view,i==view.posts.length-1);
						if (len==2) {
							var temp:TextureSet = view.postRTTs[0];
							view.postRTTs[0] = view.postRTTs[1];
							view.postRTTs[1] = temp;
						}
					}
				}
				gl3d.present();
			}
		}
		
	}

}