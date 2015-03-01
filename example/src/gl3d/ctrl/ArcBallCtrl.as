package gl3d.ctrl 
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
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
	public class ArcBallCtrl extends Ctrl
	{
		private var helpMatrix:Matrix3D = new Matrix3D;
		private var keydownMap:Object = {};
		public var rotSpeed:Number = .1;
		public var speed:Number = 1;
		public var inputSpeed:Vector3D;
		public var rotation:Vector3D=new Vector3D;
		private var lastRotation:Vector3D;
		public var position:Vector3D=new Vector3D;
		private var node:Node3D;
		private var stage:Stage;
		private var nowMouseDownEvent:Event;
		private var stagePos:Point=new Point
		private var lastPos:Point;
		private var distancePos:Point=new Point;
		private var lastDistancePos:Point=new Point;
		public var distance:Number = 10;
		public var lookat:Vector3D = new Vector3D();
		private var helpV:Vector3D = new Vector3D;
		private var isMouseDown:Boolean=false;
		public function ArcBallCtrl(node:Node3D,stage:Stage) 
		{
			position.copyFrom(node.matrix.position);
			rotation.copyFrom(node.getRotation());//.setTo(node.rotationX*180/Math.PI, node.rotationY*180/Math.PI, node.rotationZ*180/Math.PI);
			lastRotation = rotation.clone();
			
			this.stage = stage;
			this.node = node;
			stage.addEventListener(GLTouchEvent.TOUCH_BEGIN, stage_mouseDown);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, stage_mouseWheel);
			
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
		
		private function stage_mouseWheel(e:MouseEvent):void 
		{
			distance-= e.delta;
		}
		
		private function stage_mouseDown(e:Event):void
		{
			isMouseDown = true;
			nowMouseDownEvent = e;
			if(e.target is Stage){
				stagePos = GLTouchEvent.getMousePos(e);
				lastPos = GLTouchEvent.getMousePos(e);
				distancePos.setTo(0, 0);
				lastRotation = rotation.clone();
				stage.addEventListener(GLTouchEvent.TOUCH_END, stage_mouseUp);
				stage.addEventListener(GLTouchEvent.TOUCH_MOVE, stage_touchMove);
			}
		}
		
		private function stage_touchMove(e:Event):void 
		{
			/*if (GLTouchEvent.isSameTouch(nowMouseDownEvent, e)) {
				stagePos = GLTouchEvent.getMousePos(e);
				distancePos = stagePos.subtract(lastPos);
				lastPos.setTo(stagePos.x, stagePos.y);
				lastDistancePos.setTo(distancePos.x, distancePos.y);
			}*/
		}
		
		private function stage_mouseUp(e:Event):void
		{
			isMouseDown = false;
			if (GLTouchEvent.isSameTouch(nowMouseDownEvent, e)) {
				stage.removeEventListener(GLTouchEvent.TOUCH_END, stage_mouseUp);
				stage.removeEventListener(GLTouchEvent.TOUCH_MOVE, stage_touchMove);
				distancePos.setTo(lastDistancePos.x, lastDistancePos.y);
				lastDistancePos.setTo(0, 0);
			}
		}
		
		override public function update():void
		{
			if (isMouseDown&&lastPos) {
				stagePos = new Point(stage.mouseX, stage.mouseY);
				distancePos = stagePos.subtract(lastPos);
				lastPos.setTo(stagePos.x, stagePos.y);
				lastDistancePos.setTo(distancePos.x, distancePos.y);
			}
			
			rotation.y = rotation.y + distancePos.x*rotSpeed;
			rotation.x = rotation.x + distancePos.y * rotSpeed;
			rotation.x = Math.min(Math.max( -90, rotation.x), 90);
			distancePos.x *= .99;
			distancePos.y *= .99;
			if (isMouseDown) {
				distancePos.setTo(0, 0);
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
			lookat = lookat.add(helpV);
			
			helpMatrix.identity();
			helpMatrix.appendTranslation(0, 0, -distance);
			helpMatrix.appendRotation(rotation.x, Vector3D.X_AXIS);
			helpMatrix.appendRotation(rotation.y, Vector3D.Y_AXIS);
			helpMatrix.appendTranslation(lookat.x, lookat.y, lookat.z);
			node.matrix = helpMatrix;
		}
	}

}