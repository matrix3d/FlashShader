package gl3d.core 
{
	/**
	 * ...
	 * @author lizhi
	 */
	public class DrawableSource 
	{
		public var index:Array;
		public var pos:Array;
		public var joint:Array;
		public var weight:Array;
		public var uvIndex:Array;
		public var uv:Array;
		public var uv2:Array;
		public var color:Array;
		public var alpha:Array;
		public function DrawableSource() 
		{
			
		}
		
		public static function getIndex(ins:Array):Array{
			var newIndex = [];
			for (var i:int = 0; i < ins.length;i+=3 ){
				newIndex.push([ins[i],ins[i+1],ins[i+2]]);
			}
			return newIndex;
		}
	}

}