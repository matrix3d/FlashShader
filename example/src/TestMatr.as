package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.getTimer;
	import gl3d.core.math.Quaternion;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestMatr extends BaseExample
	{
		
		public function TestMatr() 
		{
			
		}
		
		override public function enterFrame(e:Event):void 
		{
			//var matr:Matrix3D = teapot.matrix;
			//var data:Vector.<Number> = matr.rawData;
			//data[5] = .1;
			//data[0] = -1;
			//matr.rawData = data;
			
			//teapot.matrix = matr;
			//teapot.scaleX = 2;
			view.render(getTimer());
			//traceMatr(teapot.matrix);
			
			
			var q:Quaternion = new Quaternion();
			var matr:Matrix3D = new Matrix3D;
			trace(5 * Math.PI / 180);
			matr.appendRotation(5, Vector3D.Z_AXIS);
			q.fromMatrix(matr);
			trace(q);
		}
		
		private function traceMatr(matr:Matrix3D):void {
			//teapot.x = 1;
			//teapot.y = 2;
			//teapot.scaleX = 3;
			//teapot.scaleY = 4;
			//teapot.scaleZ = 5;
			var data:Vector.<Number> = matr.rawData;
			var str:String = "";
			for (var i:int = 0; i < 4;i++ ) {
				for (var j:int = 0; j < 4; j++ ) {
					str += data[j * 4 + i] + ",";
				}
				str += "\n";
			}
			trace(str);
			trace()
		}
		
	}

}