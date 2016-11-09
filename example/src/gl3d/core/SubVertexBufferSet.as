package gl3d.core 
{
	import gl3d.core.renders.GL;
	/**
	 * ...
	 * @author lizhi
	 */
	public class SubVertexBufferSet extends VertexBufferSet
	{
		private var buffSet:VertexBufferSet;
		private var offset:int;
		private var count:int;
		
		public function SubVertexBufferSet(buffSet:VertexBufferSet,offset:int,count:int) 
		{
			this.count = count;
			this.offset = offset;
			this.buffSet = buffSet;
			super(null, 0);
		}
		
		override public function update(context:GL):void 
		{
			buffSet.update(context);
		}
		
		override public function dispose():void 
		{
			buffSet.dispose();
		}
		
		override public function bind(context:GL, i:int, offset:int = 0, format:String = null):void 
		{
			buffSet.bind(context, i, this.offset, format || FORMATS[count]);
			//super.bind(context, i, offset, format);
		}
	}

}