package flShader 
{
	import flash.display3D.Context3DProgramType;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	/**
	 * ...
	 * @author lizhi
	 */
	public class AGALByteCreator extends Creator
	{
		
		private static var initialized:Boolean					= false;
		public var verbose:Boolean								= false;
		public var  version:uint;
		public var _error:String;
		public function AGALByteCreator(version:uint=1) 
		{
			this.version = version;
		}
		
		override public function creat(shader:FlShader):void 
		{
			if (!initialized) {
				init();
				initregmap(1, false); 
				initregmap(2, false); 
			}
			var REGMAP:Dictionary = version == 1?REGMAP1:REGMAP2;
			var isFrag:Boolean=shader.programType==Context3DProgramType.FRAGMENT
			var programTypeName:String;
			if (shader.programType==Context3DProgramType.VERTEX) {
				programTypeName = "v";
			}else {
				programTypeName = "f";
			}
			
			var agalcode:ByteArray = new ByteArray;
			data = agalcode;
			agalcode.endian = Endian.LITTLE_ENDIAN;
			agalcode.writeByte( 0xa0 );				// tag version
			agalcode.writeUnsignedInt( version );		// AGAL version, big endian, bit pattern will be 0x01000000
			agalcode.writeByte( 0xa1 );				// tag program id
			agalcode.writeByte( isFrag ? 1 : 0 );	// vertex or fragment
			
			
			var lines:Array = shader.lines;
			var nops:int = 0;
			for (var i:int = 0; i < lines.length;i++ ) {
				var line:Array = lines[i];
				var opName:String = line[0];
				var opFound:OpCode = OPMAP[opName];
				var opts:Array=line.flag;
				if ( opFound == null )
				{
					if ( line.length >= 3 )
						trace( "warning: bad line "+i+": "+lines[i] );
					continue;
				}
				
				if ( ( opFound.flags & OP_VERSION2 ) && version<2 )
				{
					_error = "error: opcode requires version 2.";
					break;					
				}
					
				if ( ( opFound.flags & OP_VERT_ONLY ) && isFrag )
				{
					_error = "error: opcode is only allowed in vertex programs.";
					break;
				}		
					
				if ( ( opFound.flags & OP_FRAG_ONLY ) && !isFrag )
				{
					_error = "error: opcode is only allowed in fragment programs.";
					break;
				}
				if ( verbose )
					trace( "emit opcode=" + opFound );
				
				agalcode.writeUnsignedInt( opFound.emitCode );
				nops++;
				
				if ( nops > MAX_OPCODES )
				{
					_error = "error: too many opcodes. maximum is "+MAX_OPCODES+".";
					break;
				}
				
				
				var badreg:Boolean	= false;
				var pad:uint		= 160//64 + 64 + 32;
				var regLength:uint	= line.length-1;
				
				for ( var j:int = 0; j < regLength; j++ )
				{
					var v:Var = line[j+1];
					var regidx:uint = v.index;
					var isRelative:Boolean = v.component is Var
					if ( verbose &&isRelative)
							trace( "IS REL" );
					var regFound:Register = REGMAP[ programTypeName+v.type ];
					
					
					if ( regFound == null )
					{
						_error = "error: could not find register name for operand "+j+" ("+v.type+").";
						badreg = true;
						break;
					}
					
					if ( isFrag )
					{
						if ( !( regFound.flags & REG_FRAG ) )
						{
							_error = "error: register operand "+j+" ("+v.type+") only allowed in vertex programs.";
							badreg = true;
							break;
						}
						if ( isRelative )
						{
							_error = "error: register operand "+j+" ("+v.type+") relative adressing not allowed in fragment programs.";
							badreg = true;
							break;
						}			
					}
					else
					{
						if ( !( regFound.flags & REG_VERT ) )
						{
							_error = "error: register operand "+j+" ("+v.type+") only allowed in fragment programs.";
							badreg = true;
							break;
						}
					}
					if ( regFound.range < regidx )
					{
						_error = "error: register operand "+j+" ("+v.type+") index exceeds limit of "+(regFound.range+1)+".";
						badreg = true;
						break;
					}
					
					var regmask:uint		= 0;
					var maskmatch:String=null
					if(v.component is String)
						maskmatch	= v.component as String;
					var isDest:Boolean		= ( j == 0 && !( opFound.flags & OP_NO_DEST ) );
					var isSampler:Boolean	= ( j == 2 && ( opFound.flags & OP_SPECIAL_TEX ) );
					var reltype:uint		= 0;
					var relsel:uint			= 0;
					var reloffset:int		= 0;
					
					if ( isDest && isRelative )
					{
						_error = "error: relative can not be destination";	
						badreg = true; 
						break;								
					}
					
					if ( maskmatch )
					{
						regmask = 0;
						var cv:uint; 
						var maskLength:uint = maskmatch.length;
						for ( var k:int = 1; k <= maskLength; k++ )
						{
							cv = maskmatch.charCodeAt(k-1) - "x".charCodeAt(0);
							if ( cv > 2 )
								cv = 3;
							if ( isDest )
								regmask |= 1 << cv;
							else
								regmask |= cv << ( ( k - 1 ) << 1 );
						}
						if ( !isDest )
							for ( ; k <= 4; k++ )
								regmask |= cv << ( ( k - 1 ) << 1 ); // repeat last								
					}
					else
					{
						regmask = isDest ? 0xf : 0xe4; // id swizzle or mask						
					}
					
					if ( isRelative )
					{
						var relv:Var = v.component as Var;	
						regidx = relv.index;
						var regFoundRel:Register = REGMAP[programTypeName+relv.type];						
						if ( regFoundRel == null )
						{ 
							_error = "error: bad index register"; 
							badreg = true; 
							break;
						}
						reltype = regFoundRel.emitCode;
						relsel = (relv.component as String).charCodeAt(0) - "x".charCodeAt(0);
						if ( relsel > 2 )
							relsel = 3; 
						reloffset = v.index;//relv.offset; 						
						if ( reloffset < 0 || reloffset > 255 )
						{
							_error = "error: index offset "+reloffset+" out of bounds. [0..255]"; 
							badreg = true; 
							break;							
						}
						if ( verbose )
							trace( "RELATIVE: type="+reltype+"=="+" sel="+relsel+"=="+" idx="+regidx+" offset="+reloffset ); 
					}
					
					if ( verbose )
						trace( "  emit argcode="+regFound+"["+regidx+"]["+regmask+"]" );
					if ( isDest )
					{												
						agalcode.writeShort( regidx );
						agalcode.writeByte( regmask );
						agalcode.writeByte( regFound.emitCode );
						pad -= 32; 
					} else
					{
						if ( isSampler )
						{
							if ( verbose )
								trace( "  emit sampler" );
							var samplerbits:uint = 5; // type 5 
							var optsLength:uint = opts == null ? 0 : opts.length;
							var bias:Number = 0; 
							for ( k = 0; k<optsLength; k++ )
							{
								if ( verbose )
									trace( "    opt: "+opts[k] );
								var optfound:Sampler = SAMPLEMAP [opts[k]];
								if ( optfound == null )
								{
									// todo check that it's a number...
									//trace( "Warning, unknown sampler option: "+opts[k] );
									bias = Number(opts[k]); 
									if ( verbose )
										trace( "    bias: " + bias );																	
								}
								else
								{
									if ( optfound.flag != SAMPLER_SPECIAL_SHIFT )
										samplerbits &= ~( 0xf << optfound.flag );										
									samplerbits |= uint( optfound.mask ) << uint( optfound.flag );
								}
							}
							agalcode.writeShort( regidx );
							agalcode.writeByte(int(bias*8.0));
							agalcode.writeByte(0);							
							agalcode.writeUnsignedInt( samplerbits );
							
							if ( verbose )
								trace( "    bits: " + ( samplerbits - 5 ) );
							pad -= 64;
						}
						else
						{
							if ( j == 0 )
							{
								agalcode.writeUnsignedInt( 0 );
								pad -= 32;
							}
							agalcode.writeShort( regidx );
							agalcode.writeByte( reloffset );
							agalcode.writeByte( regmask );
							agalcode.writeByte( regFound.emitCode );
							agalcode.writeByte( reltype );
							agalcode.writeShort( isRelative ? ( relsel | ( 1 << 15 ) ) : 0 );
							
							pad -= 64;
						}
					}
				}
				
				// pad unused regs
				for ( j = 0; j < pad; j += 8 ) 
					agalcode.writeByte( 0 );
				
				if ( badreg )
					break;
			}
		}		
		
		static private function initregmap ( version:uint, ignorelimits:Boolean ) : void {
			// version changes limits	
			var REGMAP:Dictionary = version == 1?REGMAP1:REGMAP2;
			REGMAP[ "v"+Var.TYPE_VA ]	= new Register( VA,	"vertex attribute",		0x0,	ignorelimits?1024:7,						REG_VERT | REG_READ );
			REGMAP["v"+ Var.TYPE_C ]	= new Register( VC,	"vertex constant",		0x1,	ignorelimits?1024:(version==1?127:249),		REG_VERT | REG_READ );
			REGMAP[ "v"+Var.TYPE_T ]	= new Register( VT,	"vertex temporary",		0x2,	ignorelimits?1024:(version==1?7:25),		REG_VERT | REG_WRITE | REG_READ );
			REGMAP[ "v"+Var.TYPE_OP ]	= new Register( VO,	"vertex output",		0x3,	ignorelimits?1024:0,						REG_VERT | REG_WRITE );
			
			REGMAP[ "v"+Var.TYPE_V ]	= 
			REGMAP[ "f"+Var.TYPE_V ]	= new Register( VI,	"varying",				0x4,	ignorelimits?1024:(version==1?7:9),		REG_VERT | REG_FRAG | REG_READ | REG_WRITE );			
			
			REGMAP[ "f"+Var.TYPE_C ]	= new Register( FC,	"fragment constant",	0x1,	ignorelimits?1024:(version==1?27:63),		REG_FRAG | REG_READ );
			REGMAP[ "f"+Var.TYPE_T ]	= new Register( FT,	"fragment temporary",	0x2,	ignorelimits?1024:(version==1?7:25),		REG_FRAG | REG_WRITE | REG_READ );
			REGMAP[ "f"+Var.TYPE_FS ]	= new Register( FS,	"texture sampler",		0x5,	ignorelimits?1024:7,						REG_FRAG | REG_READ );
			REGMAP[ "f"+Var.TYPE_OC ]	= new Register( FO,	"fragment output",		0x3,	ignorelimits?1024:(version==1?0:3),			REG_FRAG | REG_WRITE );				
			//REGMAP[ FD ]	= new Register( FD,	"fragment depth output",0x6,	ignorelimits?1024:(version==1?-1:0),		REG_FRAG | REG_WRITE );
		}
		
		static private function init():void
		{
			initialized = true;
			
			// Fill the dictionaries with opcodes and registers
			OPMAP[ MOV ] = new OpCode( MOV, 2, 0x00, 0 );
			OPMAP[ ADD ] = new OpCode( ADD, 3, 0x01, 0 );
			OPMAP[ SUB ] = new OpCode( SUB, 3, 0x02, 0 );
			OPMAP[ MUL ] = new OpCode( MUL, 3, 0x03, 0 );
			OPMAP[ DIV ] = new OpCode( DIV, 3, 0x04, 0 );
			OPMAP[ RCP ] = new OpCode( RCP, 2, 0x05, 0 );					
			OPMAP[ MIN ] = new OpCode( MIN, 3, 0x06, 0 );
			OPMAP[ MAX ] = new OpCode( MAX, 3, 0x07, 0 );
			OPMAP[ FRC ] = new OpCode( FRC, 2, 0x08, 0 );			
			OPMAP[ SQT ] = new OpCode( SQT, 2, 0x09, 0 );
			OPMAP[ RSQ ] = new OpCode( RSQ, 2, 0x0a, 0 );
			OPMAP[ POW ] = new OpCode( POW, 3, 0x0b, 0 );
			OPMAP[ LOG ] = new OpCode( LOG, 2, 0x0c, 0 );
			OPMAP[ EXP ] = new OpCode( EXP, 2, 0x0d, 0 );
			OPMAP[ NRM ] = new OpCode( NRM, 2, 0x0e, 0 );
			OPMAP[ SIN ] = new OpCode( SIN, 2, 0x0f, 0 );
			OPMAP[ COS ] = new OpCode( COS, 2, 0x10, 0 );
			OPMAP[ CRS ] = new OpCode( CRS, 3, 0x11, 0 );
			OPMAP[ DP3 ] = new OpCode( DP3, 3, 0x12, 0 );
			OPMAP[ DP4 ] = new OpCode( DP4, 3, 0x13, 0 );					
			OPMAP[ ABS ] = new OpCode( ABS, 2, 0x14, 0 );
			OPMAP[ NEG ] = new OpCode( NEG, 2, 0x15, 0 );
			OPMAP[ SAT ] = new OpCode( SAT, 2, 0x16, 0 );
			OPMAP[ M33 ] = new OpCode( M33, 3, 0x17, OP_SPECIAL_MATRIX );
			OPMAP[ M44 ] = new OpCode( M44, 3, 0x18, OP_SPECIAL_MATRIX );
			OPMAP[ M34 ] = new OpCode( M34, 3, 0x19, OP_SPECIAL_MATRIX );		
			OPMAP[ DDX ] = new OpCode( DDX, 2, 0x1a, OP_VERSION2 | OP_FRAG_ONLY );
			OPMAP[ DDY ] = new OpCode( DDY, 2, 0x1b, OP_VERSION2 | OP_FRAG_ONLY );			
			OPMAP[ IFE ] = new OpCode( IFE, 2, 0x1c, OP_NO_DEST | OP_VERSION2 | OP_INCNEST | OP_SCALAR );
			OPMAP[ INE ] = new OpCode( INE, 2, 0x1d, OP_NO_DEST | OP_VERSION2 | OP_INCNEST | OP_SCALAR );
			OPMAP[ IFG ] = new OpCode( IFG, 2, 0x1e, OP_NO_DEST | OP_VERSION2 | OP_INCNEST | OP_SCALAR );			
			OPMAP[ IFL ] = new OpCode( IFL, 2, 0x1f, OP_NO_DEST | OP_VERSION2 | OP_INCNEST | OP_SCALAR );
			OPMAP[ ELS ] = new OpCode( ELS, 0, 0x20, OP_NO_DEST | OP_VERSION2 | OP_INCNEST | OP_DECNEST | OP_SCALAR );
			OPMAP[ EIF ] = new OpCode( EIF, 0, 0x21, OP_NO_DEST | OP_VERSION2 | OP_DECNEST | OP_SCALAR );
			// space			
			//OPMAP[ TED ] = new OpCode( TED, 3, 0x26, OP_FRAG_ONLY | OP_SPECIAL_TEX | OP_VERSION2);	//ted is not available in AGAL2		
			OPMAP[ KIL ] = new OpCode( KIL, 1, 0x27, OP_NO_DEST | OP_FRAG_ONLY );
			OPMAP[ TEX ] = new OpCode( TEX, 3, 0x28, OP_FRAG_ONLY | OP_SPECIAL_TEX );
			OPMAP[ SGE ] = new OpCode( SGE, 3, 0x29, 0 );
			OPMAP[ SLT ] = new OpCode( SLT, 3, 0x2a, 0 );
			OPMAP[ SGN ] = new OpCode( SGN, 2, 0x2b, 0 );
			OPMAP[ SEQ ] = new OpCode( SEQ, 3, 0x2c, 0 );
			OPMAP[ SNE ] = new OpCode( SNE, 3, 0x2d, 0 );			
		
			
			SAMPLEMAP[ RGBA ]		= new Sampler( RGBA,		SAMPLER_TYPE_SHIFT,			0 );
			SAMPLEMAP[ DXT1 ]		= new Sampler( DXT1,		SAMPLER_TYPE_SHIFT,			1 );
			SAMPLEMAP[ DXT5 ]		= new Sampler( DXT5,		SAMPLER_TYPE_SHIFT,			2 );
			SAMPLEMAP[ VIDEO ]		= new Sampler( VIDEO,		SAMPLER_TYPE_SHIFT,			3 );
			SAMPLEMAP[ D2 ]			= new Sampler( D2,			SAMPLER_DIM_SHIFT,			0 );
			SAMPLEMAP[ D3 ]			= new Sampler( D3,			SAMPLER_DIM_SHIFT,			2 );
			SAMPLEMAP[ CUBE ]		= new Sampler( CUBE,		SAMPLER_DIM_SHIFT,			1 );
			SAMPLEMAP[ MIPNEAREST ]	= new Sampler( MIPNEAREST,	SAMPLER_MIPMAP_SHIFT,		1 );
			SAMPLEMAP[ MIPLINEAR ]	= new Sampler( MIPLINEAR,	SAMPLER_MIPMAP_SHIFT,		2 );
			SAMPLEMAP[ MIPNONE ]	= new Sampler( MIPNONE,		SAMPLER_MIPMAP_SHIFT,		0 );
			SAMPLEMAP[ NOMIP ]		= new Sampler( NOMIP,		SAMPLER_MIPMAP_SHIFT,		0 );
			SAMPLEMAP[ NEAREST ]	= new Sampler( NEAREST,		SAMPLER_FILTER_SHIFT,		0 );
			SAMPLEMAP[ LINEAR ]		= new Sampler( LINEAR,		SAMPLER_FILTER_SHIFT,		1 );
			SAMPLEMAP[ ANISOTROPIC2X ]	= new Sampler( ANISOTROPIC2X, SAMPLER_FILTER_SHIFT, 2 );
			SAMPLEMAP[ ANISOTROPIC4X ]	= new Sampler( ANISOTROPIC4X, SAMPLER_FILTER_SHIFT,	3 );
			SAMPLEMAP[ ANISOTROPIC8X ]	= new Sampler( ANISOTROPIC8X, SAMPLER_FILTER_SHIFT,	4 );
			SAMPLEMAP[ ANISOTROPIC16X ]	= new Sampler( ANISOTROPIC16X, SAMPLER_FILTER_SHIFT,5 );
			SAMPLEMAP[ CENTROID ]	= new Sampler( CENTROID,	SAMPLER_SPECIAL_SHIFT,		1 << 0 );
			SAMPLEMAP[ SINGLE ]		= new Sampler( SINGLE,		SAMPLER_SPECIAL_SHIFT,		1 << 1 );
			SAMPLEMAP[ IGNORESAMPLER ]	= new Sampler( IGNORESAMPLER,		SAMPLER_SPECIAL_SHIFT,		1 << 2 );
			SAMPLEMAP[ REPEAT ]		= new Sampler( REPEAT,		SAMPLER_REPEAT_SHIFT,		1 );
			SAMPLEMAP[ WRAP ]		= new Sampler( WRAP,		SAMPLER_REPEAT_SHIFT,		1 );
			SAMPLEMAP[ CLAMP ]		= new Sampler( CLAMP,		SAMPLER_REPEAT_SHIFT,		0 );
			SAMPLEMAP[ CLAMP_U_REPEAT_V ]	= new Sampler( CLAMP_U_REPEAT_V, SAMPLER_REPEAT_SHIFT, 2 );
			SAMPLEMAP[ REPEAT_U_CLAMP_V ]	= new Sampler( REPEAT_U_CLAMP_V, SAMPLER_REPEAT_SHIFT, 3 );
		}
		
		// ======================================================================
		//	Constants
		// ----------------------------------------------------------------------
		private static const OPMAP:Dictionary					= new Dictionary();
		private static const REGMAP1:Dictionary					= new Dictionary();
		private static const REGMAP2:Dictionary					= new Dictionary();
		private static const SAMPLEMAP:Dictionary				= new Dictionary();
		
		private static const MAX_NESTING:int					= 4;
		private static const MAX_OPCODES:int					= 2048;
		
		private static const FRAGMENT:String					= "fragment";
		private static const VERTEX:String						= "vertex";
		
		// masks and shifts
		private static const SAMPLER_TYPE_SHIFT:uint			= 8;
		private static const SAMPLER_DIM_SHIFT:uint				= 12;
		private static const SAMPLER_SPECIAL_SHIFT:uint			= 16;
		private static const SAMPLER_REPEAT_SHIFT:uint			= 20;
		private static const SAMPLER_MIPMAP_SHIFT:uint			= 24;
		private static const SAMPLER_FILTER_SHIFT:uint			= 28;
		
		// regmap flags
		private static const REG_WRITE:uint						= 0x1;
		private static const REG_READ:uint						= 0x2;
		private static const REG_FRAG:uint						= 0x20;
		private static const REG_VERT:uint						= 0x40;
		
		// opmap flags
		private static const OP_SCALAR:uint						= 0x1;
		private static const OP_SPECIAL_TEX:uint				= 0x8;
		private static const OP_SPECIAL_MATRIX:uint				= 0x10;
		private static const OP_FRAG_ONLY:uint					= 0x20;
		private static const OP_VERT_ONLY:uint					= 0x40;
		private static const OP_NO_DEST:uint					= 0x80;
		private static const OP_VERSION2:uint 					= 0x100;		
		private static const OP_INCNEST:uint 					= 0x200;
		private static const OP_DECNEST:uint					= 0x400;
		
		// opcodes
		private static const MOV:String							= "mov";
		private static const ADD:String							= "add";
		private static const SUB:String							= "sub";
		private static const MUL:String							= "mul";
		private static const DIV:String							= "div";
		private static const RCP:String							= "rcp";
		private static const MIN:String							= "min";
		private static const MAX:String							= "max";
		private static const FRC:String							= "frc";
		private static const SQT:String							= "sqt";
		private static const RSQ:String							= "rsq";
		private static const POW:String							= "pow";
		private static const LOG:String							= "log";
		private static const EXP:String							= "exp";
		private static const NRM:String							= "nrm";
		private static const SIN:String							= "sin";
		private static const COS:String							= "cos";
		private static const CRS:String							= "crs";
		private static const DP3:String							= "dp3";
		private static const DP4:String							= "dp4";
		private static const ABS:String							= "abs";
		private static const NEG:String							= "neg";
		private static const SAT:String							= "sat";
		private static const M33:String							= "m33";
		private static const M44:String							= "m44";
		private static const M34:String							= "m34";
		private static const DDX:String							= "ddx";
		private static const DDY:String							= "ddy";		
		private static const IFE:String							= "ife";
		private static const INE:String							= "ine";
		private static const IFG:String							= "ifg";
		private static const IFL:String							= "ifl";
		private static const ELS:String							= "els";
		private static const EIF:String							= "eif";
		private static const TED:String							= "ted";
		private static const KIL:String							= "kil";
		private static const TEX:String							= "tex";
		private static const SGE:String							= "sge";
		private static const SLT:String							= "slt";
		private static const SGN:String							= "sgn";
		private static const SEQ:String							= "seq";
		private static const SNE:String							= "sne";		
		
		// registers
		private static const VA:String							= "va";
		private static const VC:String							= "vc";
		private static const VT:String							= "vt";
		private static const VO:String							= "vo";
		private static const VI:String							= "vi";
		private static const FC:String							= "fc";
		private static const FT:String							= "ft";
		private static const FS:String							= "fs";
		private static const FO:String							= "fo";			
		private static const FD:String							= "fd"; 
		
		// samplers
		private static const D2:String							= "2d";
		private static const D3:String							= "3d";
		private static const CUBE:String						= "cube";
		private static const MIPNEAREST:String					= "mipnearest";
		private static const MIPLINEAR:String					= "miplinear";
		private static const MIPNONE:String						= "mipnone";
		private static const NOMIP:String						= "nomip";
		private static const NEAREST:String						= "nearest";
		private static const LINEAR:String						= "linear";
		private static const ANISOTROPIC2X:String				= "anisotropic2x"; //Introduced by Flash 14
		private static const ANISOTROPIC4X:String				= "anisotropic4x"; //Introduced by Flash 14
		private static const ANISOTROPIC8X:String				= "anisotropic8x"; //Introduced by Flash 14
		private static const ANISOTROPIC16X:String				= "anisotropic16x"; //Introduced by Flash 14
		private static const CENTROID:String					= "centroid";
		private static const SINGLE:String						= "single";
		private static const IGNORESAMPLER:String				= "ignoresampler";
		private static const REPEAT:String						= "repeat";
		private static const WRAP:String						= "wrap";
		private static const CLAMP:String						= "clamp";
		private static const REPEAT_U_CLAMP_V:String			= "repeat_u_clamp_v"; //Introduced by Flash 13
		private static const CLAMP_U_REPEAT_V:String			= "clamp_u_repeat_v"; //Introduced by Flash 13
		private static const RGBA:String						= "rgba";
		private static const DXT1:String						= "dxt1";
		private static const DXT5:String						= "dxt5";
		private static const VIDEO:String						= "video";
	}
}

// ================================================================================
//	Helper Classes
// --------------------------------------------------------------------------------
{
	// ===========================================================================
	//	Class
	// ---------------------------------------------------------------------------
	class OpCode
	{		
		// ======================================================================
		//	Properties
		// ----------------------------------------------------------------------
		private var _emitCode:uint;
		private var _flags:uint;
		private var _name:String;
		private var _numRegister:uint;
		
		// ======================================================================
		//	Getters
		// ----------------------------------------------------------------------
		public function get emitCode():uint		{ return _emitCode; }
		public function get flags():uint		{ return _flags; }
		public function get name():String		{ return _name; }
		public function get numRegister():uint	{ return _numRegister; }
		
		// ======================================================================
		//	Constructor
		// ----------------------------------------------------------------------
		public function OpCode( name:String, numRegister:uint, emitCode:uint, flags:uint)
		{
			_name = name;
			_numRegister = numRegister;
			_emitCode = emitCode;
			_flags = flags;
		}		
		
		// ======================================================================
		//	Methods
		// ----------------------------------------------------------------------
		public function toString():String
		{
			return "[OpCode name=\""+_name+"\", numRegister="+_numRegister+", emitCode="+_emitCode+", flags="+_flags+"]";
		}
	}
	
	// ===========================================================================
	//	Class
	// ---------------------------------------------------------------------------
	class Register
	{
		// ======================================================================
		//	Properties
		// ----------------------------------------------------------------------
		private var _emitCode:uint;
		private var _name:String;
		private var _longName:String;
		private var _flags:uint;
		private var _range:uint;
		
		// ======================================================================
		//	Getters
		// ----------------------------------------------------------------------
		public function get emitCode():uint		{ return _emitCode; }
		public function get longName():String	{ return _longName; }
		public function get name():String		{ return _name; }
		public function get flags():uint		{ return _flags; }
		public function get range():uint		{ return _range; }
		
		// ======================================================================
		//	Constructor
		// ----------------------------------------------------------------------
		public function Register( name:String, longName:String, emitCode:uint, range:uint, flags:uint)
		{
			_name = name;
			_longName = longName;
			_emitCode = emitCode;
			_range = range;
			_flags = flags;
		}
		
		// ======================================================================
		//	Methods
		// ----------------------------------------------------------------------
		public function toString():String
		{
			return "[Register name=\""+_name+"\", longName=\""+_longName+"\", emitCode="+_emitCode+", range="+_range+", flags="+ _flags+"]";
		}
	}
	
	// ===========================================================================
	//	Class
	// ---------------------------------------------------------------------------
	class Sampler
	{
		// ======================================================================
		//	Properties
		// ----------------------------------------------------------------------
		private var _flag:uint;
		private var _mask:uint;
		private var _name:String;
		
		// ======================================================================
		//	Getters
		// ----------------------------------------------------------------------
		public function get flag():uint		{ return _flag; }
		public function get mask():uint		{ return _mask; }
		public function get name():String	{ return _name; }
		
		// ======================================================================
		//	Constructor
		// ----------------------------------------------------------------------
		public function Sampler( name:String, flag:uint, mask:uint )
		{
			_name = name;
			_flag = flag;
			_mask = mask;
		}
		
		// ======================================================================
		//	Methods
		// ----------------------------------------------------------------------
		public function toString():String
		{
			return "[Sampler name=\""+_name+"\", flag=\""+_flag+"\", mask="+mask+"]";
		}
	}
}