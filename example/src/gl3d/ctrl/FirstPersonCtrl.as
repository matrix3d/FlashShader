package gl3d.ctrl
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;
	import gl3d.core.Node3D;
	import gl3d.events.GLTouchEvent;
	
	/**
	 * ...
	 * @author lizhi
	 */
	public class FirstPersonCtrl extends Ctrl
	{
		private var node:Node3D;
		private var stage:Stage;
		private var keydownMap:Object = {};
		public var speed:Number = 2.3;
		public var rotSpeed:Number = .2;
		private var helpMatrix:Matrix3D=new Matrix3D;
		private var helpV:Vector3D=new Vector3D;
		private var lastPos:Point;
		
		public var rotation:Vector3D=new Vector3D;
		private var lastRotation:Vector3D;
		public var position:Vector3D=new Vector3D;
		private var isMouseDown:Boolean=false;
		public var movementFunc:Function;//start end -> end
		public var inputSpeed:Vector3D;
		
		private var nowMouseDownEvent:Event;
		private var stagePos:Point=new Point
		public function FirstPersonCtrl(node:Node3D, stage:Stage)
		{
			position.copyFrom(node.matrix.position);
			rotation.copyFrom(node.getRotation());//.setTo(node.rotationX*180/Math.PI, node.rotationY*180/Math.PI, node.rotationZ*180/Math.PI);
			this.stage = stage;
			this.node = node;
			stage.addEventListener(GLTouchEvent.TOUCH_BEGIN, stage_mouseDown);
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
		
		private function stage_mouseDown(e:Event):void
		{
			nowMouseDownEvent = e;
			if(e.target is Stage){
				isMouseDown = true;
				stagePos = GLTouchEvent.getMousePos(e);
				lastPos = GLTouchEvent.getMousePos(e);
				lastRotation = rotation.clone();
				stage.addEventListener(GLTouchEvent.TOUCH_END, stage_mouseUp);
				stage.addEventListener(GLTouchEvent.TOUCH_MOVE, stage_touchMove);
			}
		}
		
		private function stage_touchMove(e:Event):void 
		{
			if (GLTouchEvent.isSameTouch(nowMouseDownEvent, e)) {
				stagePos = GLTouchEvent.getMousePos(e);
			}
		}
		
		private function stage_mouseUp(e:Event):void
		{
			if (GLTouchEvent.isSameTouch(nowMouseDownEvent, e)) {
				isMouseDown=false;
				stage.removeEventListener(GLTouchEvent.TOUCH_END, stage_mouseUp);
				stage.removeEventListener(GLTouchEvent.TOUCH_MOVE, stage_touchMove);
			}
		}
		
		override public function update():void
		{
			if(isMouseDown){
				rotation.y = lastRotation.y + (stagePos.x - lastPos.x)*rotSpeed;
				rotation.x = lastRotation.x + (stagePos.y - lastPos.y)*rotSpeed;
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
			if (inputSpeed) {
				inputSpeed.scaleBy(speed);
				helpV.x += inputSpeed.x;
				helpV.z -= inputSpeed.y;
			}
			
			helpV = helpMatrix.transformVector(helpV);
			if (movementFunc!=null) {
				position.copyFrom(movementFunc(position,position.clone().add(helpV)));
			}else {
				position.x += helpV.x;
				position.y += helpV.y;
				position.z += helpV.z;
			}
			
			helpMatrix.appendTranslation(position.x, position.y, position.z);
			node.matrix.copyFrom(helpMatrix);
			node.matrix = node.matrix;
		}
	}

}