package gl3d.core {
	import flash.display3D.Context3D;
	import flash.display3D.IndexBuffer3D;
	/**
	 * ...
	 * @author lizhi
	 */
	public class IndexBufferSet 
	{
		public var data:Vector.<uint>;
		private var invalid:Boolean = true;
		private var context:Context3D;
		public var buff:IndexBuffer3D;
		public function IndexBufferSet(data:Vector.<uint>) 
		{
			this.data = data;
			
		}
		
		public function update(context:Context3D):void 
		{
			if (invalid||this.context!=context) {
				var num:int = data.length;
				buff = context.createIndexBuffer(num);
				buff.uploadFromVector(data, 0, num);
				invalid = false;
				this.context = context;
			}
		}
		
	}

}