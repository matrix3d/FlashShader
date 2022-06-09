package
{
	import com.bit101.components.PushButton;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.utils.getTimer;
	import gl3d.core.Camera3D;
	import gl3d.core.Light;
	import gl3d.core.Material;
	import gl3d.core.MaterialBase;
	import gl3d.core.Node3D;
	import gl3d.core.TextureSet;
	import gl3d.meshs.Meshs;
	import gl3d.meshs.Teapot;
	import gl3d.util.Stats;
	
	public class TestShadow extends BaseExample
	{
		public var lightNum:int = 5;
		
		public var button:PushButton;
		private var quats:Array = [];
		private var c2d:Camera3D=new Camera3D;
		override public function initUI():void
		{
			button = new PushButton(this, 10, 10, "Reset", onReset);
		}
		
		public function TestShadow() 
		{
			super();
		}
		
		override public function initNode():void
		{
			view.enableErrorChecking = true;
			addSky();
			var node:Node3D = new Node3D("sphere");
			node.material = new Material;
			node.material.ambient.setTo(.3, .3, .3);
			node.material.receiveShadows = true;
			node.material.castShadow = true;
			node.drawable = Meshs.cube();
			node.y =-.7;
			view.scene.addChild(node);
			
			var node:Node3D = new Node3D("sphere");
			node.material = new Material;
			node.material.ambient.setTo(.3, .3, .3);
			node.material.receiveShadows = true;
			node.material.castShadow = true;
			node.drawable = Meshs.sphere();
			node.setScale(3, 3, 3);
			node.y =2;
			node.x = 1.5;
			view.scene.addChild(node);
			
			
			var node:Node3D = new Node3D("sphere");
			node.material = new Material;
			node.material.ambient.setTo(.3, .3, .3);
			node.material.receiveShadows = true;
			node.material.castShadow = true;
			node.drawable = Meshs.sphere();
			node.y =-0.3;
			node.x = 1.5;
			view.scene.addChild(node);
			
			var plane:Node3D = new Node3D("plane");
			plane.material = new Material;
			
			plane.material.ambient.setTo(.5, .5, .5);
			plane.material.castShadow = true;
			plane.material.receiveShadows = true;
			plane.drawable = Meshs.plane(30);
			//plane.drawable = Meshs.cube(30, 30, 0.01);
			plane.setRotation(90, 0, 0);
			plane.y = -1.5;
			view.scene.addChild(plane);
			//addChild(new Stats(view));
		}
		
		override protected function stage_resize(e:Event = null):void 
		{
			super.stage_resize(e);
			c2d.orthoOffCenterLH( 0, stage.stageWidth, -stage.stageHeight ,0, -1000, 1000);
		}
		
		private var inum:int = 0;
		override public function initLight():void
		{
			trace("initlight");
			inum++;
			var light:Light;
			while (lights.length)
			{
				light = lights.pop();
				if (light.parent)
				{
					light.parent.removeChild(light);
				}
				light.dispose();
			}
			while (quats.length)
			{
				var quat:Node3D = quats.pop();
				if (quat.parent)
				{
					quat.parent.removeChild(quat);
				}
			}
			var i:int;
			lightNum =  1//2 + 2 * Math.random();
			for (i = 0; i < lightNum; i += 1)
			{
				light = new RotLight();
				light.x = light.y = light.z = 0;
				light.y = 100;
				light.x = 100;
				light.name = "light" + i;
				light.shadowMapEnabled = true;
				lights.push(light);
				view.scene.addChild(light);
				
				var size:int = 100;
				quat = new Node3D(inum+"quat"+i);
				quat.material = new Material;
				if(light.shadowMapEnabled){
				quat.material.diffTexture = new TextureSet(new BitmapData(1,1,false,0xffffff*Math.random()))//light.shadowMap;
				quat.material.diffTexture = light.shadowMap;
				}
				quat.material.materialCamera = c2d;
				quat.material.lightAble = false;
				quat.material.castShadow = false;
				quat.drawable = Meshs.plane(size);
				quat.x = size + i * ((size*2)+1);
				quat.y = -size;
				view.scene.addChild(quat);
				quats.push(quat);
			}
		}
		
		override public function enterFrame(e:Event):void 
		{
			//trace("-----------");
			for each(var light:RotLight in lights) {
				//light.matrix.appendRotation(light.speed, light.axis);
				//light.x = light.z = 0;
				//light.y = 2.5;
				light.x = 100 * Math.sin(getTimer() / 1000);
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
import gl3d.meshs.Teapot;

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
		
		//color.setTo(Math.random(), Math.random(), Math.random());
		material = new Material;
		material.castShadow = true;
		material.receiveShadows = true;
		material.lightAble = true;
		material.color.copyFrom(color);
		drawable = Meshs.sphere();
		scaleX = scaleY = scaleZ = .5;
	}
}