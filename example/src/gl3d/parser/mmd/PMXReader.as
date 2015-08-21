package gl3d.parser.mmd 
{
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author lizhi
	 */
	public dynamic class PMXReader extends ReaderBase{ // extend BinaryStream
	public function PMXReader(buffer:ByteArray) 
	{
		super(buffer);
	// read header
	if ( this.readUint32() != 0x20584d50 ) { //  'PMX '
		throw "Exception.MAGIC";
	}
	this.version = this.readFloat32();
	if ( this.version !== 2.0 ) {
		throw "Exception.DATA"; // not supported
	}
	if ( this.readUint8() !== 8 ) {
		throw "Exception.DATA";
	}
	this.encode = this.readUint8()==0?"utf-16":"utf-8"; // 0=UTF16_LE, 1=UTF-8
	this.additionalUvCount = this.readUint8();
	this.vertexIndexSize = this.readUint8();
	this.textureIndexSize = this.readUint8();
	this.materialIndexSize = this.readUint8();
	this.boneIndexSize = this.readUint8();
	this.morphIndexSize = this.readUint8();
	this.rigidIndexSize = this.readUint8();
	}


public function readVertexIndex ():int {
	return this.readIndex( this.vertexIndexSize, true );
}
public function readTextureIndex():int {
	return this.readIndex( this.textureIndexSize );
}
public function readMaterialIndex():int {
	return this.readIndex( this.materialIndexSize );
}
public function readBoneIndex():int {
	return this.readIndex( this.boneIndexSize );
}
public function readMorphIndex():int {
	return this.readIndex( this.morphIndexSize );
}
public function readRigidIndex():int {
	return this.readIndex( this.rigidIndexSize );
}

}
}