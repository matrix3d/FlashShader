package 
{
	import com.bit101.components.PushButton;
	import com.bit101.components.VBox;
	import flash.events.Event;
	import gl3d.core.Node3D;
	import gl3d.core.skin.SkinAnimFrameScript;
	import gl3d.core.skin.SkinAnimation;
	import gl3d.core.skin.SkinAnimationCalbak;
	import gl3d.parser.fbx.FbxParser;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestModel extends BaseExample
	{
		private var fbx:FbxParser;
		
		public function TestModel() 
		{
			
		}
		
		override public function initNode():void 
		{
			[Embed(source = "assets/fbx/pearl.fbx", mimeType = "application/octet-stream")]var m1:Class;
			[Embed(source = "assets/fbx/Walking.fbx", mimeType = "application/octet-stream")]var m2:Class;
			[Embed(source = "assets/fbx/Mma Kick.fbx", mimeType = "application/octet-stream")]var m3:Class;
			[Embed(source = "assets/fbx/Idle.fbx", mimeType = "application/octet-stream")]var m4:Class;
			fbx = new FbxParser(new m1);
			fbx.animc.anims[fbx.animc.anims.length-1].name = "TPos";
			fbx.loadAnimation(new FbxParser(new m2));
			fbx.animc.anims[fbx.animc.anims.length-1].name = "Walking";
			fbx.loadAnimation(new FbxParser(new m3));
			fbx.animc.anims[fbx.animc.anims.length-1].name = "Mma Kick";
			fbx.loadAnimation(new FbxParser(new m4));
			fbx.animc.anims[fbx.animc.anims.length-1].name = "Idle";
			
			var node:Node3D = new Node3D;
			node.setScale(.02, .02, .02);
			node.addChild(fbx.rootNode);
			
			var cloned:Node3D = fbx.rootNode.clone();
			node.addChild(cloned);
			cloned.x += 100;
			
			view.scene.addChild(node);
		}
		
		override public function initUI():void 
		{
			var vbox:VBox = new VBox(this);
			vbox.scaleX = vbox.scaleY = 2;
			new PushButton(vbox, 0, 0, "TPos", onA);
			new PushButton(vbox, 0, 0, "Walking", onA);
			new PushButton(vbox, 0, 0, "Mma Kick", onA);
			new PushButton(vbox, 0, 0, "Idle", onA);
		}
		
		private function onA(e:Event):void 
		{
			var name:String = (e.currentTarget as PushButton).label;
			var anim:SkinAnimation = fbx.animc.play(name,.3);
			anim.timeline.clear();
			anim.timeline.addFrameScript(new SkinAnimFrameScript(1,
				function ():void{
					trace(1);
					//fbx.animc.stop();
				}
			));
		}
	}

}