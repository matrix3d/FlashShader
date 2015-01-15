package as3Shader;

import flash.display3D.Context3DProgramType;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import flash.utils.Endian;

/**

 * ...

 * @author lizhi

 */class AGALByteCreator extends Creator {

	static var initialized : Bool = false;
	public var verbose : Bool;
	public var version : UInt;
	public var _error : String;
	public function new(version : UInt = 1) {
		super();
		verbose = false;
		this.version = version;
	}

	override public function creat(shader : AS3Shader) : Void {
		if(!initialized)  {
			init();
			initregmap(1, false);
			initregmap(2, false);
		}
		var REGMAP : Dictionary = version == (1) ? REGMAP1 : REGMAP2;
		var isFrag : Bool = shader.programType == Context3DProgramType.FRAGMENT;
		var programTypeName : String;
		if(shader.programType == Context3DProgramType.VERTEX)  {
			programTypeName = "v";
		}

		else  {
			programTypeName = "f";
		}

		var agalcode : ByteArray = new ByteArray();
		data = agalcode;
		agalcode.endian = Endian.LITTLE_ENDIAN;
		agalcode.writeByte(0xa0);
		// tag version
		agalcode.writeUnsignedInt(version);
		// AGAL version, big endian, bit pattern will be 0x01000000
		agalcode.writeByte(0xa1);
		// tag program id
		agalcode.writeByte((isFrag) ? 1 : 0);
		// vertex or fragment
		var lines : Array<Dynamic> = shader.lines;
		var nops : Int = 0;
		var i : Int = 0;
		while(i < lines.length) {
			var line : Array<Dynamic> = lines[i];
			var opName : String = line[0];
			var opFound : OpCode = OPMAP[opName];
			var opts : Array<Dynamic> = line.flag;
			if(opFound == null)  {
				if(line.length >= 3) 
					trace("warning: bad line " + i + ": " + lines[i]);
				 {
					i++;
					continue;
				}

			}
			if((opFound.flags & OP_VERSION2) && version < 2)  {
				_error = "error: opcode requires version 2.";
				break;
			}
			if((opFound.flags & OP_VERT_ONLY) && isFrag)  {
				_error = "error: opcode is only allowed in vertex programs.";
				break;
			}
			if((opFound.flags & OP_FRAG_ONLY) && !isFrag)  {
				_error = "error: opcode is only allowed in fragment programs.";
				break;
			}
			if(verbose) 
				trace("emit opcode=" + opFound);
			agalcode.writeUnsignedInt(opFound.emitCode);
			nops++;
			if(nops > MAX_OPCODES)  {
				_error = "error: too many opcodes. maximum is " + MAX_OPCODES + ".";
				break;
			}
			var badreg : Bool = false;
			var pad : UInt = 160;
			//64 + 64 + 32;
			var regLength : UInt = line.length - 1;
			var j : Int = 0;
			while(j < regLength) {
				var v : Var = line[j + 1];
				var regidx : UInt = v.index;
				var isRelative : Bool = Std.is(v.component, Var);
				if(verbose && isRelative) 
					trace("IS REL");
				var regFound : Register = REGMAP[programTypeName + v.type];
				if(regFound == null)  {
					_error = "error: could not find register name for operand " + j + " (" + v.type + ").";
					badreg = true;
					break;
				}
				if(isFrag)  {
					if(!(regFound.flags & REG_FRAG))  {
						_error = "error: register operand " + j + " (" + v.type + ") only allowed in vertex programs.";
						badreg = true;
						break;
					}
					if(isRelative)  {
						_error = "error: register operand " + j + " (" + v.type + ") relative adressing not allowed in fragment programs.";
						badreg = true;
						break;
					}
				}

				else  {
					if(!(regFound.flags & REG_VERT))  {
						_error = "error: register operand " + j + " (" + v.type + ") only allowed in fragment programs.";
						badreg = true;
						break;
					}
				}

				if(regFound.range < regidx)  {
					_error = "error: register operand " + j + " (" + v.type + ") index exceeds limit of " + (regFound.range + 1) + ".";
					badreg = true;
					break;
				}
				var regmask : UInt = 0;
				var maskmatch : String = null;
				if(Std.is(v.component, String)) 
					maskmatch = try cast(v.component, String) catch(e:Dynamic) null;
				var isDest : Bool = (j == 0 && !(opFound.flags & OP_NO_DEST));
				var isSampler : Bool = (j == 2 && (opFound.flags & OP_SPECIAL_TEX));
				var reltype : UInt = 0;
				var relsel : UInt = 0;
				var reloffset : Int = 0;
				if(isDest && isRelative)  {
					_error = "error: relative can not be destination";
					badreg = true;
					break;
				}
				if(maskmatch != null)  {
					regmask = 0;
					var cv : UInt;
					var maskLength : UInt = maskmatch.length;
					var k : Int = 1;
					while(k <= maskLength) {
						cv = maskmatch.charCodeAt(k - 1) - "x".charCodeAt(0);
						if(cv > 2) 
							cv = 3;
						if(isDest) 
							regmask |= 1 << cv
						else regmask |= cv << ((k - 1) << 1);
						k++;
					}
					if(!isDest) 
											while(k <= 4) {
						regmask |= cv << ((k - 1) << 1);
						k++;
					}
;
				}

				else  {
					regmask = (isDest) ? 0xf : 0xe4;
				}

				if(isRelative)  {
					var relv : Var = try cast(v.component, Var) catch(e:Dynamic) null;
					regidx = relv.index;
					var regFoundRel : Register = REGMAP[programTypeName + relv.type];
					if(regFoundRel == null)  {
						_error = "error: bad index register";
						badreg = true;
						break;
					}
					reltype = regFoundRel.emitCode;
					relsel = (try cast(relv.component, String) catch(e:Dynamic) null).charCodeAt(0) - "x".charCodeAt(0);
					if(relsel > 2) 
						relsel = 3;
					reloffset = relv.offset;
					if(reloffset < 0 || reloffset > 255)  {
						_error = "error: index offset " + reloffset + " out of bounds. [0..255]";
						badreg = true;
						break;
					}
					if(verbose) 
						trace("RELATIVE: type=" + reltype + "==" + " sel=" + relsel + "==" + " idx=" + regidx + " offset=" + reloffset);
				}
				if(verbose) 
					trace("  emit argcode=" + regFound + "[" + regidx + "][" + regmask + "]");
				if(isDest)  {
					agalcode.writeShort(regidx);
					agalcode.writeByte(regmask);
					agalcode.writeByte(regFound.emitCode);
					pad -= 32;
				}

				else  {
					if(isSampler)  {
						if(verbose) 
							trace("  emit sampler");
						var samplerbits : UInt = 5;
						// type 5
						var optsLength : UInt = opts == (null) ? 0 : opts.length;
						var bias : Float = 0;
						k = 0;
						while(k < optsLength) {
							if(verbose) 
								trace("    opt: " + opts[k]);
							var optfound : Sampler = SAMPLEMAP[opts[k]];
							if(optfound == null)  {
								// todo check that it's a number...
								//trace( "Warning, unknown sampler option: "+opts[k] );
								bias = as3hx.Compat.parseFloat(opts[k]);
								if(verbose) 
									trace("    bias: " + bias);
							}

							else  {
								if(optfound.flag != SAMPLER_SPECIAL_SHIFT) 
									samplerbits &= ~(0xf << optfound.flag);
								samplerbits |= uint(optfound.mask) << uint(optfound.flag);
							}

							k++;
						}
						agalcode.writeShort(regidx);
						agalcode.writeByte(as3hx.Compat.parseInt(bias * 8.0));
						agalcode.writeByte(0);
						agalcode.writeUnsignedInt(samplerbits);
						if(verbose) 
							trace("    bits: " + (samplerbits - 5));
						pad -= 64;
					}

					else  {
						if(j == 0)  {
							agalcode.writeUnsignedInt(0);
							pad -= 32;
						}
						agalcode.writeShort(regidx);
						agalcode.writeByte(reloffset);
						agalcode.writeByte(regmask);
						agalcode.writeByte(regFound.emitCode);
						agalcode.writeByte(reltype);
						agalcode.writeShort((isRelative) ? (relsel | (1 << 15)) : 0);
						pad -= 64;
					}

				}

				j++;
			}
			// pad unused regs
			j = 0;
			while(j < pad) {
				agalcode.writeByte(0);
				j += 8;
			}
;
			if(badreg) 
				break;
			i++;
		}
	}

	static function initregmap(version : UInt, ignorelimits : Bool) : Void {
		// version changes limits
		var REGMAP : Dictionary = version == (1) ? REGMAP1 : REGMAP2;
		REGMAP["v" + Var.TYPE_VA] = new Register(VA, "vertex attribute", 0x0, (ignorelimits) ? 1024 : 7, REG_VERT | REG_READ);
		REGMAP["v" + Var.TYPE_C] = new Register(VC, "vertex constant", 0x1, (ignorelimits) ? 1024 : (version == (1) ? 127 : 249), REG_VERT | REG_READ);
		REGMAP["v" + Var.TYPE_T] = new Register(VT, "vertex temporary", 0x2, (ignorelimits) ? 1024 : (version == (1) ? 7 : 25), REG_VERT | REG_WRITE | REG_READ);
		REGMAP["v" + Var.TYPE_OP] = new Register(VO, "vertex output", 0x3, (ignorelimits) ? 1024 : 0, REG_VERT | REG_WRITE);
		REGMAP["v" + Var.TYPE_V] = REGMAP["f" + Var.TYPE_V] = new Register(VI, "varying", 0x4, (ignorelimits) ? 1024 : (version == (1) ? 7 : 9), REG_VERT | REG_FRAG | REG_READ | REG_WRITE);
		REGMAP["f" + Var.TYPE_C] = new Register(FC, "fragment constant", 0x1, (ignorelimits) ? 1024 : (version == (1) ? 27 : 63), REG_FRAG | REG_READ);
		REGMAP["f" + Var.TYPE_T] = new Register(FT, "fragment temporary", 0x2, (ignorelimits) ? 1024 : (version == (1) ? 7 : 25), REG_FRAG | REG_WRITE | REG_READ);
		REGMAP["f" + Var.TYPE_FS] = new Register(FS, "texture sampler", 0x5, (ignorelimits) ? 1024 : 7, REG_FRAG | REG_READ);
		REGMAP["f" + Var.TYPE_OC] = new Register(FO, "fragment output", 0x3, (ignorelimits) ? 1024 : (version == (1) ? 0 : 3), REG_FRAG | REG_WRITE);
	}

	static function init() : Void {
		initialized = true;
		// Fill the dictionaries with opcodes and registers
		OPMAP[MOV] = new OpCode(MOV, 2, 0x00, 0);
		OPMAP[ADD] = new OpCode(ADD, 3, 0x01, 0);
		OPMAP[SUB] = new OpCode(SUB, 3, 0x02, 0);
		OPMAP[MUL] = new OpCode(MUL, 3, 0x03, 0);
		OPMAP[DIV] = new OpCode(DIV, 3, 0x04, 0);
		OPMAP[RCP] = new OpCode(RCP, 2, 0x05, 0);
		OPMAP[MIN] = new OpCode(MIN, 3, 0x06, 0);
		OPMAP[MAX] = new OpCode(MAX, 3, 0x07, 0);
		OPMAP[FRC] = new OpCode(FRC, 2, 0x08, 0);
		OPMAP[SQT] = new OpCode(SQT, 2, 0x09, 0);
		OPMAP[RSQ] = new OpCode(RSQ, 2, 0x0a, 0);
		OPMAP[POW] = new OpCode(POW, 3, 0x0b, 0);
		OPMAP[LOG] = new OpCode(LOG, 2, 0x0c, 0);
		OPMAP[EXP] = new OpCode(EXP, 2, 0x0d, 0);
		OPMAP[NRM] = new OpCode(NRM, 2, 0x0e, 0);
		OPMAP[SIN] = new OpCode(SIN, 2, 0x0f, 0);
		OPMAP[COS] = new OpCode(COS, 2, 0x10, 0);
		OPMAP[CRS] = new OpCode(CRS, 3, 0x11, 0);
		OPMAP[DP3] = new OpCode(DP3, 3, 0x12, 0);
		OPMAP[DP4] = new OpCode(DP4, 3, 0x13, 0);
		OPMAP[ABS] = new OpCode(ABS, 2, 0x14, 0);
		OPMAP[NEG] = new OpCode(NEG, 2, 0x15, 0);
		OPMAP[SAT] = new OpCode(SAT, 2, 0x16, 0);
		OPMAP[M33] = new OpCode(M33, 3, 0x17, OP_SPECIAL_MATRIX);
		OPMAP[M44] = new OpCode(M44, 3, 0x18, OP_SPECIAL_MATRIX);
		OPMAP[M34] = new OpCode(M34, 3, 0x19, OP_SPECIAL_MATRIX);
		OPMAP[DDX] = new OpCode(DDX, 2, 0x1a, OP_VERSION2 | OP_FRAG_ONLY);
		OPMAP[DDY] = new OpCode(DDY, 2, 0x1b, OP_VERSION2 | OP_FRAG_ONLY);
		OPMAP[IFE] = new OpCode(IFE, 2, 0x1c, OP_NO_DEST | OP_VERSION2 | OP_INCNEST | OP_SCALAR);
		OPMAP[INE] = new OpCode(INE, 2, 0x1d, OP_NO_DEST | OP_VERSION2 | OP_INCNEST | OP_SCALAR);
		OPMAP[IFG] = new OpCode(IFG, 2, 0x1e, OP_NO_DEST | OP_VERSION2 | OP_INCNEST | OP_SCALAR);
		OPMAP[IFL] = new OpCode(IFL, 2, 0x1f, OP_NO_DEST | OP_VERSION2 | OP_INCNEST | OP_SCALAR);
		OPMAP[ELS] = new OpCode(ELS, 0, 0x20, OP_NO_DEST | OP_VERSION2 | OP_INCNEST | OP_DECNEST | OP_SCALAR);
		OPMAP[EIF] = new OpCode(EIF, 0, 0x21, OP_NO_DEST | OP_VERSION2 | OP_DECNEST | OP_SCALAR);
		// space
		//OPMAP[ TED ] = new OpCode( TED, 3, 0x26, OP_FRAG_ONLY | OP_SPECIAL_TEX | OP_VERSION2);	//ted is not available in AGAL2
		OPMAP[KIL] = new OpCode(KIL, 1, 0x27, OP_NO_DEST | OP_FRAG_ONLY);
		OPMAP[TEX] = new OpCode(TEX, 3, 0x28, OP_FRAG_ONLY | OP_SPECIAL_TEX);
		OPMAP[SGE] = new OpCode(SGE, 3, 0x29, 0);
		OPMAP[SLT] = new OpCode(SLT, 3, 0x2a, 0);
		OPMAP[SGN] = new OpCode(SGN, 2, 0x2b, 0);
		OPMAP[SEQ] = new OpCode(SEQ, 3, 0x2c, 0);
		OPMAP[SNE] = new OpCode(SNE, 3, 0x2d, 0);
		SAMPLEMAP[RGBA] = new Sampler(RGBA, SAMPLER_TYPE_SHIFT, 0);
		SAMPLEMAP[DXT1] = new Sampler(DXT1, SAMPLER_TYPE_SHIFT, 1);
		SAMPLEMAP[DXT5] = new Sampler(DXT5, SAMPLER_TYPE_SHIFT, 2);
		SAMPLEMAP[VIDEO] = new Sampler(VIDEO, SAMPLER_TYPE_SHIFT, 3);
		SAMPLEMAP[D2] = new Sampler(D2, SAMPLER_DIM_SHIFT, 0);
		SAMPLEMAP[D3] = new Sampler(D3, SAMPLER_DIM_SHIFT, 2);
		SAMPLEMAP[CUBE] = new Sampler(CUBE, SAMPLER_DIM_SHIFT, 1);
		SAMPLEMAP[MIPNEAREST] = new Sampler(MIPNEAREST, SAMPLER_MIPMAP_SHIFT, 1);
		SAMPLEMAP[MIPLINEAR] = new Sampler(MIPLINEAR, SAMPLER_MIPMAP_SHIFT, 2);
		SAMPLEMAP[MIPNONE] = new Sampler(MIPNONE, SAMPLER_MIPMAP_SHIFT, 0);
		SAMPLEMAP[NOMIP] = new Sampler(NOMIP, SAMPLER_MIPMAP_SHIFT, 0);
		SAMPLEMAP[NEAREST] = new Sampler(NEAREST, SAMPLER_FILTER_SHIFT, 0);
		SAMPLEMAP[LINEAR] = new Sampler(LINEAR, SAMPLER_FILTER_SHIFT, 1);
		SAMPLEMAP[ANISOTROPIC2X] = new Sampler(ANISOTROPIC2X, SAMPLER_FILTER_SHIFT, 2);
		SAMPLEMAP[ANISOTROPIC4X] = new Sampler(ANISOTROPIC4X, SAMPLER_FILTER_SHIFT, 3);
		SAMPLEMAP[ANISOTROPIC8X] = new Sampler(ANISOTROPIC8X, SAMPLER_FILTER_SHIFT, 4);
		SAMPLEMAP[ANISOTROPIC16X] = new Sampler(ANISOTROPIC16X, SAMPLER_FILTER_SHIFT, 5);
		SAMPLEMAP[CENTROID] = new Sampler(CENTROID, SAMPLER_SPECIAL_SHIFT, 1 << 0);
		SAMPLEMAP[SINGLE] = new Sampler(SINGLE, SAMPLER_SPECIAL_SHIFT, 1 << 1);
		SAMPLEMAP[IGNORESAMPLER] = new Sampler(IGNORESAMPLER, SAMPLER_SPECIAL_SHIFT, 1 << 2);
		SAMPLEMAP[REPEAT] = new Sampler(REPEAT, SAMPLER_REPEAT_SHIFT, 1);
		SAMPLEMAP[WRAP] = new Sampler(WRAP, SAMPLER_REPEAT_SHIFT, 1);
		SAMPLEMAP[CLAMP] = new Sampler(CLAMP, SAMPLER_REPEAT_SHIFT, 0);
		SAMPLEMAP[CLAMP_U_REPEAT_V] = new Sampler(CLAMP_U_REPEAT_V, SAMPLER_REPEAT_SHIFT, 2);
		SAMPLEMAP[REPEAT_U_CLAMP_V] = new Sampler(REPEAT_U_CLAMP_V, SAMPLER_REPEAT_SHIFT, 3);
	}

	// ======================================================================
		//	Constants
		// ----------------------------------------------------------------------
		static inline var OPMAP : Dictionary = new Dictionary();
	static inline var REGMAP1 : Dictionary = new Dictionary();
	static inline var REGMAP2 : Dictionary = new Dictionary();
	static inline var SAMPLEMAP : Dictionary = new Dictionary();
	static inline var MAX_NESTING : Int = 4;
	static inline var MAX_OPCODES : Int = 2048;
	static inline var FRAGMENT : String = "fragment";
	static inline var VERTEX : String = "vertex";
	// masks and shifts
		static inline var SAMPLER_TYPE_SHIFT : UInt = 8;
	static inline var SAMPLER_DIM_SHIFT : UInt = 12;
	static inline var SAMPLER_SPECIAL_SHIFT : UInt = 16;
	static inline var SAMPLER_REPEAT_SHIFT : UInt = 20;
	static inline var SAMPLER_MIPMAP_SHIFT : UInt = 24;
	static inline var SAMPLER_FILTER_SHIFT : UInt = 28;
	// regmap flags
		static inline var REG_WRITE : UInt = 0x1;
	static inline var REG_READ : UInt = 0x2;
	static inline var REG_FRAG : UInt = 0x20;
	static inline var REG_VERT : UInt = 0x40;
	// opmap flags
		static inline var OP_SCALAR : UInt = 0x1;
	static inline var OP_SPECIAL_TEX : UInt = 0x8;
	static inline var OP_SPECIAL_MATRIX : UInt = 0x10;
	static inline var OP_FRAG_ONLY : UInt = 0x20;
	static inline var OP_VERT_ONLY : UInt = 0x40;
	static inline var OP_NO_DEST : UInt = 0x80;
	static inline var OP_VERSION2 : UInt = 0x100;
	static inline var OP_INCNEST : UInt = 0x200;
	static inline var OP_DECNEST : UInt = 0x400;
	// opcodes
		static inline var MOV : String = "mov";
	static inline var ADD : String = "add";
	static inline var SUB : String = "sub";
	static inline var MUL : String = "mul";
	static inline var DIV : String = "div";
	static inline var RCP : String = "rcp";
	static inline var MIN : String = "min";
	static inline var MAX : String = "max";
	static inline var FRC : String = "frc";
	static inline var SQT : String = "sqt";
	static inline var RSQ : String = "rsq";
	static inline var POW : String = "pow";
	static inline var LOG : String = "log";
	static inline var EXP : String = "exp";
	static inline var NRM : String = "nrm";
	static inline var SIN : String = "sin";
	static inline var COS : String = "cos";
	static inline var CRS : String = "crs";
	static inline var DP3 : String = "dp3";
	static inline var DP4 : String = "dp4";
	static inline var ABS : String = "abs";
	static inline var NEG : String = "neg";
	static inline var SAT : String = "sat";
	static inline var M33 : String = "m33";
	static inline var M44 : String = "m44";
	static inline var M34 : String = "m34";
	static inline var DDX : String = "ddx";
	static inline var DDY : String = "ddy";
	static inline var IFE : String = "ife";
	static inline var INE : String = "ine";
	static inline var IFG : String = "ifg";
	static inline var IFL : String = "ifl";
	static inline var ELS : String = "els";
	static inline var EIF : String = "eif";
	static inline var TED : String = "ted";
	static inline var KIL : String = "kil";
	static inline var TEX : String = "tex";
	static inline var SGE : String = "sge";
	static inline var SLT : String = "slt";
	static inline var SGN : String = "sgn";
	static inline var SEQ : String = "seq";
	static inline var SNE : String = "sne";
	// registers
		static inline var VA : String = "va";
	static inline var VC : String = "vc";
	static inline var VT : String = "vt";
	static inline var VO : String = "vo";
	static inline var VI : String = "vi";
	static inline var FC : String = "fc";
	static inline var FT : String = "ft";
	static inline var FS : String = "fs";
	static inline var FO : String = "fo";
	static inline var FD : String = "fd";
	// samplers
		static inline var D2 : String = "2d";
	static inline var D3 : String = "3d";
	static inline var CUBE : String = "cube";
	static inline var MIPNEAREST : String = "mipnearest";
	static inline var MIPLINEAR : String = "miplinear";
	static inline var MIPNONE : String = "mipnone";
	static inline var NOMIP : String = "nomip";
	static inline var NEAREST : String = "nearest";
	static inline var LINEAR : String = "linear";
	static inline var ANISOTROPIC2X : String = "anisotropic2x";
	//Introduced by Flash 14
		static inline var ANISOTROPIC4X : String = "anisotropic4x";
	//Introduced by Flash 14
		static inline var ANISOTROPIC8X : String = "anisotropic8x";
	//Introduced by Flash 14
		static inline var ANISOTROPIC16X : String = "anisotropic16x";
	//Introduced by Flash 14
		static inline var CENTROID : String = "centroid";
	static inline var SINGLE : String = "single";
	static inline var IGNORESAMPLER : String = "ignoresampler";
	static inline var REPEAT : String = "repeat";
	static inline var WRAP : String = "wrap";
	static inline var CLAMP : String = "clamp";
	static inline var REPEAT_U_CLAMP_V : String = "repeat_u_clamp_v";
	//Introduced by Flash 13
		static inline var CLAMP_U_REPEAT_V : String = "clamp_u_repeat_v";
	//Introduced by Flash 13
		static inline var RGBA : String = "rgba";
	static inline var DXT1 : String = "dxt1";
	static inline var DXT5 : String = "dxt5";
	static inline var VIDEO : String = "video";
}

// ================================================================================
//	Helper Classes
// --------------------------------------------------------------------------------
// ===========================================================================
//	Class
// ---------------------------------------------------------------------------
class OpCode {
	public var emitCode(getEmitCode, never) : UInt;
	public var flags(getFlags, never) : UInt;
	public var name(getName, never) : String;
	public var numRegister(getNumRegister, never) : UInt;

	// ======================================================================
		//	Properties
		// ----------------------------------------------------------------------
		var _emitCode : UInt;
	var _flags : UInt;
	var _name : String;
	var _numRegister : UInt;
	// ======================================================================
		//	Getters
		// ----------------------------------------------------------------------
		public function getEmitCode() : UInt {
		return _emitCode;
	}

	public function getFlags() : UInt {
		return _flags;
	}

	public function getName() : String {
		return _name;
	}

	public function getNumRegister() : UInt {
		return _numRegister;
	}

	// ======================================================================
		//	Constructor
		// ----------------------------------------------------------------------
		public function new(name : String, numRegister : UInt, emitCode : UInt, flags : UInt) {
		_name = name;
		_numRegister = numRegister;
		_emitCode = emitCode;
		_flags = flags;
	}

	// ======================================================================
		//	Methods
		// ----------------------------------------------------------------------
		public function toString() : String {
		return "[OpCode name=\"" + _name + "\", numRegister=" + _numRegister + ", emitCode=" + _emitCode + ", flags=" + _flags + "]";
	}

}

// ===========================================================================
//	Class
// ---------------------------------------------------------------------------
class Register {
	public var emitCode(getEmitCode, never) : UInt;
	public var longName(getLongName, never) : String;
	public var name(getName, never) : String;
	public var flags(getFlags, never) : UInt;
	public var range(getRange, never) : UInt;

	// ======================================================================
		//	Properties
		// ----------------------------------------------------------------------
		var _emitCode : UInt;
	var _name : String;
	var _longName : String;
	var _flags : UInt;
	var _range : UInt;
	// ======================================================================
		//	Getters
		// ----------------------------------------------------------------------
		public function getEmitCode() : UInt {
		return _emitCode;
	}

	public function getLongName() : String {
		return _longName;
	}

	public function getName() : String {
		return _name;
	}

	public function getFlags() : UInt {
		return _flags;
	}

	public function getRange() : UInt {
		return _range;
	}

	// ======================================================================
		//	Constructor
		// ----------------------------------------------------------------------
		public function new(name : String, longName : String, emitCode : UInt, range : UInt, flags : UInt) {
		_name = name;
		_longName = longName;
		_emitCode = emitCode;
		_range = range;
		_flags = flags;
	}

	// ======================================================================
		//	Methods
		// ----------------------------------------------------------------------
		public function toString() : String {
		return "[Register name=\"" + _name + "\", longName=\"" + _longName + "\", emitCode=" + _emitCode + ", range=" + _range + ", flags=" + _flags + "]";
	}

}

// ===========================================================================
//	Class
// ---------------------------------------------------------------------------
class Sampler {
	public var flag(getFlag, never) : UInt;
	public var mask(getMask, never) : UInt;
	public var name(getName, never) : String;

	// ======================================================================
		//	Properties
		// ----------------------------------------------------------------------
		var _flag : UInt;
	var _mask : UInt;
	var _name : String;
	// ======================================================================
		//	Getters
		// ----------------------------------------------------------------------
		public function getFlag() : UInt {
		return _flag;
	}

	public function getMask() : UInt {
		return _mask;
	}

	public function getName() : String {
		return _name;
	}

	// ======================================================================
		//	Constructor
		// ----------------------------------------------------------------------
		public function new(name : String, flag : UInt, mask : UInt) {
		_name = name;
		_flag = flag;
		_mask = mask;
	}

	// ======================================================================
		//	Methods
		// ----------------------------------------------------------------------
		public function toString() : String {
		return "[Sampler name=\"" + _name + "\", flag=\"" + _flag + "\", mask=" + mask + "]";
	}

}

