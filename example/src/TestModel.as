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
			[Embed(source = "assets/fbx/Standing 2H Magic Area Attack 02 (2).fbx", mimeType = "application/octet-stream")]var m1:Class;
			[Embed(source = "assets/fbx/Dying.fbx", mimeType = "application/octet-stream")]var m2:Class;
			fbx = new FbxParser(new m1);
			fbx.loadAnimation(new FbxParser(new m2));
			
			if(fbx.animc.anims[1].name=="mixamo.com")
			fbx.animc.anims[1].name = "a1";
			if(fbx.animc.anims[2].name=="mixamo.com")
			fbx.animc.anims[2].name = "a1";
			var node:Node3D = new Node3D;
			node.setScale(.01, .01, .01);
			node.addChild(fbx.rootNode);
			
			view.scene.addChild(node);
		}
		
		override public function initUI():void 
		{
			var vbox:VBox = new VBox(this);
			new PushButton(vbox, 0, 0, "mixamo.com", onA);
			new PushButton(vbox, 0, 0, "a1", onA);
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