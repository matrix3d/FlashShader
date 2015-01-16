package gl3d.core {
	import flash.display3D.Context3D;
	import flash.display3D.VertexBuffer3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class VertexBufferSet 
	{
		public var data32PerVertex:int;
		public var data:Vector.<Number>;
		private var buff:VertexBuffer3D;
		private var invalid:Boolean = true;
		private var context:Context3D;
		public static var FORMATS:Array = [null, "float1", "float2", "float3", "float4"];
		public var subBuffs:Array;
		public function VertexBufferSet(data:Vector.<Number>,data32PerVertex:int) 
		{
			this.data = data;
			this.data32PerVertex = data32PerVertex;
			
		}
		
		public function update(context:Context3D):void 
		{
			if (invalid||this.context!=context) {
				if(data){
					var num:int = data.length / data32PerVertex;
					buff = context.createVertexBuffer(num, data32PerVertex);
					buff.uploadFromVector(data, 0, num);
					invalid = false;
					this.context = context;
				}
			}
		}
		
		public function bind(context:Context3D, i:int, offset:int = 0, format:String = null):void {
			if (subBuffs) {
				for each(var a:Array in subBuffs) {
					context.setVertexBufferAt(a[0], buff,a[1],a[2]);
				}
			}else {
				context.setVertexBufferAt(i, buff,offset,format||FORMATS[data32PerVertex]);
			}
		}
	}

}