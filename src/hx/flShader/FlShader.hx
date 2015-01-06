package flShader;

import flash.display3D.Context3DProgramType;
import flash.geom.Matrix3D;
import flash.utils.ByteArray;
import flShader.Var;

/**

 * ...

 * @author lizhi

 */class FlShader {
	public var code(get_code, never) : String;
	public var code2(get_code2, never) : ByteArray;

	public var lines : Array<Dynamic>;
	public var line2Flag:Map<Array<Dynamic>,Array<String>>;
	var tempCounter : Int;
	public var programType : Context3DProgramType;
	static public var op : Var = new Var(Var.TYPE_OP);
	static public var oc : Var = new Var(Var.TYPE_OC);
	public var constPool : Array<Dynamic>;
	public var constMemLen : Int;
	public var invalid : Bool;
	public var creator : Creator;
	public function new(programType : Context3DProgramType , creator : Creator = null) {
		line2Flag=new Map<Array<Dynamic>,Array<String>>();
		lines = [];
		tempCounter = 0;
		constPool = [];
		constMemLen = 0;
		invalid = true;
		this.creator = creator!=null? creator: new AGALCodeCreator();
		this.programType = programType;
	}

	public function clear() : Void {
		lines = [];
		tempCounter = 0;
		constPool = [];
		constMemLen = 0;
	}

	public function build() : Void {
	}

	public function optimize() : Void {
		/*var xyzw : String = "xyzw";
		var startEnds : Array<Dynamic> = [];
		var ttypePool : Array<Dynamic> = [];
		var tempConsts : Array<Dynamic> = [];
		var i : Int = 0;
		while(i < lines.length) {
			var line : Array<Dynamic> = lines[i];
			var j : Int = 1;
			var len : Int = line.length;
			while(j < len) {
				var v : Var = line[j];
				if(v.type == Var.TYPE_T)  {
					//找到所有临时变量，并找到它开始被使用和最后被使用的索引
					var startEnd : Array<Dynamic> = startEnds[v.index];
					if(startEnd == null) 
						startEnd = startEnds[v.index] = [i, i];
					startEnd[1] = i;
					var vs : Array<Dynamic> = ttypePool[v.index];
					//把相同索引的临时变量放入数组
					if(vs == null) 
						vs = ttypePool[v.index] = [];
					vs.push(v);
				}

				else if(v.type == Var.TYPE_C)  {
					//遍历常量
					if(v.index != -1)  {
						//找到非临时常量使用的最大内存
						var theConstMemLen : Int = v.index + v.constLenght;
						if(theConstMemLen > constMemLen)  {
							constMemLen = theConstMemLen;
						}
					}

					else  {
						//找到临时常量
						tempConsts.push(v);
					}
				}
				j++;
			}
			i++;
		}
		i = 1;
		var len:Int = startEnds.length;
		while(i < len) {
			var startEnd = startEnds[i];
			var start : Int = startEnd[0];
			var j = 0;
			while(j < i) {
				var startEnd2 : Array<Dynamic> = startEnds[j];
				if(start > startEnd2[1])  {
					//找到没被使用的变量
					for(v in ttypePool[i]) {
						v.index = j;
					}
					startEnd2[1] = startEnd[1];
					startEnd[0] = 0;
					startEnd[1] = 0;
					break;
				}
				j++;
			}
			i++;
		}
		for(v in tempConsts) {
			var floats : Array<Dynamic> = try cast(v.data, Array) catch(e:Dynamic) null;
			var floatsLen : Int = floats.length;
			var floatsLen2 : Int = floatsLen;
			var have : Bool = false;
			if(floatsLen <= 4)  {
				i = 0;
				while(i < constPool.length) {
					var j = 0;
					while(j <= 4 - floatsLen) {
						have = true;
						var k : Int = 0;
						while(k < floatsLen) {
							if(floats[k] != constPool[i * 4 + j + k])  {
								have = false;
								break;
							}
							k++;
						}
						if(have)  {
							break;
						}
						j++;
					}
					if(have)  {
						break;
					}
					i += 4;
				}
			}

			else  {
			}

			if(have)  {
				v.index = Std.int(i / 4) + constMemLen;
				if((i % 4) > 0 || floatsLen2 != 4)  {
					v.component = xyzw.substr(i % 4, floatsLen);
				}
			}

			else  {
				if(floatsLen2 > 4)  {
					floatsLen2 = 4;
				}
				var startConstIndex : Int = constPool.length;
				var startConstLineIndex : Int = 0;
				while(true) {
					startConstLineIndex = startConstIndex % 4;
					if((startConstLineIndex + floatsLen2) <= 4)  {
						break;
					}
					startConstIndex++;
				}

				var k = 0;
				while(k < floatsLen) {
					constPool[k + startConstIndex] = floats[k];
					k++;
				}
				v.index = Std.int(startConstIndex / 4) + constMemLen;
				if(startConstLineIndex > 0 || floatsLen2 != 4)  {
					v.component = xyzw.substr(startConstLineIndex, floatsLen);
				}
			}

		}

		while((constPool.length % 4) != 0) {
			constPool.push(0);
		}*/

	}

	public function createTempVar() : Var {
		var v : Var = new Var(Var.TYPE_T, tempCounter);
		tempCounter++;
		return v;
	}

	function createTempConst(data : Dynamic, len : Int = 1) : Var {
		var c : Var = C( -1);
		c.data = data;
		c.constLenght = len;
		return c;
	}

	public function get_code() : String {
		if(invalid)  {
			invalid = false;
			build();
			optimize();
			creator.creat(this);
		}
		return creator.data + "";
	}

	public function get_code2() : ByteArray {
		if(invalid)  {
			invalid = false;
			build();
			optimize();
			creator.creat(this);
		}
		return try cast(creator.data, ByteArray) catch(e:Dynamic) null;
	}

	public function f(op : String, a : Var = null, b : Var = null, t : Var = null, flag : Array<String> = null, numParam : Int = 3, component : String = null) : Var {
		var c = null;
		if(numParam > 1) 
			c = t!=null?t: createTempVar();
		if(component != null)  {
			c = c.c(component);
		}
		var line : Array<Dynamic> = [op];
		if(c != null) 
			line.push(c);
		if(a != null) 
			line.push(a);
		if(b != null) 
			line.push(b);
		line2Flag.set(line, flag);
		lines.push(line);
		return c;
	}

	public function f2(op : String, arr : Array<Dynamic>, t : Var = null) : Var {
		if(arr.length == 0)  {
			return t;
		}

		else if(arr.length == 1)  {
			return mov(arr[0], null, t);
		}
		var a : Var = arr[0];
		var i : Int = 1;
		while(i < arr.length - 1) {
			a = f(op, a, arr[i]);
			i++;
		}
		return f(op, a, arr[arr.length - 1], t);
	}

	public function distance2(a : Var, b : Var, t : Var = null) : Var {
		var d : Var = sub(a, b);
		var d2 : Var = mul(d, d);
		var arr : Array<Dynamic> = [d2.x, d2.y];
		return sqt(add2(arr), null, t);
	}

	public function distance3(a : Var, b : Var, t : Var = null) : Var {
		var d : Var = sub(a, b);
		var d2 : Var = mul(d, d);
		var arr : Array<Dynamic> = [d2.x, d2.y, d2.z];
		return sqt(add2(arr), null, t);
	}

	public function mul2(arr : Array<Dynamic>, t : Var = null) : Var {
		return f2("mul", arr, t);
	}

	public function add2(arr : Array<Dynamic>, t : Var = null) : Var {
		return f2("add", arr, t);
	}

	public function sub2(arr : Array<Dynamic>, t : Var = null) : Var {
		return f2("sub", arr, t);
	}

	public function div2(arr : Array<Dynamic>, t : Var = null) : Var {
		return f2("div", arr, t);
	}

	public function max2(arr : Array<Dynamic>, t : Var = null) : Var {
		return f2("max", arr, t);
	}

	public function min2(arr : Array<Dynamic>, t : Var = null) : Var {
		return f2("min", arr, t);
	}

	/** float */	public function F(data : Array<Dynamic>, len : Int = 1) : Var {
		return createTempConst(data, len);
	}

	public function M(data : Matrix3D) : Var {
		return createTempConst(data, 4);
	}

	public function C(index : Int = 0) : Var {
		return new Var(Var.TYPE_C, index);
	}

	public function T(index : Int = 0) : Var {
		return new Var(Var.TYPE_T, index);
	}

	public function VA(index : Int = 0) : Var {
		return new Var(Var.TYPE_VA, index);
	}

	public function V(index : Int = 0) : Var {
		return new Var(Var.TYPE_V, index);
	}

	public function FS(index : Int = 0) : Var {
		return new Var(Var.TYPE_FS, index);
	}

	public function mov(a : Var = null, b : Var = null, t : Var = null) : Var {
		return f("mov", a, b, t);
	}

	public function add(a : Var = null, b : Var = null, t : Var = null) : Var {
		return f("add", a, b, t);
	}

	public function sub(a : Var = null, b : Var = null, t : Var = null) : Var {
		return f("sub", a, b, t);
	}

	public function mul(a : Var = null, b : Var = null, t : Var = null) : Var {
		return f("mul", a, b, t);
	}

	public function div(a : Var = null, b : Var = null, t : Var = null) : Var {
		return f("div", a, b, t);
	}

	public function rcp(a : Var = null, b : Var = null, t : Var = null) : Var {
		return f("rcp", a, b, t);
	}

	public function min(a : Var = null, b : Var = null, t : Var = null) : Var {
		return f("min", a, b, t);
	}

	public function max(a : Var = null, b : Var = null, t : Var = null) : Var {
		return f("max", a, b, t);
	}

	public function frc(a : Var = null, b : Var = null, t : Var = null) : Var {
		return f("frc", a, b, t);
	}

	public function sqt(a : Var = null, b : Var = null, t : Var = null) : Var {
		return f("sqt", a, b, t);
	}

	public function rsq(a : Var = null, b : Var = null, t : Var = null) : Var {
		return f("rsq", a, b, t);
	}

	public function pow(a : Var = null, b : Var = null, t : Var = null) : Var {
		return f("pow", a, b, t);
	}

	public function log(a : Var = null, b : Var = null, t : Var = null) : Var {
		return f("log", a, b, t);
	}

	public function exp(a : Var = null, b : Var = null, t : Var = null) : Var {
		return f("exp", a, b, t);
	}

	public function nrm(a : Var = null, b : Var = null, t : Var = null, component : String = null) : Var {
		return f("nrm", a, b, t, null, 3, component!=null?component: "xyz");
	}

	public function sin(a : Var = null, b : Var = null, t : Var = null) : Var {
		return f("sin", a, b, t);
	}

	public function cos(a : Var = null, b : Var = null, t : Var = null) : Var {
		return f("cos", a, b, t);
	}

	public function crs(a : Var = null, b : Var = null, t : Var = null) : Var {
		return f("crs", a, b, t);
	}

	public function dp3(a : Var = null, b : Var = null, t : Var = null) : Var {
		return f("dp3", a, b, t);
	}

	public function dp4(a : Var = null, b : Var = null, t : Var = null) : Var {
		return f("dp4", a, b, t);
	}

	public function abs(a : Var = null, b : Var = null, t : Var = null) : Var {
		return f("abs", a, b, t);
	}

	public function neg(a : Var = null, b : Var = null, t : Var = null) : Var {
		return f("neg", a, b, t);
	}

	public function sat(a : Var = null, b : Var = null, t : Var = null) : Var {
		return f("sat", a, b, t);
	}

	public function m33(a : Var = null, b : Var = null, t : Var = null, component : String = null) : Var {
		return f("m33", a, b, t, null, 3, component!=null?component: "xyz");
	}

	public function m44(a : Var = null, b : Var = null, t : Var = null) : Var {
		return f("m44", a, b, t);
	}

	public function m34(a : Var = null, b : Var = null, t : Var = null) : Var {
		return f("m34", a, b, t);
	}

	public function ddx(a : Var = null, b : Var = null, t : Var = null) : Var {
		return f("ddx", a, b, t);
	}

	public function ddy(a : Var = null, b : Var = null, t : Var = null) : Var {
		return f("ddy", a, b, t);
	}

	public function ife(a : Var = null, b : Var = null, t : Var = null) : Var {
		return f("ife", a, b, t);
	}

	public function ine(a : Var = null, b : Var = null, t : Var = null) : Var {
		return f("ine", a, b, t);
	}

	public function ifg(a : Var = null, b : Var = null, t : Var = null) : Var {
		return f("ifg", a, b, t);
	}

	public function ifl(a : Var = null, b : Var = null, t : Var = null) : Var {
		return f("ifl", a, b, t);
	}

	public function els(a : Var = null, b : Var = null, t : Var = null) : Var {
		return f("els", a, b, t);
	}

	public function eif(a : Var = null, b : Var = null, t : Var = null) : Var {
		return f("eif", a, b, t);
	}

	public function ted(a : Var = null, b : Var = null, t : Var = null) : Var {
		return f("ted", a, b, t);
	}

	public function kil(a : Var = null, b : Var = null, t : Var = null) : Var {
		return f("kil", a, b, t, null, 1);
	}

	public function tex(a : Var = null, b : Var = null, t : Var = null, flags : Array<String> = null) : Var {
		return f("tex", a, b, t, flags);
	}

	public function sge(a : Var = null, b : Var = null, t : Var = null) : Var {
		return f("sge", a, b, t);
	}

	public function slt(a : Var = null, b : Var = null, t : Var = null) : Var {
		return f("slt", a, b, t);
	}

	public function sgn(a : Var = null, b : Var = null, t : Var = null) : Var {
		return f("sgn", a, b, t);
	}

	public function seq(a : Var = null, b : Var = null, t : Var = null) : Var {
		return f("seq", a, b, t);
	}

	public function sne(a : Var = null, b : Var = null, t : Var = null) : Var {
		return f("sne", a, b, t);
	}

}

