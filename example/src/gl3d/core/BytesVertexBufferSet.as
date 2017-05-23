package gl3d.core 
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import gl3d.core.renders.GL;
	/**
	 * ...
	 * @author lizhi
	 */
	public class BytesVertexBufferSet extends VertexBufferSet
	{
		public var bytedata:ByteArray;
		
		public function BytesVertexBufferSet(bytedata:ByteArray,data32PerVertex:int/*,subBuffs:Array=null*/,bufferUsage:String="staticDraw") 
		{
			super(null, data32PerVertex, bufferUsage,5);
			this.bytedata = bytedata;
			
		}
		
		override public function update(context:GL):void 
		{
			if (invalid||this.context!=context) {
				if(bytedata){
					var num:int = bytedata.length / 4 / data32PerVertex;
					buff = context.createVertexBuffer(num, data32PerVertex,bufferUsage);
					invalid = false;
					this.context = context;
				}
				dataInvalid = true;
			}
			if (bytedata&&dataInvalid){
				dataInvalid = false;
				buff.uploadFromByteArray(bytedata, 0, 0, bytedata.length / 4 / data32PerVertex);
			}
		}
		
	}

}