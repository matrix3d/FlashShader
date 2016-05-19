package {
	import awayphysics.collision.dispatch.AWPCollisionObject;
	import awayphysics.collision.shapes.*;
	import awayphysics.dynamics.*;
	import awayphysics.dynamics.vehicle.*;
	import awayphysics.debug.AWPDebugDraw;
	import awayphysics.GL3DObject;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import gl3d.core.Drawable;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.core.TextureSet;
	import gl3d.ctrl.Ctrl;
	import gl3d.ctrl.FirstPersonCtrl;
	import gl3d.ctrl.FollowCtrl;
	import gl3d.meshs.Meshs;
	import gl3d.meshs.ShapeBuilder;
	import gl3d.shaders.TerrainPhongGLShader;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Vector3D;
	import flash.net.URLRequest;
	import flash.ui.Keyboard;

	public class AwayphysicsBvhTriangleMeshCarTest extends BaseAwayphysics {
		private var car : AWPRaycastVehicle;
		private var _engineForce : Number = 0;
		private var _breakingForce : Number = 0;
		private var _vehicleSteering : Number = 0;
		private var keyRight : Boolean = false;
		private var keyLeft : Boolean = false;
		private var player:Node3D = new Node3D;
		private var carnode:Node3D;
		public function AwayphysicsBvhTriangleMeshCarTest() {
		}
		
		override public function initNode():void 
		{
			addSky();
		}

		override public function initPhys() : void {
			super.initPhys();
			physicsRoot.scaleX =
			physicsRoot.scaleY =
			physicsRoot.scaleZ = 1 / 100;
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			
			onSceneResourceComplete();
			onCarResourceComplete();
		}
		
		private function getTerrainTexture(c:Class):TextureSet {
			var bmd:BitmapData =  (new c as Bitmap).bitmapData;
			return new TextureSet(bmd);
		}

		private function onSceneResourceComplete() : void {
			// create triangle mesh shape
			
			[Embed(source = "assets/unityterraintexture/Cliff (Layered Rock).jpg")]var c0:Class;
			[Embed(source = "assets/unityterraintexture/GoodDirt.jpg")]var c1:Class;
			[Embed(source = "assets/unityterraintexture/Grass (Hill).jpg")]var c2:Class;
			[Embed(source = "assets/unityterraintexture/Grass&Rock.jpg")]var c3:Class;
			
			var bmd:BitmapData = new BitmapData(128, 128, false, 0xff0000);
			bmd.perlinNoise(3, 3, 10, 1, false, false);
			var byte:ByteArray = bmd.getPixels(bmd.rect);
			for (var i:int = 0; i < byte.length;i+=4 ) {
				var a:uint = byte[i];
				var r:uint = byte[i+1];
				var g:uint = byte[i+2];
				var b:uint = byte[i + 3];
				var rgb:uint = r + g + b;
				if (rgb > 0xff) {
					b = 0;
				}
				rgb = r + g;
				if (rgb > 0xff) {
					g = 0;
				}
				byte[i + 1] = r;
				byte[i + 2] = g;
				byte[i + 3] = b
			}
			byte.position = 0;
			bmd.setPixels(bmd.rect, byte);
			var texture:TextureSet=new TextureSet(bmd);
			
			var node:Node3D = new Node3D;
			node.drawable = Meshs.terrain(64, new Vector3D(100000, 100000, 100000));
			node.material = new Material;
			node.material.diffTexture = texture;
			node.material.terrainTextureSets = [getTerrainTexture(c0), getTerrainTexture(c1), getTerrainTexture(c2), getTerrainTexture(c3)];
			node.material.shader = new TerrainPhongGLShader();
			physicsRoot.addChild(node);
			
			var sceneShape : AWPBvhTriangleMeshShape = new AWPBvhTriangleMeshShape(node.drawable.index.data,node.drawable.pos.data);
			var sceneBody : AWPRigidBody = new AWPRigidBody(sceneShape, null, 0);
			physicsWorld.addRigidBody(sceneBody);

			// create rigidbody shape
			var boxShape : AWPBoxShape = new AWPBoxShape(200, 200, 200);
			var boxDrawable:Drawable = Meshs.cube(200, 200, 200);
			
			// create rigidbodies
			var body : AWPRigidBody;
			var numx : int = 10;
			var numy : int = 5;
			var numz : int = 1;
			for (i = 0; i < numx; i++ ) {
				for (var j : int = 0; j < numz; j++ ) {
					for (var k : int = 0; k < numy; k++ ) {
						// create boxes
						node = new Node3D;
						node.material = new Material;
						node.material.color.setTo(0, 0,1);
						node.drawable = boxDrawable;
						physicsRoot.addChild(node);
						
						body = new AWPRigidBody(boxShape, new GL3DObject(node), 1);
						body.friction = .9;
						body.position = new Vector3D(-1500 + i * 200, 200 + k * 200, 1000 + j * 200);
						physicsWorld.addRigidBody(body);
					}
				}
			}
		}

		private function onCarResourceComplete() : void {
			// create the chassis body
			var css:Array = createCarShape();
			carnode=css[1]
			physicsRoot.addChild(carnode);
			view.ctrls = Vector.<Ctrl>([new FollowCtrl(player,view.camera)]);
			var carShape : AWPCompoundShape = css[0];
			var carBody : AWPRigidBody = new AWPRigidBody(carShape, new GL3DObject(carnode), 1200);
			carBody.activationState = AWPCollisionObject.DISABLE_DEACTIVATION;
			carBody.friction = 0.9;
			carBody.linearDamping = 0.1;
			carBody.angularDamping = 0.1;
			carBody.position = new Vector3D(0, 300, -1000);
			physicsWorld.addRigidBody(carBody);

			// create vehicle
			var turning : AWPVehicleTuning = new AWPVehicleTuning();
			turning.frictionSlip = 2;
			turning.suspensionStiffness = 100;
			turning.suspensionDamping = 0.85;
			turning.suspensionCompression = 0.83;
			turning.maxSuspensionTravelCm = 20;
			turning.maxSuspensionForce = 10000;
			car = new AWPRaycastVehicle(turning, carBody);
			physicsWorld.addVehicle(car);

			// add four wheels
			car.addWheel(createWheelNode(60), new Vector3D(-110, 80, 170), new Vector3D(0, -1, 0), new Vector3D(-1, 0, 0), 40, 60, turning, true);
			car.addWheel(createWheelNode(60), new Vector3D(110, 80, 170), new Vector3D(0, -1, 0), new Vector3D(-1, 0, 0), 40, 60, turning, true);
			car.addWheel(createWheelNode(60), new Vector3D(-110, 90, -210), new Vector3D(0, -1, 0), new Vector3D(-1, 0, 0), 40, 60, turning, false);
			car.addWheel(createWheelNode(60), new Vector3D(110, 90, -210), new Vector3D(0, -1, 0), new Vector3D(-1, 0, 0), 40, 60, turning, false);

			for (var i:int = 0; i < car.getNumWheels(); i++) {
				var wheel : AWPWheelInfo = car.getWheelInfo(i);
				wheel.wheelsDampingRelaxation = 4.5;
				wheel.wheelsDampingCompression = 4.5;
				wheel.suspensionRestLength1 = 20;
				wheel.rollInfluence = 0.01;
			}
		}
		
		private function createWheelNode(r:Number):GL3DObject {
			var node:Node3D = new Node3D;
			node.material = new Material;
			node.material.diffTexture = texture;
			node.material.color.setTo(.1, .1, .1);
			var sb:ShapeBuilder = ShapeBuilder.Torus(r/2, r/2);
			var wp:Node3D = new Node3D;
			node.drawable = Meshs.createDrawable(sb.indexs, sb.vertexs);
			wp.addChild(node);
			node.setRotation(0,0,90);
			physicsRoot.addChild(wp);
			return new GL3DObject(wp);
		}

		// create car chassis shape
		private function createCarShape() : Array {
			var boxShape1 : AWPBoxShape = new AWPBoxShape(260, 60, 570);
			var boxShape2 : AWPBoxShape = new AWPBoxShape(240, 70, 300);

			var carShape : AWPCompoundShape = new AWPCompoundShape();
			carShape.addChildShape(boxShape1, new Vector3D(0, 100, 0), new Vector3D());
			carShape.addChildShape(boxShape2, new Vector3D(0, 150, -30), new Vector3D());
			
			var node:Node3D = new Node3D;
			var node1:Node3D = new Node3D;
			node1.material = new Material;
			node1.material.color.setTo(1, 0, 0);
			node1.drawable = Meshs.cube(260, 60, 570);
			node1.y = 100;
			node.addChild(node1);
			node1 = new Node3D;
			node1.material = new Material;
			node1.material.color.setTo(1, 0, 0);
			node1.drawable = Meshs.cube(240, 70, 300);
			node1.y = 150;
			node1.z = -30;
			node.addChild(node1);
			
			return [carShape,node];
		}

		private function keyDownHandler(event : KeyboardEvent) : void {
			switch(event.keyCode) {
				case Keyboard.UP:
					_engineForce = 2500;
					_breakingForce = 0;
					break;
				case Keyboard.DOWN:
					_engineForce = -2500;
					_breakingForce = 0;
					break;
				case Keyboard.LEFT:
					keyLeft = true;
					keyRight = false;
					break;
				case Keyboard.RIGHT:
					keyRight = true;
					keyLeft = false;
					break;
				case Keyboard.SPACE:
					_breakingForce = 80;
					_engineForce = 0;
			}
		}

		private function keyUpHandler(event : KeyboardEvent) : void {
			switch(event.keyCode) {
				case Keyboard.UP:
					_engineForce = 0;
					break;
				case Keyboard.DOWN:
					_engineForce = 0;
					break;
				case Keyboard.LEFT:
					keyLeft = false;
					break;
				case Keyboard.RIGHT:
					keyRight = false;
					break;
				case Keyboard.SPACE:
					_breakingForce = 0;
			}
		}

		override public function enterFrame(e:Event):void 
		{
			super.enterFrame(e);
			if (keyLeft) {
				_vehicleSteering -= 0.05;
				if (_vehicleSteering < -Math.PI / 6) {
					_vehicleSteering = -Math.PI / 6;
				}
			}
			if (keyRight) {
				_vehicleSteering += 0.05;
				if (_vehicleSteering > Math.PI / 6) {
					_vehicleSteering = Math.PI / 6;
				}
			}

			if (car) {
				// control the car
				car.applyEngineForce(_engineForce, 0);
				car.setBrake(_breakingForce, 0);
				car.applyEngineForce(_engineForce, 1);
				car.setBrake(_breakingForce, 1);
				car.applyEngineForce(_engineForce, 2);
				car.setBrake(_breakingForce, 2);
				car.applyEngineForce(_engineForce, 3);
				car.setBrake(_breakingForce, 3);

				car.setSteeringValue(_vehicleSteering, 0);
				car.setSteeringValue(_vehicleSteering, 1);
				_vehicleSteering *= 0.9;
			}
			player.x = carnode.x *physicsRoot.scaleX;
			player.y = carnode.y*physicsRoot.scaleX;
			player.z = carnode.z*physicsRoot.scaleX;
			var rot:Vector3D = carnode.getRotation();
			player.setRotation(rot.x, rot.y, rot.z);
		}
		
		override public function initCtrl():void 
		{
			
		}
	}
}