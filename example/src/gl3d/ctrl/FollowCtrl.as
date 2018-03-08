package gl3d.ctrl 
{
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import gl3d.core.Node3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class FollowCtrl extends Ctrl
	{
		public var isRotation:Boolean = false;
		private var target:Node3D;
		private var node:Node3D;
		private var help:Matrix3D = new Matrix3D;
		private var help2:Matrix3D = new Matrix3D;
		private var distance:Number = 60;
		public function FollowCtrl(target:Node3D,node:Node3D,stage:Stage) 
		{
			this.node = node;
			this.target = target;
			
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, stage_mouseWheel);
		}
		
		private function stage_mouseWheel(e:MouseEvent):void 
		{
			
			distance-= e.delta / 100 * distance;
		}
		
		override public function update(time:int,n:Node3D):void 
		{
			help.identity();
			help.appendRotation(45, Vector3D.X_AXIS);
			var v:Vector3D = new Vector3D(0, 0, -1);
			v = help.transformVector(v);
			v.scaleBy(distance);
			help.appendTranslation(v.x, v.y, v.z);
			help.appendTranslation(target.x, target.y, target.z);
			//help2.recompose(Vector.<Vector3D>([target.trs[0],isRotation?target.trs[1]:new Vector3D(0,0,0),new Vector3D(1,1,1)]));
			//help.append(help2);
			node.matrix = Matrix3D.interpolate(node.matrix, help, 0.05);
			node.matrix = node.matrix;
		}
		
	}

}