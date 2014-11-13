package flShader {
	import flash.display3D.Context3DProgramType;
	import flash.geom.Matrix3D;
	import flash.utils.ByteArray;
	import flShader.Var;
	/**
	 * ...
	 * @author lizhi
	 */
	public class FlShader 
	{
		public var lines:Array = [];
		private var tempCounter:int = 0;
		
		public var programType:String;
		public static const op:Var = new Var(Var.TYPE_OP);
		public static const oc:Var = new Var(Var.TYPE_OC);
		
		public var constPool:Array = [];
		public var constMemLen:int = 0;
		
		public var invalid:Boolean = true;
		public var creator:Creator;
		public function FlShader(programType:String=Context3DProgramType.VERTEX,creator:Creator=null) 
		{
			this.creator=creator||new AGALCodeCreator;
			this.programType = programType;
		}
		
		public function clear():void {
			lines = [];
			tempCounter = 0;
			constPool = [];
			constMemLen = 0;
		}
		
		public function build():void {
			
		}
		
		public function optimize():void {
			var xyzw:String = "xyzw";
			var startEnds:Array = [];
			var ttypePool:Array = [];
			var tempConsts:Array = [];
			for (var i:int = 0; i < lines.length;i++ ) {
				var line:Array = lines[i];
				for (var j:int = 1,len:int=line.length; j <len ;j++ ) {
					var v:Var = line[j];
					if (v.type==Var.TYPE_T) {//找到所有临时变量，并找到它开始被使用和最后被使用的索引
						var startEnd:Array = startEnds[v.index];
						if (startEnd == null) startEnd = startEnds[v.index] = [i, i];
						startEnd[1] = i;
						var vs:Array = ttypePool[v.index];//把相同索引的临时变量放入数组
						if (vs == null) vs = ttypePool[v.index] = [];
						vs.push(v);
					}else if (v.type==Var.TYPE_C) {//遍历常量
						if (v.index!=-1) {//找到非临时常量使用的最大内存
							var theConstMemLen:int = v.index + v.constLenght;
							if (theConstMemLen>constMemLen) {
								constMemLen = theConstMemLen;
							}
						}else {//找到临时常量
							tempConsts.push(v);
						}
					}
				}
			}
			for (i = 1,len=startEnds.length; i <len ;i++ ) {
				startEnd = startEnds[i];
				var start:int = startEnd[0];
				for (j = 0; j < i;j++ ) {
					var startEnd2:Array = startEnds[j];
					if (start > startEnd2[1]) {//找到没被使用的变量
						for each(v in ttypePool[i]) {
							v.index = j;
						}
						startEnd2[1] = startEnd[1];
						startEnd[0] = 0;
						startEnd[1] = 0;
						break;
					}
				}
			}
			
			for each(v in tempConsts) {
				var floats:Array = v.data as Array;
				var floatsLen:int = floats.length;
				var floatsLen2:int = floatsLen;
				var have:Boolean = false;
				if(floatsLen<=4){
					for (i = 0; i < constPool.length; i += 4 ) {
						for (j = 0; j <= 4-floatsLen;j++ ) {
							have = true;
							for (var k:int = 0; k < floatsLen; k++ ) {
								if (floats[k]!=constPool[i*4+j+k]) {
									have = false;
									break;
								}
							}
							if (have) {
								break;
							}
						}
						if (have) {
							break;
						}
					}
				}else {
					// TODO : matrix3d >4 vec
				}
				if (have) {
					v.index = int(i / 4)+constMemLen;
					if ((i%4) > 0||floatsLen2!=4) {
						v.component = xyzw.substr(i%4,floatsLen);
					}
				}else {
					if (floatsLen2>4) {
						floatsLen2 = 4;
					}
					var startConstIndex:int = constPool.length;
					while (true) {	
						var startConstLineIndex:int = startConstIndex % 4;
						if ((startConstLineIndex+floatsLen2)<=4) {
							break;
						}
						startConstIndex++;
					}
					
					for (k = 0; k < floatsLen; k++ ) {
						constPool[k + startConstIndex] = floats[k];
					}
					v.index = int(startConstIndex / 4)+constMemLen;
					if (startConstLineIndex > 0||floatsLen2!=4) {
						v.component = xyzw.substr(startConstLineIndex,floatsLen);
					}
				}
				//trace(floats,have);
			}
			while ((constPool.length%4)!=0) {
				constPool.push(0);
			}
			//trace("pool",constPool);
		}
		
		public function createTempVar():Var {
			var v:Var = new Var(Var.TYPE_T, tempCounter);
			tempCounter++;
			return v;
		}
		
		private function createTempConst(data:Object,len:int=1):Var {
			var c:Var = C(-1);
			c.data = data;
			c.constLenght=len
			return c;
		}
		
		public function get code():String {
			if (invalid) {
				invalid = false;
				build();
				optimize();
				creator.creat(this);
			}
			if(creator.data==null)creator.creat(this);
			return creator.data + "";
		}
		
		public function get code2():ByteArray {
			if (invalid) {
				invalid = false;
				build();
				optimize();
				creator.creat(this)
			}
			if(creator.data==null)creator.creat(this);
			return creator.data as ByteArray;
		}
		
		public function f(op:String, a:Object = null, b:Object = null, t:Var = null, flag:Array = null, numParam:int = 3 ,component:String=null):Var {
			if(numParam>1)
			var c:Var = t || createTempVar();
			if (component) {
				c = c.c(component);
			}
			var line:Array = [op];
			if (c) line.push(c);
			if (a!=null) line.push(object2Var(a));
			if (b!=null) line.push(object2Var(b));
			line.flag = flag;
			lines.push(line);
			return c;
		}
		
		public function object2Var(v:Object):Var {
			return v is Var?v as Var:F(v);
		}
		
		public function f2(op:String,arr:Array, t:Var=null):Var {
			if (arr.length==0) {
				return t;
			}else if (arr.length==1) {
				return mov(arr[0], t);
			}
			var a:Object = arr[0];
			for (var i:int = 1; i < arr.length-1;i++ ) {
				a = f(op,a,arr[i]);
			}
			return f(op, a, arr[arr.length - 1], t);
		}
		
		public function distance2(a:Var, b:Var, t:Var=null):Var {
			var d:Var = sub(a, b);
			var d2:Var = mul(d, d);
			var arr:Array = [d2.x, d2.y];
			return sqt(add2(arr), t);
		}
		
		public function distance3(a:Var, b:Var, t:Var=null):Var {
			var d:Var = sub(a, b);
			var d2:Var = mul(d, d);
			var arr:Array = [d2.x, d2.y,d2.z];
			return sqt(add2(arr), t);
		}
		
		public function mul2(arr:Array, t:Var=null):Var {return f2("mul", arr, t);}
		public function add2(arr:Array, t:Var=null):Var {return f2("add", arr, t);}
		public function sub2(arr:Array, t:Var=null):Var {return f2("sub", arr, t);}
		public function div2(arr:Array, t:Var=null):Var {return f2("div", arr, t);}
		public function max2(arr:Array, t:Var=null):Var {return f2("max", arr, t);}
		public function min2(arr:Array, t:Var=null):Var {return f2("min", arr, t);}
		
		/** float */
		public function F(data:Object, len:int = 1):Var { 
			if (data is int||data is Number||data is uint) {
				return createTempConst([data], len) 
			}
			return createTempConst(data, len) 
		};
		public function M(data:Matrix3D):Var { return createTempConst(data,4) };
		public function C(index:int = 0, len:int=1):Var {
			var c:Var = new Var(Var.TYPE_C, index);
			c.constLenght = len;
			return c;
		};
		public function T(index:int=0):Var { return new Var(Var.TYPE_T,index)};
		public function VA(index:int=0):Var { return new Var(Var.TYPE_VA,index)};
		public function V(index:int=0):Var { return new Var(Var.TYPE_V,index)};
		public function FS(index:int=0):Var { return new Var(Var.TYPE_FS,index)};
		
		public function mov(a:Object=null, t:Var=null):Var {return f("mov", a, null, t);}
		public function add(a:Object=null, b:Object=null, t:Var=null):Var {return f("add", a, b, t);}
		public function sub(a:Object=null, b:Object=null, t:Var=null):Var {return f("sub", a, b, t);}
		public function mul(a:Object=null, b:Object=null, t:Var=null):Var {return f("mul", a, b, t);}
		public function div(a:Object=null, b:Object=null, t:Var=null):Var {return f("div", a, b, t);}
		public function rcp(a:Object=null, t:Var=null):Var {return f("rcp", a, null, t);}
		public function min(a:Object=null, b:Object=null, t:Var=null):Var {return f("min", a, b, t);}
		public function max(a:Object=null, b:Object=null, t:Var=null):Var {return f("max", a, b, t);}
		public function frc(a:Object=null, t:Var=null):Var {return f("frc", a, null, t);}
		public function sqt(a:Object=null, t:Var=null):Var {return f("sqt", a, null, t);}
		public function rsq(a:Object=null, t:Var=null):Var {return f("rsq", a, null, t);}
		public function pow(a:Object=null, b:Object=null, t:Var=null):Var {return f("pow", a, b, t);}
		public function log(a:Object=null, t:Var=null):Var {return f("log", a, null, t);}
		public function exp(a:Object=null,  t:Var=null):Var {return f("exp", a, null, t);}
		public function nrm(a:Object=null, t:Var=null,component:String=null):Var {return f("nrm", a, null, t,null,3,component||"xyz");}
		public function sin(a:Object=null,  t:Var=null):Var {return f("sin", a, null, t);}
		public function cos(a:Object=null,  t:Var=null):Var {return f("cos", a, null, t);}
		public function crs(a:Object=null, b:Object=null, t:Var=null,component:String=null):Var {return f("crs", a, b, t,null,3,component||"xyz");}
		public function dp3(a:Object=null, b:Object=null, t:Var=null):Var {return f("dp3", a, b, t);}
		public function dp4(a:Object=null, b:Object=null, t:Var=null):Var {return f("dp4", a, b, t);}
		public function abs(a:Object=null,  t:Var=null):Var {return f("abs", a, null, t);}
		public function neg(a:Object=null,  t:Var=null):Var {return f("neg", a, null, t);}
		public function sat(a:Object=null,  t:Var=null):Var {return f("sat", a, null, t);}
		public function m33(a:Object=null, b:Object=null, t:Var=null,component:String=null):Var {return f("m33", a, b, t,null,3,component||"xyz");}
		public function m44(a:Object=null, b:Object=null, t:Var=null):Var {return f("m44", a, b, t);}
		public function m34(a:Object=null, b:Object=null, t:Var=null):Var {return f("m34", a, b, t);}
		public function ddx(a:Object=null, t:Var=null):Var {return f("ddx", a, null, t);}
		public function ddy(a:Object=null, t:Var=null):Var {return f("ddy", a, null, t);}
		public function ife(a:Object=null, b:Object=null, t:Var=null):Var {return f("ife", a, b, t);}
		public function ine(a:Object=null, b:Object=null, t:Var=null):Var {return f("ine", a, b, t);}
		public function ifg(a:Object=null, b:Object=null, t:Var=null):Var {return f("ifg", a, b, t);}
		public function ifl(a:Object=null, b:Object=null, t:Var=null):Var {return f("ifl", a, b, t);}
		public function els(a:Object=null, b:Object=null, t:Var=null):Var {return f("els", a, b, t);}
		public function eif(a:Object=null, b:Object=null, t:Var=null):Var {return f("eif", a, b, t);}
		public function ted(a:Object=null, b:Object=null, t:Var=null):Var {return f("ted", a, b, t);}
		public function kil(a:Object=null, b:Object=null, t:Var=null):Var {return f("kil", a, b, t,null,1);}
		public function tex(a:Object = null, b:Object = null, t:Var = null, flags:Array = null):Var {return f("tex", a, b, t,flags);}
		public function sge(a:Object=null, b:Object=null, t:Var=null):Var {return f("sge", a, b, t);}
		public function slt(a:Object=null, b:Object=null, t:Var=null):Var {return f("slt", a, b, t);}
		public function sgn(a:Object=null, b:Object=null, t:Var=null):Var {return f("sgn", a, b, t);}
		public function seq(a:Object=null, b:Object=null, t:Var=null):Var {return f("seq", a, b, t);}
		public function sne(a:Object=null, b:Object=null, t:Var=null):Var {return f("sne", a, b, t);}
		
	}

}