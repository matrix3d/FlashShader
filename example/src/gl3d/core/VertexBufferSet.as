package gl3d.core {
	import flash.display3D.Context3D;
	import flash.display3D.VertexBuffer3D;
	import gl3d.core.renders.GL;
	/**
	 * ...
	 * @author lizhi
	 */
	public class VertexBufferSet 
	{
		public var data32PerVertex:int;
		public var data:Vector.<Number>;
		private var buff:VertexBuffer3D;
		public var invalid:Boolean = true;
		public var dataInvalid:Boolean = true;
		private var context:GL;
		public static var FORMATS:Array = [null, "float1", "float2", "float3", "float4"];
		//public var subBuffs:Array;
		public var cpuSkin:VertexBufferSet;
		public function VertexBufferSet(data:Vector.<Number>,data32PerVertex:int/*,subBuffs:Array=null*/) 
		{
			this.data = data;
			this.data32PerVertex = data32PerVertex;
			//this.subBuffs = subBuffs;
			//if (data32PerVertex>4&&subBuffs==null) {
			//	throw "error";
			//}
		}
		
		public function update(context:GL):void 
		{
			if (invalid||this.context!=context) {
				if(data){
					var num:int = data.length / data32PerVertex;
					buff = context.createVertexBuffer(num, data32PerVertex);
					invalid = false;
					this.context = context;
				}
				dataInvalid = true;
			}
			if (data&&dataInvalid){
				dataInvalid = false;
				buff.uploadFromVector(data, 0, data.length / data32PerVertex);
			}
		}
		
		public function bind(context:GL, i:int, offset:int = 0, format:String = null):void {
			//if (subBuffs) {
			//	var buffOffset:int = 0;
			//	for (var j:int = 0; j < subBuffs.length; j++ ) {
			//		var count:int = subBuffs[j];
			//		context.setVertexBufferAt(i + j, buff, buffOffset, format || FORMATS[count]);
			//		buffOffset += count;
			//	}
			//}else {
				context.setVertexBufferAt(i, buff,offset,format||FORMATS[data32PerVertex]);
			//}
		}
		
		public function dispose():void {
			if (buff) {
				buff.dispose();
			}
		}
	}

}