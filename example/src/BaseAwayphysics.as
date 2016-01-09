package 
{
	import awayphysics.dynamics.AWPDynamicsWorld;
	import flash.events.Event;
	import gl3d.core.Node3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class BaseAwayphysics extends BaseExample
	{
		public var physicsWorld : AWPDynamicsWorld;
		public var timeStep : Number = 1.0 / 60;
		public var physicsRoot:Node3D = new Node3D;
		public function BaseAwayphysics() 
		{
			initPhys();
		}
		
		override public function initNode():void 
		{
			addSky();
		}
		
		public function initPhys():void 
		{
			view.scene.addChild(physicsRoot);
			physicsRoot.scaleX=
			physicsRoot.scaleY=
			physicsRoot.scaleZ = 1 / 500;
			// init the physics world
			physicsWorld = AWPDynamicsWorld.getInstance();
			physicsWorld.initWithDbvtBroadphase();

		}
		override public function enterFrame(e:Event):void 
		{
			physicsWorld.step(timeStep, 1, timeStep);
			super.enterFrame(e);
		}
		
	}

}