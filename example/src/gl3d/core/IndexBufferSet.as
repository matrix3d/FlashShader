package gl3d.core {
	import flash.display3D.Context3D;
	import flash.display3D.IndexBuffer3D;
	import gl3d.core.renders.GL;
	/**
	 * ...
	 * @author lizhi
	 */
	public class IndexBufferSet 
	{
		public var data:Vector.<uint>;
		private var invalid:Boolean = true;
		public var dataInvalid:Boolean = true;
		private var context:GL;
		public var buff:IndexBuffer3D;
		public var numTriangles:int = -1
		public function IndexBufferSet(data:Vector.<uint>) 
		{
			this.data = data;
			
		}
		
		public function update(context:GL):void 
		{
			if (invalid||this.context!=context) {
				var num:int = data.length;
				buff = context.createIndexBuffer(num);
				invalid = false;
				dataInvalid = true;
				this.context = context;
			}
			if(dataInvalid){
				dataInvalid = false;
				buff.uploadFromVector(data, 0, data.length);
			}
		}
		public function dispose():void {
			if (buff) {
				buff.dispose();
			}
		}
		
	}

}