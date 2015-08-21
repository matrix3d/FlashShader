package gl3d.parser.mmd 
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	/**
	 * ...
	 * @author lizhi
	 */
	public dynamic class ReaderBase{ // extend BinaryStream
	private var buffer:ByteArray;
	public function ReaderBase(buffer:ByteArray) 
	{
this.buffer = buffer;
	}


	public function readCString(len:int):String {
		return buffer.readMultiByte(len, "ansi");
	}
	public function readText():String {
	var l:int = this.readInt32();
	return buffer.readMultiByte(l, this.encode);
}
public function readIndex ( size:int, vertex:Object=null ):int {
	var i:int;
	if ( size === 1 ) {
		i = vertex ? this.readUint8() : this.readInt8();
	} else
	if ( size === 2 ) {
		i = vertex ? this.readUint16() : this.readInt16();
	} else
	if ( size === 4 ) {
		i = this.readInt32();
	} else {
		throw "Exception.DATA";
	}
	return i;
}
	public function readVector( n:int ):Array {
	var v:Array = [];
	while ( n-- > 0 ) {
		v.push( this.readFloat32() );
	}
	return v;
}

public function readInt8():int {
	return buffer.readByte();
}
public function readUint8 () :int{
	return buffer.readUnsignedByte();
}
public function readInt16 ():int {
	return buffer.readShort();
}
public function readUint16():int {
	return buffer.readUnsignedShort();
}
public function readInt32():int {
	return buffer.readInt();
}
public function readUint32 ():int {
	return buffer.readUnsignedInt();
}
public function readFloat32():Number {
	return buffer.readFloat();
}

public function readBytes(len:int):Array {
	var a:Array = [];
	for (var i:int = 0; i < len;i++ ) {
		a.push(readUint8());
	}
	return a;
}
}
}