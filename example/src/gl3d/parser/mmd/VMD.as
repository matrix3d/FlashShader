package gl3d.parser.mmd 
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	/**
	 * ...
	 * @author lizhi
	 */
	dynamic public class VMD 
	{
		
		public function VMD(buffer:ByteArray) 
		{
			buffer.endian = Endian.LITTLE_ENDIAN;
			var bin:VMDReader, n:int;

			bin = new VMDReader( buffer );

			this.timeMax = 0;
			this.boneKeys = [];
			this.morphKeys = [];
			this.cameraKeys = [];
			this.lightKeys = [];

			n = bin.readUint32();
			while ( n-- > 0 ) {
				this.boneKeys.push( new BoneKey( bin ) );
			}
			n = bin.readUint32();
			while ( n-- > 0 ) {
				this.morphKeys.push( new MorphKey( bin ) );
			}

			n = bin.readUint32();
			while ( n-- > 0 ) {
				this.cameraKeys.push( new CameraKey( bin ) );
			}

			n = bin.readUint32();
			while ( n-- > 0 ) {
				this.lightKeys.push( new LightKey( bin ) );
			}
		}
		
	}

}

import gl3d.parser.mmd.VMDReader;
dynamic class BoneKey{
public function BoneKey( bin:VMDReader ) {
	this.name = bin.readCString(15);
	this.time =  bin.readUint32() ;
	this.pos =  bin.readVector(3) ;
	this.rot =  bin.readVector(4) ;
	this.interp = bin.readBytes(64);// .subarray(0, 16); // 必要なのは最初の１６個。
}
}
dynamic class MorphKey{
public function  MorphKey( bin:VMDReader ) {
	this.name = bin.readCString(15);
	this.time =  bin.readUint32() ;
	this.weight = bin.readFloat32();
}
}
dynamic class CameraKey{
public function CameraKey ( bin :VMDReader) {
	// 扱いやすいように一部の値は符号反転しておく。
	this.time =  bin.readUint32() ;
	this.distance = -bin.readFloat32();
	this.target = bin.readVector(3) ;
	this.rot =  bin.readVector(3) ;
	this.rot[0] *= -1;
	this.rot[1] *= -1;
	this.rot[2] *= -1;
	this.interp = bin.readBytes(24);
	this.fov = bin.readUint32();
	this.ortho = bin.readInt8();
}
}
dynamic class LightKey{
public function LightKey ( bin:VMDReader ) {
	this.time =  bin.readUint32() ;
	this.color = bin.readVector(3);
	this.dir =  bin.readVector(3) ;
}
}