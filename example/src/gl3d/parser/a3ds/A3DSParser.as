package gl3d.parser.a3ds
{
	// ===========================================================================
	//	Imports
	// ---------------------------------------------------------------------------
	import flash.geom.Matrix3D;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import gl3d.core.Drawable;
	import gl3d.core.DrawableSource;
	import gl3d.core.Material;
	import gl3d.core.Node3D;
	import gl3d.meshs.Meshs;
	public class A3DSParser
	{
		private static const ID_3DS:uint							= 0x4D4D;
		private static const ID_3DS_VERSION:uint					= 0x0002;
		
		private static const ID_3DS_EDIT:uint						= 0x3D3D;
		private static const ID_3DS_EDIT_CONFIG:uint				= 0x3D3E;
		private static const ID_3DS_EDIT_MATERIAL:uint				= 0xAFFF;
		private static const ID_3DS_EDIT_MATERIAL_UNK1:uint			= 0xA000;
		private static const ID_3DS_EDIT_MATERIAL_UNK2:uint			= 0xA010;
		private static const ID_3DS_EDIT_MATERIAL_UNK3:uint			= 0xA020;
		private static const ID_3DS_EDIT_MATERIAL_UNK4:uint			= 0xA030;
		private static const ID_3DS_EDIT_MATERIAL_UNK5:uint			= 0xA040;
		private static const ID_3DS_EDIT_MATERIAL_UNK6:uint			= 0xA041;
		private static const ID_3DS_EDIT_MATERIAL_UNK7:uint			= 0xA050;
		private static const ID_3DS_EDIT_MATERIAL_UNK8:uint			= 0xA052;
		private static const ID_3DS_EDIT_MATERIAL_UNK9:uint			= 0xA053;
		private static const ID_3DS_EDIT_MATERIAL_UNK10:uint		= 0xA084;
		private static const ID_3DS_EDIT_MATERIAL_UNK11:uint		= 0xA087;
		private static const ID_3DS_EDIT_MATERIAL_UNK12:uint		= 0xA100;
		
		private static const ID_3DS_EDIT_CONFIG_1:uint				= 0x0100;
		private static const ID_3DS_EDIT_CONFIG_2:uint				= 0x3E3D;
		private static const ID_3DS_EDIT_VIEW_1:uint				= 0x7001;
		private static const ID_3DS_EDIT_VIEW_P2:uint				= 0x7011;
		private static const ID_3DS_EDIT_VIEW_P1:uint				= 0x7012;
		private static const ID_3DS_EDIT_VIEW_P3:uint				= 0x7020;
		private static const ID_3DS_EDIT_VIEW_TOP:uint				= 0x0001;
		private static const ID_3DS_EDIT_VIEW_BOTTOM:uint			= 0x0002;
		private static const ID_3DS_EDIT_VIEW_LEFT:uint				= 0x0003;
		private static const ID_3DS_EDIT_VIEW_RIGHT:uint			= 0x0004;
		private static const ID_3DS_EDIT_VIEW_FRONT:uint			= 0x0005;
		private static const ID_3DS_EDIT_VIEW_BACK:uint				= 0x0006;
		private static const ID_3DS_EDIT_VIEW_USER:uint				= 0x0007;
		private static const ID_3DS_EDIT_VIEW_CAMERA:uint			= 0xFFFF;
		private static const ID_3DS_EDIT_VIEW_LIGHT:uint			= 0x0009;
		private static const ID_3DS_EDIT_VIEW_DISABLED:uint			= 0x0010;
		private static const ID_3DS_EDIT_VIEW_BOGUS:uint			= 0x0011;	
		private static const ID_3DS_EDIT_BACKGR:uint				= 0x1200;
		private static const ID_3DS_EDIT_AMBIENT:uint				= 0x2100;
		private static const ID_3DS_EDIT_OBJ:uint					= 0x4000;
		private static const ID_3DS_EDIT_OBJ_TRI:uint				= 0x4100;
		private static const ID_3DS_EDIT_OBJ_TRI_VTXL:uint			= 0x4110;
		private static const ID_3DS_EDIT_OBJ_TRI_VTXOPT:uint		= 0x4111;
		private static const ID_3DS_EDIT_OBJ_TRI_FACEL1:uint		= 0x4120;
		private static const ID_3DS_EDIT_OBJ_TRI_MATERIAL:uint		= 0x4130;
		private static const ID_3DS_EDIT_OBJ_TRI_UV:uint			= 0x4140;
		private static const ID_3DS_EDIT_OBJ_TRI_SMOOTH:uint		= 0x4150;
		private static const ID_3DS_EDIT_OBJ_TRI_LOCAL:uint			= 0x4160;
		private static const ID_3DS_EDIT_OBJ_TRI_VISIBLE:uint		= 0x4165;
		private static const ID_3DS_EDIT_OBJ_TRI_MAPSTD:uint		= 0x4170;
		private static const ID_3DS_EDIT_OBJ_LIGHT:uint				= 0x4600;
		private static const ID_3DS_EDIT_OBJ_LIGHT_OFF:uint			= 0x4620;
		private static const ID_3DS_EDIT_OBJ_LIGHT_SPOT:uint		= 0x4610;
		private static const ID_3DS_EDIT_OBJ_LIGHT_UNK1:uint		= 0x465A;
		private static const ID_3DS_EDIT_OBJ_CAMERA:uint			= 0x4700;
		private static const ID_3DS_EDIT_OBJ_CAMERA_UNK1:uint		= 0x4710;
		private static const ID_3DS_EDIT_OBJ_CAMERA_UNK2:uint		= 0x4720;
		private static const ID_3DS_EDIT_OBJ_UNK1:uint				= 0x4710;
		private static const ID_3DS_EDIT_OBJ_UNK2:uint				= 0x4720;
		private static const ID_3DS_EDIT_UNK1:uint					= 0x1100;
		private static const ID_3DS_EDIT_UNK2:uint					= 0x1201;
		private static const ID_3DS_EDIT_UNK3:uint					= 0x1300;
		private static const ID_3DS_EDIT_UNK4:uint					= 0x1400;
		private static const ID_3DS_EDIT_UNK5:uint					= 0x1420;
		private static const ID_3DS_EDIT_UNK6:uint					= 0x1450;
		private static const ID_3DS_EDIT_UNK7:uint					= 0x1500;
		private static const ID_3DS_EDIT_UNK8:uint					= 0x2200;
		private static const ID_3DS_EDIT_UNK9:uint					= 0x2201;
		private static const ID_3DS_EDIT_UNK10:uint					= 0x2210;
		private static const ID_3DS_EDIT_UNK11:uint					= 0x2300;
		private static const ID_3DS_EDIT_UNK12:uint					= 0x2302;
		private static const ID_3DS_EDIT_UNK13:uint					= 0x2000;
		private static const ID_3DS_EDIT_UNK14:uint					= 0xAFFF;
		
		private static const ID_3DS_KEYF:uint						= 0xB000;
		private static const ID_3DS_KEYF_UNK1:uint					= 0xB00A;
		private static const ID_3DS_KEYF_FRAMES:uint				= 0xB008;
		private static const ID_3DS_KEYF_UNK2:uint					= 0xB009;
		private static const ID_3DS_KEYF_OBJDES:uint				= 0xB002;
		private static const ID_3DS_KEYF_OBJHIERARCH:uint			= 0xB010;
		private static const ID_3DS_KEYF_OBJDUMMYNAME:uint			= 0xB011;
		private static const ID_3DS_KEYF_OBJUNK1:uint				= 0xB013;
		private static const ID_3DS_KEYF_OBJUNK2:uint				= 0xB014;
		private static const ID_3DS_KEYF_OBJUNK3:uint				= 0xB015;
		private static const ID_3DS_KEYF_OBJPIVOT:uint				= 0xB020;
		private static const ID_3DS_KEYF_OBJUNK4:uint				= 0xB021;
		private static const ID_3DS_KEYF_OBJUNK5:uint				= 0xB022;
		
		protected var _version:uint;
		
		protected var _objects:Vector.<A3DSObject>					= new Vector.<A3DSObject>();
		protected var _materials:Vector.<A3DSMaterial>				= new Vector.<A3DSMaterial>();
		
		protected var _currentObject:A3DSObject;
		public var root:Node3D = new Node3D;
		public function A3DSParser(bytes:ByteArray)
		{
			bytes.position = 0;
			bytes.endian = Endian.LITTLE_ENDIAN;
			
			if ( bytes.bytesAvailable < 6 || bytes.readUnsignedShort() != ID_3DS )
			{
				trace( "Invalid 3DS file" );
				return;
			}
			
			var length:uint = bytes.readUnsignedInt();
			while( bytes.bytesAvailable )
				parse3DSChunk( bytes );
			complete();
		}
		
		private function complete():void
		{
			for each ( var obj:A3DSObject in _objects )
			{
				var node:Node3D = new Node3D(obj.name);
				root.addChild(node);
				if(obj.indices){
				node.drawable = Meshs.createDrawable(obj.indices, obj.positions, obj.texcoords);
				node.material = new Material;
				}
				if(obj.transform)
				node.matrix = obj.transform.clone();
			}
		}
		
		protected function parse3DSChunk( bytes:ByteArray ):void
		{
			var id:uint = bytes.readUnsignedShort();
			var size:uint = bytes.readUnsignedInt() - 6;
			
			trace( "\n[ 0x" + id.toString( 16 ) + " ] - " + size );	
			switch( id )
			{
				case ID_3DS_VERSION:
					trace( "version" );
					_version = bytes.readUnsignedInt();
					break;
				
				case ID_3DS_EDIT:		parseEditChunk( bytes, size );		break
				case ID_3DS_KEYF:		parseKeyframeChunk( bytes, size );	break;
				
				default:
					trace( "Unknown chunk:0x", id.toString(16));
					bytes.position += size;
			}
		}
		
		protected function parseEditChunk( bytes:ByteArray, size:uint ):void
		{
			trace( "edit" );
			var end:uint = bytes.position + size;
			while( bytes.position < end )
				parseEditSubchunk( bytes );
		}
		
		protected function parseEditSubchunk( bytes:ByteArray ):void
		{
			var id:uint = bytes.readUnsignedShort();
			var size:uint = bytes.readUnsignedInt() - 6;
			
			trace( "\n[ 0x" + id.toString( 16 ) + " ] - " + size );
			switch( id )
			{
				case ID_3DS_EDIT_OBJ:		parseObject( bytes, size );			break;
				case ID_3DS_EDIT_MATERIAL:	parseMaterial( bytes, size );		break;
				case ID_3DS_EDIT_CONFIG:	parseConfig( bytes, size );			break;
				case ID_3DS_EDIT_CONFIG_1:	parseConfig( bytes, size );			break;
				
				default:
					trace( "Unknown chunk:0x", id.toString(16) );
					bytes.position += size;
			}
		}
		
		protected function parseMaterial( bytes:ByteArray, size:uint ):void
		{
			trace( "TODO: material" );
			bytes.position += size;
		}
		
		protected function parseObject( bytes:ByteArray, size:uint ):void
		{
			trace( "object" );
			
			_currentObject = new A3DSObject();
			_objects.push( _currentObject );
			
			var name:String = "";
			var length:uint = 1;
			while ( true )
			{
				var char:String = bytes.readUTFBytes( 1 );
				if ( !char )
					break;
				
				name += char;
				length++;
			}
			_currentObject.name = name;
			
			size -= length;
			var end:uint = bytes.position + size;
			while( bytes.position < end )
				parseObjectSubchunk( bytes );
		}
		
		protected function parseObjectSubchunk( bytes:ByteArray ):void
		{
			var id:uint = bytes.readUnsignedShort();
			var size:uint = bytes.readUnsignedInt() - 6;
			
			trace( "\n[ 0x" + id.toString( 16 ) + " ] - " + size );
			switch( id )
			{
				case ID_3DS_EDIT_OBJ_TRI:	parseTriangles( bytes, size );		break;
				
				default:
					trace( "Unknown chunk:0x", id.toString(16) );
					bytes.position += size;
			}
		}
		
		protected function parseTriangles( bytes:ByteArray, size:uint ):void
		{
			trace( "triangles" );
			
			var end:uint = bytes.position + size;
			while( bytes.position < end )
				parseTrianglesSubchunk( bytes );
		}
		
		protected function parseTrianglesSubchunk( bytes:ByteArray ):void
		{
			var id:uint = bytes.readUnsignedShort();
			var size:uint = bytes.readUnsignedInt() - 6;
			var end:uint = bytes.position + size;
			trace( "\n[ 0x" + id.toString( 16 ) + " ] - " + size );
			switch( id )
			{
				case ID_3DS_EDIT_OBJ_TRI_VTXL:		parseVertexList( bytes, size );			break;
				//case ID_3DS_EDIT_OBJ_TRI_VTXOPT:
				case ID_3DS_EDIT_OBJ_TRI_FACEL1:	parseFaceList( bytes, size );			break;
				case ID_3DS_EDIT_OBJ_TRI_MATERIAL:	parseTriangleMaterial( bytes, size );	break
				case ID_3DS_EDIT_OBJ_TRI_UV:		parseUVs( bytes, size );				break;
				//case ID_3DS_EDIT_OBJ_TRI_SMOOTH:
				//case ID_3DS_EDIT_OBJ_TRI_MAPSTD:
				case ID_3DS_EDIT_OBJ_TRI_LOCAL:		parseTriangleLocal( bytes, size );		break;
				//case ID_3DS_EDIT_OBJ_TRI_VISIBLE:
				
				default:
					trace( "Unknown chunk:0x", id.toString(16) );
					bytes.position += size;
			}
			//bytes.position = end;
		}
		
		protected function parseVertexList( bytes:ByteArray, size:uint ):void
		{
			trace( "vertex list" );
			
			var count:uint = bytes.readUnsignedShort() * 3;
			if ( count * 4 != size - 2 )
			{
				trace( "Invalid size: Vertices" );
				bytes.position += size - 2;
				return;
			}
			
			var positions:Vector.<Number> = new Vector.<Number>( count, true );
			for ( var i:uint = 0; i < count; i++ )
				positions[ i ] = bytes.readFloat();
			
			_currentObject.positions = positions;
		}
		
		protected function parseFaceList( bytes:ByteArray, size:uint ):void
		{
			trace( "face list" );
			
			var count:uint = bytes.readUnsignedShort();
			//var end:int = size + bytes.position;
			if ( size != count * 8 + 2 )
				trace( "Invalid size: Faces" );
			
			var indices:Vector.<uint> = new Vector.<uint>( ( count ) * 3, true );
			var faceInfo:Vector.<uint> = new Vector.<uint>( count, true );
			for ( var i:uint = 0; i < count; i++ )
			{
				indices[ i * 3 ] = bytes.readUnsignedShort();
				indices[ i * 3 + 2 ] = bytes.readUnsignedShort();
				indices[ i * 3 + 1 ] = bytes.readUnsignedShort();
				faceInfo[ i ] = bytes.readUnsignedShort();
			}
			
			_currentObject.indices = indices;
			_currentObject.faceInfo = faceInfo;
			
			//bytes.position = end;
		}
		
		protected function parseTriangleMaterial( bytes:ByteArray, size:uint ):void
		{
			trace( "triangle material" );
			
			var name:String = "";
			var length:uint = 1;
			while ( true )
			{
				var char:String = bytes.readUTFBytes( 1 );
				if ( !char )
					break;
				
				name += char;
				length++;
			}
			
			var count:uint = bytes.readUnsignedShort();
			
			var faces:Vector.<uint> = new Vector.<uint>( count, true );
			
			for ( var i:uint = 0; i < count; i++ )
				faces[ i ] = bytes.readUnsignedShort();
			
			_currentObject.materialAssignments.push( new A3DSMaterialAssignment( name, faces ) );
		}
		
		protected function parseUVs( bytes:ByteArray, size:uint ):void
		{
			trace( "UVs" );
			
			var count:uint = bytes.readUnsignedShort() * 2;
			if ( size != count * 4 + 2 )
				trace( "Invalid size: UVs" );
			
			var texcoords:Vector.<Number> = new Vector.<Number>( count, true );
			
			for ( var i:uint = 0; i < count; i++ )
				texcoords[ i ] = bytes.readFloat();
			
			_currentObject.texcoords = texcoords;
		}
		
		protected function parseTriangleLocal( bytes:ByteArray, size:uint ):void
		{
			trace( "triangle local" );
						if ( size != 48 )
							trace( "Invalid size!" );
			var data:Vector.<Number>=new <Number>[ 
					bytes.readFloat(), bytes.readFloat(), bytes.readFloat(), 0,
					bytes.readFloat(), bytes.readFloat(), bytes.readFloat(), 0,
					bytes.readFloat(), bytes.readFloat(), bytes.readFloat(), 0,
					bytes.readFloat(), bytes.readFloat(), bytes.readFloat(), 1
				]
			var transform:Matrix3D = new Matrix3D();
			transform.copyRawDataFrom(data, 0, false);
			trace( transform.rawData );
			
			_currentObject.transform = transform;
		}
		
		protected function parseConfig( bytes:ByteArray, size:uint ):void
		{
			trace( "TODO: config" );
			bytes.position += size;
		}
		
		protected function parseKeyframeChunk( bytes:ByteArray, size:uint ):void
		{
			trace( "TODO: keyframe" );
			bytes.position += size;
		}
	}
}

import flash.geom.Matrix3D;

	class A3DSMaterial
	{
		public var name:String;
	}
	
	class A3DSObject
	{
		public var name:String;
		public var indices:Vector.<uint>;
		public var faceInfo:Vector.<uint>;
		public var positions:Vector.<Number>;
		public var texcoords:Vector.<Number>;
		public var materialAssignments:Vector.<A3DSMaterialAssignment>;
		public var transform:Matrix3D;
		
		public function A3DSObject()
		{
			materialAssignments = new Vector.<A3DSMaterialAssignment>();
		}
		
		public function toString():String
		{
			return "name:\t" + name + "\n"
				+ "indices:\t" + indices + "\n"
				+ "faceInfo:\t" + faceInfo + "\n"
				+ "positions:\t" + positions + "\n"
				+ "texcoords:\t" + texcoords + "\n"
				+ "assignments:\n" + materialAssignments + "\n"
				+ (transform ? "transform:\t" + transform.rawData + "\n" : "" )
		}
	}
	
	class A3DSMaterialAssignment
	{
		public var name:String;
		public var faces:Vector.<uint>;
		
		public function A3DSMaterialAssignment( name:String, faces:Vector.<uint> )
		{
			this.name = name;
			this.faces = faces;
		}
		
		public function toString():String
		{
			return "name:\t" + name + "\n"
				+ "faces:\t" + faces
		}
	}

