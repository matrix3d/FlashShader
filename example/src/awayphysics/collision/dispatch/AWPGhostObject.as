package awayphysics.collision.dispatch {
	import awayphysics.Away3dObject;
	import AWPC_Run.createGhostObjectInC;
	import awayphysics.collision.shapes.AWPCollisionShape;

	/**
	 *used for create the character controller
	 */
	public class AWPGhostObject extends AWPCollisionObject {
		public function AWPGhostObject(shape : AWPCollisionShape, skin : Away3dObject = null) {
			pointer = createGhostObjectInC(shape.pointer);
			super(shape, skin, pointer);
		}
	}
}