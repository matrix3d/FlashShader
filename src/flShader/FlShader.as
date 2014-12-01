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
		public var logs:Object = { };
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
								if (floats[k]!=constPool[i+j+k]) {
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
						v.component = xyzw.substr((i+j+k-floatsLen)%4,floatsLen);
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
			c.constLenght = len;
			if (data.length < 4) {
				var xyzw:String = "xyzw";
				c.component = xyzw.substr(0, data.length);
			}
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
		
		public function debug(txt:Object):void {
			logs[lines.length] = logs[lines.length] || [];
			logs[lines.length].push(txt);
		}
		
		public function f(op:String, a:Object = null, b:Object = null, t:Var = null, flag:Array = null, numParam:int = 3 ,component:String=null):Var {
			if(numParam>1)
			var c:Var = t || createTempVar();
			if (component) {
				c = c.c(component);
			}
			var line:Array = [op];
			if (c) line.push(c);
			if (a != null) {
				var av:Var=object2Var(a)
				line.push(av);
			}
			if (b != null) {
				var bv:Var=object2Var(b)
				line.push(bv);
			}
			if (av&&bv&&av.type==Var.TYPE_C&&bv.type==Var.TYPE_C) {
				throw "can not all the a,b type const"
			}
			/*if (c==null) {
				throw "no target"
			}*/
			
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
		
		public function distance(a:Object, b:Object,len:int=2, t:Var=null):Var {
			return length(sub(a, b), len,t);
		}
		
		public function length(a:Object,len:int=2, t:Var = null):Var {
			var c:Var = mul(a, a);
			var arr:Array = [c.x,c.y];
			if (len>2) {
				arr.push(c.z);
			}
			if (len>3) {
				arr.push(c.w);
			}
			return sqt(add2(arr),t);
			//return sqt(dp4(a,a).x, t);
		}
		
		//https://gist.github.com/gradbot/1749635
		public function atan(a:Object,t:Var=null):Var {
			return div(mul(Math.PI / 2 , a) , add(1 ,abs(a)),t);
		}
		
		//http://en.wikipedia.org/wiki/Atan2
		//return 2 * Math.atan(y/(Math.sqrt(x*x+y*y)+x));
		//return 2 * Math.atan(y/(Math.sqrt(x*x+y*y)+x));
		public function atan2(y:Object,x:Object,t:Var=null):Var {
			return mul(2 , atan(div(y,add(sqt(add(mul(x,x),mul(y,y))),x))),t);
		}
		
		//http://en.wikipedia.org/wiki/Smoothstep
        public function smoothstep(edge0:Object, edge1:Object, x:Object,t:Var=null):Var
        {
            // Scale, bias and saturate x to 0..1 range
            var x2:Var = sat(div(sub(x , edge0) , sub(edge1 , edge0)));
            // Evaluate polynomial
            return mul2([x2,x2,sub(3 , mul(2,x2))],t);
        }
		
		public function mix(a:Object, b:Object, v:Object, t:Var = null):Var {
			return add(mul(sub(1,v),a),mul(v, b),t);
		}
		
		public function mod(a:Object, b:Object, t:Var=null):Var {
			return mul(modfrc(a,b), b, t);
		}
		
		public function modfrc(a:Object, b:Object, t:Var=null):Var {
			var c:Var = div(a, b);
			return frc(c,t);
		}
		
		public function fwidth(a:Object, t:Var = null):Var {
			return add(abs( ddx( a ) ) , abs( ddy( a ) ),t);
		}
		
		public function vec2(a:Object, b:Object, t:Var = null):Var {
			t = t || createTempVar();
			mov(a, t.x);
			mov(b, t.y);
			return t;
		}
		
		public function vec3(a:Object, b:Object, c:Object,t:Var = null):Var {
			t = vec2(a, b, t);
			mov(c, t.z);
			return t;
		}
		
		public function vec4(a:Object, b:Object,c:Object,d:Object, t:Var = null):Var {
			t = vec3(a, b, c, t);
			mov(d, t.w);
			return t;
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
		
		public function mov(a:Object, t:Var=null):Var {return f("mov", a, null, t);}
		public function add(a:Object, b:Object, t:Var=null):Var {return f("add", a, b, t);}
		public function sub(a:Object, b:Object, t:Var=null):Var {return f("sub", a, b, t);}
		public function mul(a:Object, b:Object, t:Var=null):Var {return f("mul", a, b, t);}
		public function div(a:Object, b:Object, t:Var=null):Var {return f("div", a, b, t);}
		public function rcp(a:Object, t:Var=null):Var {return f("rcp", a, null, t);}
		public function min(a:Object, b:Object, t:Var=null):Var {return f("min", a, b, t);}
		public function max(a:Object, b:Object, t:Var=null):Var {return f("max", a, b, t);}
		public function frc(a:Object, t:Var=null):Var {return f("frc", a, null, t);}
		public function sqt(a:Object, t:Var=null):Var {return f("sqt", a, null, t);}
		public function rsq(a:Object, t:Var=null):Var {return f("rsq", a, null, t);}
		public function pow(a:Object, b:Object, t:Var=null):Var {return f("pow", a, b, t);}
		public function log(a:Object, t:Var=null):Var {return f("log", a, null, t);}
		public function exp(a:Object,  t:Var=null):Var {return f("exp", a, null, t);}
		public function nrm(a:Object, t:Var=null,component:String=null):Var {return f("nrm", a, null, t,null,3,component||"xyz");}
		public function sin(a:Object,  t:Var=null):Var {return f("sin", a, null, t);}
		public function cos(a:Object,  t:Var=null):Var {return f("cos", a, null, t);}
		public function crs(a:Object, b:Object, t:Var=null,component:String=null):Var {return f("crs", a, b, t,null,3,component||"xyz");}
		public function dp3(a:Object, b:Object, t:Var=null):Var {return f("dp3", a, b, t);}
		public function dp4(a:Object, b:Object, t:Var=null):Var {return f("dp4", a, b, t);}
		public function abs(a:Object,  t:Var=null):Var {return f("abs", a, null, t);}
		public function neg(a:Object,  t:Var=null):Var {return f("neg", a, null, t);}
		public function sat(a:Object,  t:Var=null):Var {return f("sat", a, null, t);}
		public function m33(a:Object, b:Object, t:Var=null,component:String=null):Var {return f("m33", a, b, t,null,3,component||"xyz");}
		public function m44(a:Object, b:Object, t:Var=null):Var {return f("m44", a, b, t);}
		public function m34(a:Object, b:Object, t:Var=null):Var {return f("m34", a, b, t);}
		public function ddx(a:Object, t:Var=null):Var {return f("ddx", a, null, t);}
		public function ddy(a:Object, t:Var=null):Var {return f("ddy", a, null, t);}
		public function ife(a:Object, b:Object, t:Var=null):Var {return f("ife", a, b, t);}
		public function ine(a:Object, b:Object, t:Var=null):Var {return f("ine", a, b, t);}
		public function ifg(a:Object, b:Object, t:Var=null):Var {return f("ifg", a, b, t);}
		public function ifl(a:Object, b:Object, t:Var=null):Var {return f("ifl", a, b, t);}
		public function els(a:Object, b:Object, t:Var=null):Var {return f("els", a, b, t);}
		public function eif(a:Object, b:Object, t:Var=null):Var {return f("eif", a, b, t);}
		public function ted(a:Object, b:Object, t:Var=null):Var {return f("ted", a, b, t);}
		public function kil(a:Object):Var {return f("kil", a, null, null,null,1);}
		public function tex(a:Object = null, b:Object = null, t:Var = null, flags:Array = null):Var {return f("tex", a, b, t,flags);}
		public function sge(a:Object, b:Object, t:Var=null):Var {return f("sge", a, b, t);}
		public function slt(a:Object, b:Object, t:Var=null):Var {return f("slt", a, b, t);}
		public function sgn(a:Object, b:Object, t:Var=null):Var {return f("sgn", a, b, t);}
		public function seq(a:Object, b:Object, t:Var=null):Var {return f("seq", a, b, t);}
		public function sne(a:Object, b:Object, t:Var=null):Var {return f("sne", a, b, t);}
		
	}

}