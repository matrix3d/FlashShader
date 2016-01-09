package {
	import awayphysics.Away3dObject;
	import awayphysics.GL3DObject;
	import flash.events.MouseEvent;
	import gl3d.core.Drawable;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.meshs.Meshs;
	import gl3d.meshs.ShapeBuilder;

	import awayphysics.collision.shapes.AWPBoxShape;
	import awayphysics.collision.shapes.AWPConeShape;
	import awayphysics.collision.shapes.AWPCylinderShape;
	import awayphysics.collision.shapes.AWPSphereShape;
	import awayphysics.collision.shapes.AWPStaticPlaneShape;
	import awayphysics.dynamics.AWPDynamicsWorld;
	import awayphysics.dynamics.AWPRigidBody;
	import awayphysics.debug.AWPDebugDraw;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Vector3D;

	public class AwayphysicsBasicTest extends BaseAwayphysics {
		private var _sphereShape : AWPSphereShape;
		private var sphereDrawable:Drawable;
		private var boxDrawable:Drawable;
		override public function initPhys():void 
		{
			super.initPhys();
			
			// create ground shape and rigidbody
			var groundShape : AWPStaticPlaneShape = new AWPStaticPlaneShape(new Vector3D(0, 1, 0));
			var groundNode:Node3D = new Node3D;
			groundNode.drawable = Meshs.cube(1000000, 0, 1000000);
			groundNode.material = new Material;
			physicsRoot.addChild(groundNode);
			var groundRigidbody : AWPRigidBody = new AWPRigidBody(groundShape, new GL3DObject(groundNode), 0);
			physicsWorld.addRigidBody(groundRigidbody);

			// create a wall
			var wallShape : AWPBoxShape = new AWPBoxShape(20000, 2000, 100);
			var wallNode:Node3D = new Node3D;
			wallNode.drawable = Meshs.cube(20000, 2000, 100);
			wallNode.material = new Material;
			physicsRoot.addChild(wallNode);
			var wallRigidbody : AWPRigidBody = new AWPRigidBody(wallShape, new GL3DObject(wallNode), 0);
			physicsWorld.addRigidBody(wallRigidbody);
			wallRigidbody.position = new Vector3D(0, 1000, 2000);
			
			
			// create rigidbody shapes
			_sphereShape = new AWPSphereShape(100);
			sphereDrawable = Meshs.sphere(20,20,100);
			var boxShape : AWPBoxShape = new AWPBoxShape(200, 200, 200);
			boxDrawable = Meshs.cube(200, 200, 200);
			var cylinderShape : AWPCylinderShape = new AWPCylinderShape(100, 200);
			var sb:ShapeBuilder= ShapeBuilder.Cylinder(100, 100, 200);
			var cylinderDrawable:Drawable = Meshs.createDrawable(sb.indexs, sb.vertexs);
			var coneShape : AWPConeShape = new AWPConeShape(100, 200);
			sb= ShapeBuilder.Cylinder(100, 0, 200);
			var coneDrawable:Drawable = Meshs.createDrawable(sb.indexs, sb.vertexs);

			// create rigidbodies
			var body : AWPRigidBody;
			var numx : int = 4;
			var numy : int = 10;
			var numz : int = 1;
			for (var i : int = 0; i < numx; i++ ) {
				for (var j : int = 0; j < numz; j++ ) {
					for (var k : int = 0; k < numy; k++ ) {
						// create boxes
						var node:Node3D = new Node3D;
						node.material = new Material;
						node.material.color.setTo(0, 1, 0);
						node.drawable = boxDrawable;
						physicsRoot.addChild(node);
						
						body = new AWPRigidBody(boxShape, new GL3DObject(node), 1);
						body.friction = .9;
						body.ccdSweptSphereRadius = 0.5;
						body.ccdMotionThreshold = 1;
						body.position = new Vector3D(-1000 + i * 200, 100 + k * 200, j * 200);
						physicsWorld.addRigidBody(body);

						// create cylinders
						node = new Node3D;
						node.material = new Material;
						node.material.color.setTo(0, 0, 1);
						node.drawable = cylinderDrawable;
						physicsRoot.addChild(node);
						body = new AWPRigidBody(cylinderShape, new GL3DObject(node), 1);
						body.friction = .9;
						body.ccdSweptSphereRadius = 0.5;
						body.ccdMotionThreshold = 1;
						body.position = new Vector3D(1000 + i * 200, 100 + k * 200, j * 200);
						physicsWorld.addRigidBody(body);

						// create the Cones
						node = new Node3D;
						node.material = new Material;
						node.material.color.setTo(1, 0, 1);
						node.drawable = coneDrawable;
						physicsRoot.addChild(node);
						body = new AWPRigidBody(coneShape, new GL3DObject(node), 1);
						body.friction = .9;
						body.ccdSweptSphereRadius = 0.5;
						body.ccdMotionThreshold = 1;
						body.position = new Vector3D(i * 200, 100 + k * 230, j * 200);
						physicsWorld.addRigidBody(body);
					}
				}
			}
			stage.addEventListener(MouseEvent.CLICK, stage_click);
		}
		
		private function stage_click(e:MouseEvent):void 
		{
			var rayOrigin:Vector3D = new Vector3D;
			var rayDirection:Vector3D = new Vector3D;
			var pix:Vector3D = new Vector3D;
			view.camera.computePickRayDirectionMouse(mouseX, mouseY, stage.stageWidth, stage.stageHeight, rayOrigin, rayDirection);
			rayOrigin.scaleBy(1/physicsRoot.scaleX);
			
			var impulse : Vector3D = rayDirection;//mpos.subtract(pos);
			impulse.normalize();
			impulse.scaleBy(2000);

			// shoot a sphere
			var node:Node3D = new Node3D;
			node.material = new Material;
			node.material.color.setTo(1, 0, 0);
			node.drawable = sphereDrawable;
			physicsRoot.addChild(node);

			var body : AWPRigidBody = new AWPRigidBody(_sphereShape, new GL3DObject(node), 2);
			body.position = rayOrigin;
			body.ccdSweptSphereRadius = 0.5;
			body.ccdMotionThreshold = 1;
			physicsWorld.addRigidBody(body);
			
			body.applyCentralImpulse(impulse);
		}
		
		
	}
}