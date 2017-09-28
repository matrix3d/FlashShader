package gl3d.parser.lol.anm 
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	/**
	 * ...
	 * @author lizhi
	 */
	public class LolAnmDecoder 
	{
		private var anm:Object;
		
		public function LolAnmDecoder(b:ByteArray) 
		{
			b.endian = Endian.LITTLE_ENDIAN;
			var magic:String = readString(b, 8);
			var version:int = b.readInt();
			trace(1);
			if (version==1){
				var indexCounter:int;
				var i:int;
				
				anm = {};
				
				anm.dataSize = b.readInt();

				anm.unks = {};
				anm.subMagic = readString(b,4);
				anm.subVersion = b.readInt();
				anm.boneCounter = b.readInt();
				anm.entriesCounter = b.readInt();
				anm.unks["tell"] = b.readInt();
				anm.animationLength = b.readFloat();
				anm.FPS = b.readFloat();

				anm.unks["tell"] = b.readInt();
				anm.unks["tell"] = b.readInt();
				anm.unks["tell"] = b.readInt();
				anm.unks["tell"] = b.readInt();
				anm.unks["tell"] = b.readInt();
				anm.unks["tell"] = b.readInt();

				anm.minTranslation = {
					x: b.readFloat(),
					y: b.readFloat(),
					z: b.readFloat()
				};

				anm.maxTranslation = {
					x: b.readFloat(),
					y: b.readFloat(),
					z: b.readFloat()
				};

				anm.minScale = {
					x: b.readFloat(),
					y: b.readFloat(),
					z: b.readFloat()
				};

				anm.maxScale = {
					x: b.readFloat(),
					y: b.readFloat(),
					z: b.readFloat()
				};

				anm.entriesOffset = b.readInt();
				anm.indicesOffset = b.readInt();
				anm.hashesOffset = b.readInt();

				anm.entries = [];
				for (i = 0; i < anm.entriesCounter; i += 1) {
					anm.entries.push({
						compressedTime: b.readUnsignedShort(),
						hashId: b.readByte(),
						dataType: b.readByte(),
						compressedData: {
							x: b.readUnsignedShort(),
							y: b.readUnsignedShort(),
							z: b.readUnsignedShort()
						}
					});
				}

				indexCounter = (anm.hashesOffset - anm.indicesOffset) / 2;
				
				anm.indexes = [];//
				for (i = 0; i < indexCounter;i++ ){
					anm.indexes.push(b.readUnsignedShort());
				}

				anm.boneHashes = [];//
				for (i = 0; i < anm.boneCounter;i++ ){
					anm.boneHashes.push(b.readUnsignedInt());
				}
			}
		}
		
		private function readString(b:ByteArray, len:int):String{
			var nb:ByteArray = new ByteArray;
			b.readBytes(nb, 0, len);
			return nb + "";
		}
		
	}

}