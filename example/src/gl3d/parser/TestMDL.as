package gl3d.parser {
	import flash.display.Sprite;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestMDL extends Sprite
	{
		
		public function TestMDL() 
		{
			[Embed(source = "../../assets/barney.mdl", mimeType = "application/octet-stream")]
			var mdlc:Class;
			var mdlb:ByteArray = new mdlc as ByteArray;
			mdlb.endian = Endian.LITTLE_ENDIAN;
			//https://developer.valvesoftware.com/wiki/MDL
			//http://tfc.duke.free.fr/coding/mdl-specs-en.html
			var studiohdr_t:Struct = new Struct([
				int		,"id",		// Model format ID, such as "IDST" (0x49 0x44 0x53 0x54)
				int		,"version",	// Format version number, such as 48 (0x30,0x00,0x00,0x00)
				new Char(64)	,"name",		// The internal name of the model, padding with null bytes.
								// Typically "my_model.mdl" will have an internal name of "my_model"
				int		,"dataLength",	// Data size of MDL file in bytes.
			 
				// A vector is 12 bytes, three 4-byte float-values in a row.
				Vector3D		,"eyeposition",	// Position of player viewpoint relative to model origin
				Vector3D		,"illumposition",	// ?? Presumably the point used for lighting when per-vertex lighting is not enabled.
				Vector3D		,"hull_min",	// Corner of model hull box with the least X/Y/Z values
				Vector3D		,"hull_max",	// Opposite corner of model hull box
				Vector3D	  	,"view_bbmin",
				Vector3D	 	,"view_bbmax",
			 
				int		,"flags",		// Binary flags in little-endian order. 
								// ex (00000001,00000000,00000000,11000000) means flags for position 0, 30, and 31 are set. 
								// Set model flags section for more information
			 
				/*
				 * After this point, the header contains many references to offsets
				 * within the MDL file and the number of items at those offsets.
				 *
				 * Offsets are from the very beginning of the file.
				 * 
				 * Note that indexes/counts are not always paired and ordered consistently.
				 */	
			 
				// mstudiobone_t
				int		,"bone_count",	// Number of data sections (of type mstudiobone_t)
				int		,"bone_offset",	// Offset of first data section
			 
				// mstudiobonecontroller_t
				int		,"bonecontroller_count",
				int		,"bonecontroller_offset",
			 
				// mstudiohitboxset_t
				int		,"hitbox_count",
				int		,"hitbox_offset",
			 
				// mstudioanimdesc_t
				int		,"localanim_count",
				int		,"localanim_offset",
			 
				// mstudioseqdesc_t
				int		,"localseq_count",
				int		,"localseq_offset",
			 
				int		,"activitylistversion", // ??
				int		,"eventsindexed",	// ??
			 
				// VMT texture filenames
				// mstudiotexture_t
				int		,"texture_count",
				int		,"texture_offset",
			 
				// This offset points to a series of ints.
					// Each int value, in turn, is an offset relative to the start of this header/the-file,
					// At which there is a null-terminated string.
				int		,"texturedir_count",
				int		,"texturedir_offset",
			 
				// Each skin-family assigns a texture-id to a skin location
				int		,"skinreference_count",
				int		,"skinrfamily_count",
				int             ,"skinreference_index",
			 
				// mstudiobodyparts_t
				int		,"bodypart_count",
				int		,"bodypart_offset",
			 
					// Local attachment points		
				// mstudioattachment_t
				int		,"attachment_count",
				int		,"attachment_offset",
			 
				// Node values appear to be single bytes, while their names are null-terminated strings.
				int		,"localnode_count",
				int		,"localnode_index",
				int		,"localnode_name_index",
			 
				// mstudioflexdesc_t
				int		,"flexdesc_count",
				int		,"flexdesc_index",
			 
				// mstudioflexcontroller_t
				int		,"flexcontroller_count",
				int		,"flexcontroller_index",
			 
				// mstudioflexrule_t
				int		,"flexrules_count",
				int		,"flexrules_index",
			 
				// IK probably referse to inverse kinematics
				// mstudioikchain_t
				int		,"ikchain_count",
				int		,"ikchain_index",
			 
				// Information about any "mouth" on the model for speech animation
				// More than one sounds pretty creepy.
				// mstudiomouth_t
				int		,"mouths_count",
				int		,"mouths_index",
			 
				// mstudioposeparamdesc_t
				int		,"localposeparam_count",
				int		,"localposeparam_index",
			 
				/*
				 * For anyone trying to follow along, as of this writing,
				 * the next "surfaceprop_index" value is at position 0x0134 (308)
				 * from the start of the file.
				 */
			 
				// Surface property value (single null-terminated string)
				int		,"surfaceprop_index",
			 
				// Unusual: In this one index comes first, then count.
				// Key-value data is a series of strings. If you can't find
				// what you're interested in, check the associated PHY file as well.
				int		,"keyvalue_index",
				int		,"keyvalue_count",	
			 
				// More inverse-kinematics
				// mstudioiklock_t
				int		,"iklock_count",
				int		,"iklock_index",
			 
			 
				Number		,"mass", 		// Mass of object (4-bytes)
				int		,"contents",	// ??
			 
				// Other models can be referenced for re-used sequences and animations
				// (See also: The $includemodel QC option.)
				// mstudiomodelgroup_t
				int		,"includemodel_count",
				int		,"includemodel_index",
			 
				int		,"virtualModel",	// Placeholder for mutable-void*
			 
				// mstudioanimblock_t
				int		,"animblocks_name_index",
				int		,"animblocks_count",
				int		,"animblocks_index",
			 
				int		,"animblockModel", // Placeholder for mutable-void*
			 
				// Points to a series of bytes?
				int		,"bonetablename_index",
			 
				int		,"vertex_base",	// Placeholder for void*
				int		,"offset_base",	// Placeholder for void*
			 
				// Used with $constantdirectionallight from the QC 
				// Model should have flag #13 set if enabled
				Byte		,"directionaldotproduct",
			 
				Byte		,"rootLod",	// Preferred rather than clamped
			 
				// 0 means any allowed, N means Lod 0 -> (N-1)
				Byte		,"numAllowedRootLods",	
			 
				Byte		,"unused", // ??
				int		,"unused", // ??
			 
				// mstudioflexcontrollerui_t
				int		,"flexcontrollerui_count",
				int		,"flexcontrollerui_index",
			 
				/**
				 * Offset for additional header information.
				 * May be zero if not present, or also 408 if it immediately 
				 * follows this studiohdr_t
				 */
				// studiohdr2_t
				int		,"studiohdr2index",
			 
				int		,"unused" // ??
			 
				/**
				 * As of this writing, the header is 408 bytes long in total
				 */
			]);
			var studiohdr:Object=studiohdr_t.parser(mdlb)
			studiohdr_t.stringify(studiohdr);
			
			var studiohdr2_t:Struct = new Struct([
				int		,"srcbonetransform_count",
				int		,"srcbonetransform_index",
			 
				int		,"illumpositionattachmentindex",
			 
				Number		,"flMaxEyeDeflection",	//  If set to 0, then equivalent to cos(30)
			 
				// mstudiolinearbone_t
				int		,"linearbone_index",
			 
				new Arr(int,64) 	,"unknown"
			]);
			var studiohdr2:Object = { };
			if (studiohdr.studiohdr2index>0) {
				mdlb.position = studiohdr.studiohdr2index;
				studiohdr2_t.parser(mdlb);
			}
			studiohdr2_t.stringify(studiohdr2);
			
		}
		
	}

}
import flash.geom.Vector3D;
import flash.utils.ByteArray;

class Struct {
	public var types:Vector.<Type> = new Vector.<Type>;
	
	public function Struct(arr:Array) 
	{
		if (arr) {
			pushs(arr);
		}
	}
	
	public function pushs(arr:Array):void {
		for (var i:int = 0; i < arr.length;i+=2 ) {
			push(arr[i], arr[i + 1]);
		}
	}
	
	public function push(type:Object, name:String):void {
		types.push(new Type(type, name));
	}
	
	public function parser(byte:ByteArray):Object {
		var obj:Object = { };
		for each(var type:Type in types) {
			obj[type.name] = type.parser(byte);
		}
		return obj;
	}
	
	public function stringify(obj:Object):void {
		for each(var type:Type in types) {
			trace(type.name,obj[type.name]);
		}
	}
}
class Type {
	public var type:Object;
	public var name:String;
	public function Type(type:Object, name:String):void {
		this.name = name;
		this.type = type;
	}
	
	public function parser(byte:ByteArray):Object {
		if (type == int) {
			return byte.readInt();
		}else if (type == Number) {
			return byte.readFloat();
		}else if (type == Byte) {
			return byte.readByte();
		}else if (type == Vector3D) {
			return new Vector3D(byte.readFloat(), byte.readFloat(), byte.readFloat());
		}else if (type is Char) {
			return byte.readUTFBytes((type as Char).len);
		}else if (type is Arr) {
			var a:Arr = type as Arr;
			var v:Array = [];
			for (var i:int = 0; i < a.len;i++ ) {
				v.push(a.type.parser(byte));
			}
			return v;
		}
		return null;
	}
}
class Char {
	public var len:int;
	public function Char(len:int) {
		this.len = len;
		
	}
}

class Arr {
	public var type:Type;
	public var len:int;
	public function Arr(t:Object,len:int) {
		this.type = new Type(t, null);
		this.len = len;
	}
}

class Byte {
	
}