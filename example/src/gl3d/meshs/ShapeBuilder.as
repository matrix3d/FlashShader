package gl3d.meshs 
{
	/**
	 * 通过类似flash api创建一个平面图形，通过轴线旋转一定角度，组成一个体
	 * uv v根据旋转成体的角度计算，u根据现在长度和总线段长度比例计算
	 * norm 
	 * @author lizhi
	 */
	public class ShapeBuilder 
	{
		public var baseLine:Vector.<Number> = new Vector.<Number>;
		public var vertexs:Vector.<Number> = new Vector.<Number>;
		public var uvs:Vector.<Number> = new Vector.<Number>;
		public var norms:Vector.<Number> = new Vector.<Number>;
		public var indexs:Vector.<uint> = new Vector.<uint>;
		private var x0:Number;
		private var y0:Number;
		public function ShapeBuilder() 
		{
			
		}
		
		public function moveTo(x0:Number, y0:Number):void {
			this.y0 = y0;
			this.x0 = x0;
			baseLine.push(x0, y0,0);
		}
		
		public function lineTo(x1:Number, y1:Number, div:int = 1):void {
			var dx:Number = (x1 - x0)/div;
			var dy:Number = (y1 - y0)/div;
			for (var i:int = 1; i <= div;i++ ) {
				baseLine.push(x0 + dx * i, y0 + dy * i,0);
			}
			x0 = x1;
			y0 = y1;
		}
		
		public function arc(r:Number,cx:Number=0,cy:Number=0, a0:Number=0, a1:Number=360, div:int = 10):void {
			var da:Number = (a1 - a0) / div;
			for (var i:int = 0; i <=div;i++ ) {
				var a:Number = (a0 + da * i)*Math.PI/180;
				baseLine.push(cx + Math.cos(a) * r, cy + Math.sin(a) * r, 0);
			}
		}
		
		public function buildCircle(angel:Number = 360, div:int = 3, close:Boolean = true):void {
			vertexs = baseLine.concat();
			var da:Number = angel * Math.PI / 180 / div;
			var numY:int = baseLine.length / 3;
			var numX:int = close?div:(div + 1);
			for (var i:int = 1; i < numX;i++ ) {
				var a:Number = da * i;
				var cosa:Number = Math.cos(a);
				var sina:Number = Math.sin(a);
				for (var j:int = 0; j < numY;j++ ) {
					vertexs.push(baseLine[3 * j] * cosa, baseLine[3 * j + 1], baseLine[3 * j] * sina);
					if (j != 0) {
						indexs.push(j - 1 + i * numY, j + i * numY, j-1 + (i - 1) * numY);
						indexs.push( j + (i-1) * numY,j - 1 + (i-1) * numY, j + i* numY);
					}
				}
			}
			if (close) {
				for (j = 1; j < numY;j++ ) {
					indexs.push(j - 1 ,j ,  j-1 + (i - 1) * numY);
					indexs.push(j + (i-1) * numY, j - 1 + (i-1) * numY, j);
				}
			}
		}
		
		public static function Cylinder(r0:Number, r1:Number, h:Number,div:int=30):ShapeBuilder {
			var sb:ShapeBuilder = new ShapeBuilder;
			sb.moveTo(0, -h/2);
			sb.lineTo(r0, -h/2);
			sb.lineTo(r0, -h/2);
			sb.lineTo(r1, h/2);
			sb.lineTo(r1, h/2);
			sb.lineTo(0, h/2);
			sb.buildCircle(360, div, true);
			return sb;
		}
		
		public static function Circle(r:Number,divX:int=20,divY:int=20):ShapeBuilder {
			var sb:ShapeBuilder = new ShapeBuilder;
			sb.arc(r, 0, 0, -90, 90, divY);
			sb.buildCircle(360, divX, true);
			return sb;
		}
		
		public static function Torus(r0:Number, r1:Number, divX:int = 40, divY:int = 20):ShapeBuilder {
			var sb:ShapeBuilder = new ShapeBuilder;
			sb.arc(r1, r0, 0, -180, 180, divY);
			sb.buildCircle(360, divX, true);
			return sb;
		}
		
	}

}