package gl3d.parser.lol.skl 
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	/**
	 * ...
	 * @author lizhi
	 */
	public class LolSklDecoder 
	{
		public var magic:String;
		public var version:int;
		public var skl:Object;
		public function LolSklDecoder(b:ByteArray) 
		{
			b.endian = Endian.LITTLE_ENDIAN;
			magic = readString(b,8);
			version = b.readInt()
			
			skl = {};
			
			var boneName:String;
            var i:int;
			
			if(version==0){
				skl.unks = {};
				skl.unks["tell"] = b.readShort();
				skl.boneCounter = b.readShort();
				skl.boneIndicesCounter = b.readInt();


				skl.offsets = {};
				skl.offsets.bonesStart = b.readInt();
				skl.offsets.animationStart = b.readInt();
				skl.offsets.boneIndicesStart = b.readInt();
				skl.offsets.boneIndicesEnd = b.readInt();
				skl.offsets.halfayBetweenBoneindicesAndStrings = b.readInt();
				skl.offsets.boneNamesStart = b.readInt();
				skl.offsets.padding = readString(b, 20);

				for (i = 0, skl.bones = []; i < skl.boneCounter; i += 1) {
					skl.bones.push({
						unk0: b.readShort(),
						id: b.readShort(),
						parent: b.readShort(),
						unk1: b.readShort(),
						hash: b.readInt(),
						twoPointOne: b.readFloat(),
						position: {
							x: b.readFloat(),
							y: b.readFloat(),
							z: b.readFloat()
						},
						scale: {
							x: b.readFloat(),
							y: b.readFloat(),
							z: b.readFloat()
						},
						quaternion: {
							x: b.readFloat(),
							y: b.readFloat(),
							z: b.readFloat(),
							w: b.readFloat()
						},
						ct: {
							x: b.readFloat(),
							y: b.readFloat(),
							z: b.readFloat()
						},
						padding: readString(b,32)
					});
				}

				for (i = 0, skl.bonesExtra = []; i < skl.boneCounter; i += 1) {
					skl.bonesExtra.push({
						boneId: b.readInt(),
						boneHash: b.readInt()
					});
				}

				skl.boneIndices = []
				for (i = 0; i < skl.boneIndicesCounter;i++ ){
					skl.boneIndices.push(b.readShort());
				}

				b.position = skl.offsets.boneNamesStart;

				for (i = 0, skl.boneNames = []; i < skl.boneCounter; i += 1) {
					boneName = "";

					do {
						boneName += readString(b,4);
					} while (boneName.indexOf("\u0000") == -1);
					skl.boneNames.push(boneName);
				}
			}else{
				skl.skeletonHash = b.readInt();
				skl.boneCounter = b.readInt();
				skl.bones = [];
				// TODO : xxxx
				for (i = 0; i < skl.boneCounter;i++ ){
					
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