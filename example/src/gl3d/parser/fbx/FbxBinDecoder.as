package gl3d.parser.fbx 
{
	import flash.utils.ByteArray;
	import flash.utils.CompressionAlgorithm;
	import flash.utils.Endian;
	/**
	 * ...
	 * @author lizhi
	 */
	public class FbxBinDecoder 
	{
		private var _BLOCK_SENTINEL_LENGTH:int = 13;
		public var childs:Array;
		public var isBin:Boolean = false;
		public function FbxBinDecoder(byte:ByteArray) 
		{
			byte.endian = Endian.LITTLE_ENDIAN;
			if (byte.readUTFBytes(18) == "Kaydara FBX Binary") {
				isBin = true;
			}else {
				return;
			}
			byte.position = 23;
			var version:int = byte.readUnsignedInt();
			var is64bits:Boolean = version >= 7500;
			_BLOCK_SENTINEL_LENGTH = is64bits?25:13;
			childs = [];
			while(true){
				var elem:Object = read_elem(byte,is64bits);
				if (elem==null) {
					break;
				}
				childs.push(elem);
			}
		}
		
		private function read_string_ubyte(read:ByteArray):String{
			var size:int = read.readUnsignedByte();
			var data:String = read.readUTFBytes(size);
			return data
		}
		
		private function unpack_array(read:ByteArray, t:int):Array {
			var length:int = read.readUnsignedInt();
			var encoding:int = read.readUnsignedInt();
			var comp_len:int = read.readUnsignedInt();

			var data:ByteArray = new ByteArray;
			
			read.readBytes(data, 0, comp_len);
			
			if (encoding == 1) {
				data.uncompress(CompressionAlgorithm.ZLIB);
			}
			data.endian = Endian.LITTLE_ENDIAN;
			var data_array:Array = [];
			for (var i:int = 0; i < length;i++ ) {
				data_array.push(read_data_dict(data, t));
			}
			return data_array;
		}
		
		private function read_data_dict(r:ByteArray, t:int):Object {
			switch(t) {
				case 89/*"Y"*/:
					return r.readShort();
				case 66/*"B"*/:
					return r.readByte();
				case 67/*"C"*/:
					return r.readBoolean();
				case 73/*"I"*/:
					return r.readInt();
				case 70/*"F"*/:
					return r.readFloat();
				case 68/*"D"*/:
					return r.readDouble();
				case 76/*"L"*/:
					return readLong(r)//[r.readUnsignedInt(),r.readUnsignedInt()];
				case 82/*"R"*/:
					var b:ByteArray = new ByteArray;
					b.endian = Endian.LITTLE_ENDIAN;
					var size:int = r.readUnsignedInt();
					r.readBytes(b, 0, size);
					b.position = 0;
					return b;
				case 83/*"S"*/:
					size = r.readUnsignedInt();
					return r.readUTFBytes(size);
				case 102/*"f"*/:
				case 105/*"i"*/:
				case 100/*"d"*/:
				case 108/*"l"*/:
				case 98/*"b"*/:
				case 99/*"c"*/:
					return unpack_array(r, t-32/*.toUpperCase()*/);		
			}
			return null;
		}
		
		private function readLong(read:ByteArray):Number{
			var l:uint= read.readUnsignedInt();
			//read.position += 4;
			var h:int = read.readInt();
			return l+h*0x100000000;
		}
		
		private function read_elem(read:ByteArray,is64bits:Boolean):Object{
			// [0] the offset at which this block ends
			// [1] the number of properties in the scope
			// [2] the length of the property list
			var end_offset:int = is64bits?readLong(read):read.readUnsignedInt();
			
			if (end_offset == 0){
				return null;
			}
			var prop_count:int =is64bits?readLong(read):read.readUnsignedInt();
			var prop_length:int =is64bits?readLong(read):read.readUnsignedInt();

			var elem_id:String = read_string_ubyte(read)        //# elem name of the scope/key
			//var elem_props_type:Array = [];  //# elem property types
			var elem_props_data:Array = [];    //# elem properties (if any)
			var elem_subtree:Array = [];                        //# elem children (if any)

			for (var i:int = 0; i < prop_count;i++) {
				//var data_type:String = read.readUTFBytes(1);
				elem_props_data[i] = read_data_dict(read, read.readByte()/*data_type*/);
				//elem_props_type[i] = data_type;
			}

			if (read.position< end_offset){
				while (read.position < (end_offset - _BLOCK_SENTINEL_LENGTH)){
					elem_subtree.push(read_elem(read,is64bits));
				}
				if ( read.readUTFBytes(_BLOCK_SENTINEL_LENGTH) != "") {
					throw "failed to read nested block sentinel,expected all bytes to be 0";
				}
			}
			if (read.position != end_offset){
				if(end_offset<read.length){
					read.position = end_offset;
				}
				trace("scope length not reached, something is wrong");
			}
			var out:Object = { name:elem_id, props:elem_props_data };
			if (elem_props_data.length) {
				out.props = elem_props_data;
			}
			if (elem_subtree.length) {
				out.childs = elem_subtree;
			}
			return out;
		}
		
	}

}