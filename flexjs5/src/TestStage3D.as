package 
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Matrix3D_ARRAY;
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestStage3D 
	{
		
		public function TestStage3D() 
		{
			
		}
		
		private function arr2floatVec(arr:Array):Vector.<Number> {
			var vec:Vector.<Number> = new Vector.<Number>;
			for each(var v:Number in arr) {
				vec.push(v);
			}
			return vec;
		}
		private function arr2uintVec(arr:Array):Vector.<uint> {
			var vec:Vector.<uint> = new Vector.<uint>;
			for each(var v:uint in arr) {
				vec.push(v);
			}
			return vec;
		}
		public function start():void
		{
			//init gl
			var ctx:Context3D = new Context3D;
			ctx.configureBackBuffer(400, 400, 2);
			
			//init shader
			var vcode:String = "attribute vec3 pos;" +
				"attribute vec3 color;" +
				"varying vec3 vColor;"+
				"uniform mat4 u0;"+
				"void main(void) {" +
					"vColor=color;"+
					"gl_Position =u0*vec4(pos, 1.0);"+
				"}";
			var fcode:String = "precision mediump float;" +
				"varying vec3 vColor;"+
			   "void main(void) {" +
					"gl_FragColor = vec4(vColor,1);"+
				"}";
			var program:Program3D = ctx.createProgram();
			program.upload(vcode, fcode);
			ctx.setProgram(program);
			
			//init buffer
			var posData:Array = [0, .7, 0, -.7, -.7, 0, .7, -.7, 0];
			var posBuffer:VertexBuffer3D = ctx.createVertexBuffer(posData.length/3,3);
			posBuffer.uploadFromVector(arr2floatVec(posData), 0, posData.length / 3);
			var colorData:Array = [1, 0, 0, 0, 1, 0, 0, 0, 1];
			var colorBuffer:VertexBuffer3D = ctx.createVertexBuffer(colorData.length/3,3);
			colorBuffer.uploadFromVector(arr2floatVec(colorData),0,colorData.length/3);
			var iData:Array = [0,1,2];
			var ibuffer:IndexBuffer3D = ctx.createIndexBuffer(iData.length);
			ibuffer.uploadFromVector(arr2uintVec(iData),0,iData.length);
			ctx.setVertexBufferAt(0, posBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
			ctx.setVertexBufferAt(1, colorBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
			
			//draw
			var matr:Matrix3D_ARRAY = new Matrix3D_ARRAY();
			setInterval(function():void { 
				matr.appendRotation(1, Vector3D.Z_AXIS);
				ctx.clear();
				//ctx.setProgramConstantsFromMatrix(
				ctx.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0,arr2floatVec( matr.rawData));
				ctx.drawTriangles(ibuffer);
				ctx.present();
			}, 1000/60);
		}
		
	}

}