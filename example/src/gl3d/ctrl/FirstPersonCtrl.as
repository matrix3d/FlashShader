package gl3d.ctrl
{
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;
	import gl3d.core.Node3D;
	
	/**
	 * ...
	 * @author lizhi
	 */
	public class FirstPersonCtrl extends Ctrl
	{
		private var node:Node3D;
		private var stage:Stage;
		private var keydownMap:Object = {};
		public var speed:Number = .3;
		public var rotSpeed:Number = .2;
		private var helpMatrix:Matrix3D=new Matrix3D;
		private var helpV:Vector3D=new Vector3D;
		private var lastPos:Point;
		
		public var rotation:Vector3D=new Vector3D;
		private var lastRotation:Vector3D;
		public var position:Vector3D=new Vector3D;
		private var isMouseDown:Boolean=false;
		
		public function FirstPersonCtrl(node:Node3D, stage:Stage)
		{
			position.copyFrom(node.matrix.position);
			rotation.setTo(node.rotationX, node.rotationY, node.rotationZ);
			this.stage = stage;
			this.node = node;
			stage.addEventListener(MouseEvent.MOUSE_DOWN, stage_mouseDown);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, stage_keyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, stage_keyUp);
		}
		
		private function stage_keyUp(e:KeyboardEvent):void
		{
			keydownMap[e.keyCode] = false;
		}
		
		private function stage_keyDown(e:KeyboardEvent):void
		{
			keydownMap[e.keyCode] = true;
		}
		
		private function stage_mouseDown(e:MouseEvent):void
		{
			isMouseDown=true;
			lastPos = new Point(stage.mouseX, stage.mouseY);
			lastRotation = rotation.clone();
			stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUp);
		}
		
		private function stage_mouseUp(e:MouseEvent):void
		{
			isMouseDown=false;
			stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUp);
		}
		
		override public function update():void
		{
			if(isMouseDown){
				rotation.y = lastRotation.y + (stage.mouseX - lastPos.x)/5;
				rotation.x = lastRotation.x + (stage.mouseY - lastPos.y)/5;
			}
			helpMatrix.identity();
			helpMatrix.appendRotation(rotation.x, Vector3D.X_AXIS);
			helpMatrix.appendRotation(rotation.y, Vector3D.Y_AXIS);
			helpV.x = helpV.y =helpV.z = 0;
			if (keydownMap[Keyboard.W]) {
				helpV.z += speed;
			}else if (keydownMap[Keyboard.S]) {
				helpV.z -= speed;
			}
			if (keydownMap[Keyboard.A]) {
				helpV.x -= speed;
			}else if (keydownMap[Keyboard.D]) {
				helpV.x += speed;
			}
			helpV = helpMatrix.transformVector(helpV);
			position.x += helpV.x;
			position.y += helpV.y;
			position.z += helpV.z;
			helpMatrix.appendTranslation(position.x, position.y, position.z);
			node.matrix.copyFrom(helpMatrix);
			node.matrix = node.matrix;
		}
	}

}