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
		private const _BLOCK_SENTINEL_LENGTH:int = 13;
		//private var useFbxPropClass:Boolean;
		public var childs:Array;
		public var isBin:Boolean = false;
		public function FbxBinDecoder(byte:ByteArray/*,useFbxPropClass:Boolean=true*/) 
		{
			//this.useFbxPropClass = useFbxPropClass;
			byte.endian = Endian.LITTLE_ENDIAN;
			if (byte.readUTFBytes(18) == "Kaydara FBX Binary") {
				isBin = true;
			}else {
				return;
			}
			byte.position = 23;
			var version:int = byte.readUnsignedInt();
			childs = [];
			while(true){
				var elem:Object = read_elem(byte);
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
		
		private function unpack_array(read:ByteArray, t:String):Array {
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
		
		private function read_data_dict(r:ByteArray, t:String):Object {
			switch(t) {
				case "Y":
					return r.readShort();
				case "B":
					return r.readByte();
				case "C":
					return r.readBoolean();
				case "I":
					return r.readInt();
				case "F":
					return r.readFloat();
				case "D":
					return r.readDouble();
				case "L":
					return [r.readUnsignedInt(),r.readUnsignedInt()];
				case "R":
					var b:ByteArray = new ByteArray;
					b.endian = Endian.LITTLE_ENDIAN;
					var size:int = r.readUnsignedInt();
					r.readBytes(b, 0, size);
					b.position = 0;
					return r;
				case "S":
					size = r.readUnsignedInt();
					return r.readUTFBytes(size);
				case "f":
				case "i":
				case "d":
				case "l":
				case "b":
				case "c":
					return unpack_array(r, t.toUpperCase());		
			}
			return null;
		}
		
		/*private function read_data_dict(r:ByteArray, t:String):Object {
			if (!useFbxPropClass) return read_data_dict_value(r, t);
			switch(t) {
				case "Y":
				case "B":
				case "C":
				case "I":
					return FbxProp.PInt(read_data_dict_value(r,t) as int);
				case "F":
				case "D":
					return FbxProp.PFloat(read_data_dict_value(r,t) as Number);
				case "L":
				case "R":
				case "S":
					return FbxProp.PString(read_data_dict_value(r,t)+"");
				case "b":
				case "c":
				case "i":
					return FbxProp.PInts(read_data_dict_value(r,t) as Array);	
				case "f":
				case "d":
				case "l":
					return FbxProp.PFloats(read_data_dict_value(r,t) as Array);	
			}
			return null;
		}*/
		
		private function read_elem(read:ByteArray):Object{
			// [0] the offset at which this block ends
			// [1] the number of properties in the scope
			// [2] the length of the property list
			var end_offset:int = read.readUnsignedInt();
			if (end_offset == 0){
				return null;
			}

			var prop_count:int = read.readUnsignedInt();
			var prop_length:int = read.readUnsignedInt();

			var elem_id:String = read_string_ubyte(read)        //# elem name of the scope/key
			//var elem_props_type:Array = [];  //# elem property types
			var elem_props_data:Array = [];    //# elem properties (if any)
			var elem_subtree:Array = [];                        //# elem children (if any)

			for (var i:int = 0; i < prop_count;i++) {
				var data_type:String = read.readUTFBytes(1);
				elem_props_data[i] = read_data_dict(read, data_type);
				//elem_props_type[i] = data_type;
			}

			if (read.position< end_offset){
				while (read.position < (end_offset - _BLOCK_SENTINEL_LENGTH)){
					elem_subtree.push(read_elem(read));
				}
				if ( read.readUTFBytes(_BLOCK_SENTINEL_LENGTH) != "") {
					throw "failed to read nested block sentinel,expected all bytes to be 0";
				}
			}
			if (read.position != end_offset){
				throw "scope length not reached, something is wrong";
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