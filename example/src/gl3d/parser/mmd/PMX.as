package gl3d.parser.mmd 
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	/**
	 * ...
	 * @author lizhi
	 */
	dynamic public class PMX 
	{
		public var bin:PMXReader;
		public var maxWeight:int = 0;
		public function PMX(buffer:ByteArray) 
		{
			buffer.endian = Endian.LITTLE_ENDIAN;
			var n:int, bones:Array;
			bin = new PMXReader( buffer );

			this.vertices = [];
			this.indices = [];
			this.textures = [];
			this.materials = [];
			this.bones = [];
			this.morphs = [];
			this.frames = [];
			this.rigids = [];
			this.joints = [];

			//_bdef1 = _bdef2 = _bdef4 = _sdef = 0; // debug

			this.info = new Info( bin );
			//console.log(this.info.name);

			n = bin.readInt32();
			//console.log('vertices = ' + n);
			while ( n-- > 0 ) {
				var vert:Vertex= new Vertex( bin ) 
				this.vertices.push(vert);
				if (maxWeight < vert.skin.bones.length) maxWeight = vert.skin.bones.length;
			}
			//console.log('(bdef1=' + _bdef1 + ' bdef2=' + _bdef2 +' bdef4=' + _bdef4 +' sdef=' + _sdef + ')');

			n = bin.readInt32();
			//console.log('faces = ' + n/3);
			while ( n-- > 0 ) {
				this.indices.push( bin.readVertexIndex() );
			}

			n = bin.readInt32();
			//console.log('textures = ' + n);
			while ( n-- > 0 ) {
				this.textures.push( new Texture( bin ) );
			}

			n = bin.readInt32();
			//console.log('materials = ' + n);
			while ( n-- > 0 ) {
				this.materials.push( new Material( bin ) );
			}

			n = bin.readInt32();
			//console.log('bones = ' + n);
			while ( n-- > 0 ) {
				this.bones.push( new Bone( bin ) );
			}

			n = bin.readInt32();
			//console.log('morphs = ' + n);
			while ( n-- > 0 ) {
				this.morphs.push( new Morph( bin ) );
			}

			n = bin.readInt32();
			//console.log('frames = ' + n);
			while ( n-- > 0 ) {
				this.frames.push( new Frame( bin ) );
			}

			n = bin.readInt32();
			//console.log('rigid bodies = ' + n);
			while ( n-- > 0 ) {
				this.rigids.push( new Rigid( bin ) );
			}

			n = bin.readInt32();
			//console.log('joints = ' + n);
			while ( n-- > 0 ) {
				this.joints.push( new Joint( bin ) );
			}
		}
		
	}

}
import flash.utils.ByteArray;
import gl3d.parser.mmd.PMXReader;


dynamic class Info  {
	public function Info(bin:PMXReader) 
	{
		super();
		this.name = bin.readText();
	this.nameEn = bin.readText();
	this.comment = bin.readText();
	this.commentEn = bin.readText();
	}
	
}

dynamic class Skin {
public function Skin(bin:PMXReader) 
	{var w:Number;
	this.type = bin.readUint8();
	switch( this.type ) {
	case 0: // BDEF1
		this.bones = [ readBoneIndex() ];
		this.weights = [ 1.0 ];
		//_bdef1++; // debug
		break;
	case 1: // BDEF2
		this.bones = [ readBoneIndex(), readBoneIndex() ];
		w = bin.readFloat32();
		this.weights = [ w, 1.0 - w ];
		//_bdef2++; // debug
		break;
	case 2: // BDEF4
		this.bones = [ readBoneIndex(), readBoneIndex(), readBoneIndex(), readBoneIndex() ];
		this.weights = [ bin.readFloat32(), bin.readFloat32(), bin.readFloat32(), bin.readFloat32() ];
		//_bdef4++; // debug
		break;
	case 3: // SDEF
		this.bones = [ readBoneIndex(), readBoneIndex() ];
		w = bin.readFloat32();
		this.weights = [ w, 1.0 - w ];
		this.sdefC = bin.readVector( 3 );
		this.sdefR0 = bin.readVector( 3 );
		this.sdefR1 = bin.readVector( 3 );
		//_sdef++; // debug
		break;
	default:
		throw "Exception.DATA";
	}

	function readBoneIndex():int {
		var i:int = bin.readBoneIndex();
		if (i < 0) { // ボーン指定無しの場合は安全のためゼロにする。当然weightはゼロのはず。
			i = 0;
		}
		return i;
	}
	}	
	
}

 dynamic class  Vertex  {
	public function Vertex(bin:PMXReader) 
	{ var n:int;
	this.pos =  bin.readVector( 3 ) ;
	this.normal =  bin.readVector( 3  );
	this.uv = bin.readVector( 2 );
	this.additionalUvs = [];
	n = bin.additionalUvCount;
	while ( n-- > 0 ) {
		this.additionalUvs.push( bin.readVector( 4 ) ); // x,y,z,w
	}
	this.skin = new Skin( bin );
	this.edgeScale = bin.readFloat32();
	}
	
}

dynamic class Texture {
public function Texture(bin:PMXReader) 
	{
		this.path = bin.readText().replace(/\\/g,'/');
	}	
	
}

dynamic class Material {
	public function Material(bin:PMXReader) 
	{
		this.name = bin.readText();
	this.nameEn = bin.readText();
	this.diffuse = bin.readVector(3);
	this.alpha = bin.readFloat32();
	this.specular = bin.readVector(3);
	this.power = bin.readFloat32();
	this.ambient = bin.readVector(3);
	this.drawFlags = bin.readUint8();
	this.edgeColor = bin.readVector(4);
	this.edgeSize = bin.readFloat32();
	this.texture = bin.readTextureIndex();
	this.sphereTexture = bin.readTextureIndex();
	this.sphereMode = bin.readUint8();
	this.sharedToon = bin.readUint8();
	if ( this.sharedToon === 0 ) {
		this.toonTexture = bin.readTextureIndex(); // -1: not apply toon
	} else {
		this.toonTexture = bin.readUint8();
	}
	this.memo = bin.readText();
	this.indexCount = bin.readInt32();
	}
	

	/* // debug
	var s = this.drawFlags.toString(2);
	while ( s.length < 5 ) {
		s = '0' + s;
	}
	console.log( this.name, s ); */
}

dynamic class IKLink {
	public function IKLink(bin:PMXReader) 
	{this.bone = bin.readBoneIndex();
	if ( bin.readUint8() === 1 ) {
		this.limits = [ bin.readVector(3), bin.readVector(3) ];
		 this.limits[0], this.limits[1] ;
	}
	}
	
}

dynamic class IK {
public function IK(bin:PMXReader) 
	{var n:int;
	this.effector = bin.readBoneIndex();
	this.iteration = bin.readInt32();
	this.control = bin.readFloat32();
	this.links = [];
	n = bin.readInt32();
	while ( n-- > 0 ) {
		this.links.push( new IKLink( bin ) );
	}
	}	
	
}

dynamic class Bone  {
	public function Bone(bin:PMXReader) 
	{
		this.name = bin.readText();
	//console.log('*' + this.name);
	this.nameEn = bin.readText();
	this.origin =  bin.readVector(3) ;
	this.parent = bin.readBoneIndex();
	this.deformHierachy = bin.readInt32();
	//console.log('deformHierachy ' + this.deformHierachy);
	this.flags = bin.readUint16();
	//console.log(this.flags.toString(16));
	if ( ( this.flags & 1 ) !== 0 ) {
		bin.readBoneIndex(); // dummy read
		//this.end = bin.readBoneIndex();
	} else {
		bin.readVector(3); // dummy read
		//this.end = convV( bin.readVector(3) );
	}
	/* if ( ( this.flags & 2 ) !== 0 ) {
		console.log('rotatable');
	}
	if ( ( this.flags & 4 ) !== 0 ) {
		console.log('translatable');
	}
	if ( ( this.flags & 8 ) !== 0 ) {
		console.log('visible');
	}
	if ( ( this.flags & 0x10 ) !== 0 ) {
		console.log('manipulatable');
	} */
	/* if ( ( this.flags & 0x80 ) !== 0 ) {
		//console.log('GlobalAdditionalTransform');
	} */
	if ( ( this.flags & 0x300) !== 0 ) {
		this.additionalTransform = [ bin.readBoneIndex(), bin.readFloat32() ];
		//console.log('additionalTransform(' + (this.flags & 0x300).toString(16) + ')', this.additionalTransform);
	}
	if ( ( this.flags & 0x400) !== 0 ) {
		bin.readVector(3); // dummy read
		//this.fixedAxis = convV( bin.readVector(3) );
		//console.log('fixedAxis ',this.fixedAxis);
	}
	if ( ( this.flags & 0x800) !== 0 ) {
		bin.readVector(3); bin.readVector(3); // dummy read
		//this.localCoordinate = [ convV( bin.readVector(3) ), convV( bin.readVector(3) ) ];
		//console.log('localCoordinate ', this.localCoordinate);
	}
	/* if ( ( this.flags & 0x1000) !== 0 ) {
		//this.afterPhysics = true;
		//console.log('afterPhysics');
	} */
	if ( ( this.flags & 0x2000) !== 0 ) {
		this.externalDeform = bin.readInt32(); // key
		//console.log('externalDeform ', this.externalDeform);
	}
	if ( ( this.flags & 0x20) !== 0 ) {
		this.IK = new IK( bin );
		//console.log('IK');
	}
	}
	
}

dynamic class MorphVertex{
	public function MorphVertex(bin:PMXReader) 
	{
		this.target = bin.readVertexIndex();
	this.offset =  bin.readVector(3) ;
	}
	
}

dynamic class MorphUV {
public function MorphUV(bin:PMXReader) 
	{
		this.target = bin.readVertexIndex();
	this.uv = bin.readVector(4);
	}	
	
}

dynamic class MorphBone{
	public function MorphBone(bin:PMXReader) 
	{this.target = bin.readBoneIndex();
	this.pos = bin.readVector(3);
	this.rot = bin.readVector(4);
	}
	
}

dynamic class MorphMaterial {
	public function MorphMaterial(bin:PMXReader) 
	{this.target = bin.readMaterialIndex();
	this.operator = bin.readUint8();
	this.diffuse = bin.readVector(3);
	this.alpha = bin.readFloat32();
	this.specular = bin.readVector(3);
	this.power = bin.readFloat32();
	this.ambient = bin.readVector(3);
	this.edgeColor = bin.readVector(4);
	this.edgeSize = bin.readFloat32();
	this.texture = bin.readVector(4);
	this.sphereTexture = bin.readVector(4);
	this.toonTexture = bin.readVector(4);
	}
	
}

dynamic class MorphGroup {
public function MorphGroup(bin:PMXReader) 
	{this.target = bin.readMorphIndex(); // no group nest
	this.weight = bin.readFloat32();
	}	
	
}

dynamic class Morph {
	public function Morph(bin:PMXReader) 
	{	var n:int;
	this.name = bin.readText();
	this.nameEn = bin.readText();
	this.panel = bin.readUint8();
	this.type = bin.readUint8();
	this.items = [];

	/* // debug
	if ( this.type === 0 ) {
		console.log(this.name + ' MorphGroup');
	} else
	if ( this.type === 1 ) {
		console.log(this.name + ' MorphVertex');
	} else
	if ( this.type === 2 ) {
		console.log(this.name + ' MorphBone');
	} else
	if ( this.type >= 3 && this.type <= 7 ) {
		console.log(this.name + ' MorphUV' + (this.type - 3));
	} else
	if ( this.type === 8 ) {
		console.log(this.name + ' MorphMaterial');
	} */

	n = bin.readInt32();
	while ( n-- > 0) {
		if ( this.type === 0 ) {
			this.items.push( new MorphGroup( bin ) );
		} else
		if ( this.type === 1 ) {
			this.items.push( new MorphVertex( bin ) );
		} else
		if ( this.type === 2 ) {
			this.items.push( new MorphBone( bin ) );
		} else
		if ( this.type >= 3 && this.type <= 7 ) {
			this.items.push( new MorphUV( bin ) );
		} else
		if ( this.type === 8 ) {
			this.items.push( new MorphMaterial( bin ) );
		} else {
			throw "Exception.DATA";
		}
	}
	}

}

dynamic class FrameItem  {
	public function FrameItem(bin:PMXReader) 
	{this.type = bin.readUint8();
	if ( this.type === 0 ) {
		this.index = bin.readBoneIndex();
	} else
	if ( this.type === 1 ) {
		this.index = bin.readMorphIndex();
	} else {
		throw "Exception.DATA";
	}
	}
	
}

dynamic class Frame  {
	public function Frame(bin:PMXReader) 
	{var n:int;
	this.name = bin.readText();
	this.nameEn = bin.readText();
	this.special = bin.readUint8();
	this.items = [];
	n = bin.readInt32();
	while (n-- > 0) {
		this.items.push( new FrameItem( bin ) );
	}
	}
	
}

dynamic class Rigid { // rigid body
	public function Rigid(bin:PMXReader) 
	{this.name = bin.readText();
	this.nameEn = bin.readText();
	this.bone = bin.readBoneIndex();
	this.group = bin.readUint8();
	this.mask = bin.readUint16();
	this.shape = bin.readUint8();
	this.size = bin.readVector(3);
	this.pos =  bin.readVector(3) ;
	this.rot =  bin.readVector(3) ;
	this.mass = bin.readFloat32();
	this.posDamping = bin.readFloat32();
	this.rotDamping = bin.readFloat32();
	this.restitution = bin.readFloat32();
	this.friction = bin.readFloat32();
	this.type = bin.readUint8();
	}
	
}

dynamic class Joint { // constraint between two rigid bodies
	public function Joint(bin:PMXReader) 
	{this.name = bin.readText();
	this.nameEn = bin.readText();
	this.type = bin.readUint8();
	this.rigidA = bin.readRigidIndex();
	this.rigidB = bin.readRigidIndex();
	this.pos = bin.readVector(3) ;
	this.rot =  bin.readVector(3) ;
	this.posLower = bin.readVector(3);
	this.posUpper = bin.readVector(3);
	 this.posLower, this.posUpper ;
	this.rotLower = bin.readVector(3);
	this.rotUpper = bin.readVector(3);
	 this.rotLower, this.rotUpper ;
	this.posSpring = bin.readVector(3);
	this.rotSpring = bin.readVector(3);
	}
	
}