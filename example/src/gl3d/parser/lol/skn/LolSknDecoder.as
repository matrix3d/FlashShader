package gl3d.parser.lol.skn 
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	/**
	 * ...
	 * @author lizhi
	 */
	public class LolSknDecoder 
	{
		public var magic:int;
		public var version:int;
		public var numObjects:int;
		public var skin:LolSkn;
		public function LolSknDecoder(b:ByteArray) 
		{
			b.endian = Endian.LITTLE_ENDIAN;
			magic = b.readInt();
			version = b.readShort();
			numObjects = b.readShort();
			
			skin = new LolSkn;
			
			if (version>=1){
				var mc:int = b.readInt();
				for (var i:int = 0; i < mc;i++ ){
					var nameb:ByteArray = new ByteArray;
					b.readBytes(nameb, 0, 64);
					var name:String = nameb + "";
					var startVertex:int = b.readInt();
					var numVertices:int = b.readInt();
					var startIndex:int = b.readInt();
					var numIndices:int = b.readInt();
				}
			}
			
			if (version==4){
				var unks:Object = {};
				unks["tell"] = b.readInt();
			}
			
			var indicesCount:int = b.readInt();
			var verticesCount:int = b.readInt();
			
			if (version == 4){
				var ta:Array = [];
				unks["tell"] = ta;
				for (i = 0; i < 24;i++ ){
					ta.push(b.readShort());
				}
			}
			
			skin.indices = [];
			for (i = 0; i < indicesCount;i++ ){
				skin.indices.push(b.readShort());
			}
			for (i = 0; i < verticesCount;i++ ){
				skin.pos.push( b.readFloat(),b.readFloat(),b.readFloat());
				skin.boneIndices.push( [b.readByte(), b.readByte(), b.readByte(), b.readByte()]);
				skin.weight.push(b.readFloat(),b.readFloat(),b.readFloat(),b.readFloat());
				skin.normal.push(b.readFloat(),b.readFloat(),b.readFloat());
				skin.uv.push(b.readFloat(),b.readFloat());
			}
			
		}
		
	}

}