package
{
	import com.bit101.components.PushButton;
	import flash.events.Event;
	import gl3d.core.Light;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.meshs.Meshs;
	
	public class TestPointLight extends BaseExample
	{
		public var lightNum:int = 5;
		
		public var button:PushButton;
		
		override public function initUI():void
		{
			button = new PushButton(this, 10, 10, "Reset", onReset);
		}
		
		override public function initNode():void
		{
			//addSky();
			var node:Node3D = new Node3D;
			node.material = new Material;
			node.drawable = Meshs.sphere();
			view.scene.addChild(node);
		}
		
		override public function initLight():void
		{
			var light:Light;
			while (view.lights.length)
			{
				light = view.lights.pop();
				if (light.parent)
				{
					light.parent.removeChild(light);
				}
			}
			var i:int;
			for (i = 0; i < lightNum; i += 1)
			{
				light = new Light(Light.DISTANT);
				light.color.setTo(Math.random(), Math.random(), Math.random());
				light.x = (Math.random() * .5 + 1) * (Math.random() < 0.5 ? -1 : 1);
				light.y = (Math.random() * .5 + 1) * (Math.random() < 0.5 ? -1 : 1);
				light.z = (Math.random() * .5 + 1) * (Math.random() < 0.5 ? -1 : 1);
				view.lights.push(light);
				
				light.distance = light.matrix.position.length+1;
				view.scene.addChild(light);
				light.material = new Material;
				light.material.color.copyFrom(light.color);
				light.drawable = Meshs.sphere();
				light.scaleX = light.scaleY = light.scaleZ = .1;
			}
		}
		
		private function onReset(e:Event):void
		{
			initLight();
		}
	}
}