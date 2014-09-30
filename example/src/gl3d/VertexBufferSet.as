package gl3d 
{
	import flash.display3D.Context3D;
	import flash.display3D.VertexBuffer3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class VertexBufferSet 
	{
		private var data32PerVertex:int;
		public var data:Vector.<Number>;
		private var buff:VertexBuffer3D;
		private var invalid:Boolean = true;
		public function VertexBufferSet(data:Vector.<Number>,data32PerVertex:int) 
		{
			this.data = data;
			this.data32PerVertex = data32PerVertex;
			
		}
		
		public function update(context:Context3D):void 
		{
			if (invalid) {
				if(data){
					var num:int = data.length / data32PerVertex;
					buff = context.createVertexBuffer(num, data32PerVertex);
					buff.uploadFromVector(data, 0, num);
					invalid = false;
				}
			}
		}
		
		public function bind(context:Context3D, i:int):void {
			context.setVertexBufferAt(i, buff,0,"float"+data32PerVertex);
		}
	}

}