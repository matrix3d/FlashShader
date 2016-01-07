package
{
	import com.bit101.components.PushButton;
	import flash.events.Event;
	import gl3d.core.Light;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.meshs.Meshs;
	import gl3d.meshs.Teapot;
	
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
			addSky();
			var node:Node3D = new Node3D;
			node.material = new Material;
			node.drawable = Meshs.sphere()
			view.scene.addChild(node);
		}
		
		override public function initLight():void
		{
			var light:Light;
			while (lights.length)
			{
				light = lights.pop();
				if (light.parent)
				{
					light.parent.removeChild(light);
				}
			}
			var i:int;
			lightNum = 3 + 3 * Math.random();
			for (i = 0; i < lightNum; i += 1)
			{
				light = new RotLight();
				lights.push(light);
				view.scene.addChild(light);
			}
		}
		
		override public function enterFrame(e:Event):void 
		{
			for each(var light:RotLight in lights) {
				light.matrix.appendRotation(light.speed, light.axis);
				light.updateTransforms();
			}
			super.enterFrame(e);
		}
		
		private function onReset(e:Event):void
		{
			initLight();
		}
	}
}
import flash.geom.Matrix3D;
import flash.geom.Vector3D;
import gl3d.core.Light;
import gl3d.core.Material;
import gl3d.meshs.Meshs;

class RotLight extends Light {
	public var axis:Vector3D;
	public var speed:Number;
	public function RotLight() 
	{
		super(Light.DISTANT);
		speed = (Math.random() - .5) * 2;
		var m:Matrix3D = new Matrix3D;
		var r:Number = 360 * Math.random();
		m.appendRotation(r, Vector3D.X_AXIS);
		r = 360 * Math.random();
		m.appendRotation(r, Vector3D.Y_AXIS);
		r = 360 * Math.random();
		m.appendRotation(r, Vector3D.Z_AXIS);
		
		var pos:Vector3D = m.transformVector(Vector3D.X_AXIS);
		axis = m.transformVector(Vector3D.Z_AXIS);
		pos.scaleBy(1.5 + 1.5 * Math.random());
		x = pos.x;
		y = pos.y;
		z = pos.z;
		
		color.setTo(Math.random(), Math.random(), Math.random());
		material = new Material;
		material.color.copyFrom(color);
		drawable = Meshs.sphere();
		scaleX = scaleY = scaleZ = .1;
	}
}