package as3Shader {
	import flash.display3D.Context3DProgramType;
	import flash.geom.Matrix3D;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import as3Shader.Var;
	/**
	 * http://help.adobe.com/en_US/as3/dev/WSd6a006f2eb1dc31e-310b95831324724ec56-8000.html
	 * @author lizhi
	 */
	public class AS3Shader 
	{
		public var lines:Array = [];
		public var logs:Object = { };
		private var tempCounter:int = 0;
		private var np:NativeOp;
		
		private var uniformCounter:int = 0;
		private var samplerCounter:int = 0;
		private var buffCounter:int = 0;
		private var varyingCounter:int = 0;
		public var uniforms:Array;
		public var samplers:Array;
		public var buffs:Array;
		public var varyings:Array;
		public var temps:Array;
		private var uniformVars:Array;
		private var samplerVars:Array;
		private var buffVars:Array;
		private var varyingVars:Array;
		private var tempVars:Array;
		
		public var programType:String;
		public var constPoolVec:Vector.<Number>;
		public var constMemLen:int = 0;
		
		public var invalid:Boolean = true;
		public var creator:Creator;
		public function AS3Shader(programType:String=Context3DProgramType.VERTEX,creator:Creator=null) 
		{
			this.creator=creator||new AGALCodeCreator;
			this.programType = programType;
			np = new NativeOp(this);
		}
		
		public function clear():void {
			lines = [];
			tempCounter = 0;
			uniformCounter = 0;
			samplerCounter = 0;
			buffCounter = 0;
			varyingCounter = 0;
			constMemLen = 0;
		}
		
		public function build():void {
			
		}
		
		private function findUsed(lines:Array,i:int,usedline:Array):void{
			if (usedline[i]){
				return;
			}
			usedline[i] = true;
			var line:Array = lines[i];
			//trace(i, "used");
			var nv:Var = line[1];
			if (nv&&nv.component is Var){
				findUsedSub(lines, nv.component as Var, i,usedline);
			}
			for (var j:int = line[2]?2:1; j < line.length; j++ ){
				findUsedSub(lines, line[j] as Var, i,usedline);
			}
		}
		
		private function findUsedSub(lines:Array, v:Var, i:int,usedline:Array):void{
			var comps:Array = [];
			for (var k:int = i - 1; k >= 0;k-- ){
				var line2:Array = lines[k];
				var v2:Var = line2[1];
				if (v2.type == v.type && v2.index == v.index){
					findUsed(lines,k,usedline);
					if (v2.component==null){
						break;
					}
				}
			}
		}
		
		public function optimize():void {
			var xyzw:String = "xyzw";
			var startEnds:Array = [];
			var ttypePool:Array = [];
			var tempConsts:Array = [];
			var constPool:Array = [];
			uniforms = [];
			samplers = [];
			buffs = [];
			varyings = [];
			temps = [];
			//删除多余line 
			// todo : vshader fshader v (eif etc)
			/*var usedline:Array = [];
			for (var i:int = lines.length - 1; i >= 0;i-- ){
				line = lines[i];
				var t:Var = line[1];
				if (line[2]==null||t.type==Var.TYPE_OP||t.type==Var.TYPE_OC||t.type==Var.TYPE_V){
					findUsed(lines,i,usedline);
				}
			}
			for (i = lines.length - 1; i >= 0;i-- ){
				if (usedline[i]==null){
					trace("remove line", i);
					lines.splice(i, 1);
				}
			}*/
			//find
			for (var i:int = 0; i < lines.length;i++ ) {
				var line:Array = lines[i];
				var len:int = line.length;
				for (var j:int = 1; j <len ;j++ ) {
					var v:Var = line[j];
					addVar(v, i, startEnds, ttypePool, tempConsts);
					if (v.component is Var) {
						addVar(v.component as Var, i, startEnds, ttypePool, tempConsts);
					}
				}
			}
			
			//optimize temp
			len = startEnds.length;
			for (i = 1; i <len ;i++ ) {
				var startEnd:Array = startEnds[i];
				if(startEnd){
					var start:int = startEnd[0];
					for (j = 0; j < i;j++ ) {
						var startEnd2:Array = startEnds[j];
						if (startEnd2&&(start > startEnd2[1])) {//找到没被使用的变量
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
			}
			
			if (uniformCounter) {
				uniforms=optimizeVar(uniforms,uniformVars);
			}
			for each(v in uniforms) {
				var theConstMemLen:int = v.index + v.constLenght;
				if (theConstMemLen>constMemLen) {
					constMemLen = theConstMemLen;
				}
			}
			if (programType==Context3DProgramType.FRAGMENT) {
				samplers=optimizeVar(samplers,samplerVars);
			}
			if (programType==Context3DProgramType.VERTEX) {
				buffs=optimizeVar(buffs,buffVars);
			}
			if (programType==Context3DProgramType.VERTEX) {
				varyings=optimizeVar(varyings,varyingVars);
			}
			temps=optimizeVar(temps,temps);
			
			
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
			constPoolVec = Vector.<Number>(constPool);
			//trace("pool",constPool);
		}
		
		private function addVar(v:Var,i:int,startEnds:Array,ttypePool:Array,tempConsts:Array):void {
			if (v.type==Var.TYPE_T) {//找到所有临时变量，并找到它开始被使用和最后被使用的索引
				var startEnd:Array = startEnds[v.index];
				if (startEnd == null) startEnd = startEnds[v.index] = [i, i];
				startEnd[1] = i;
				var vs:Array = ttypePool[v.index];//把相同索引的临时变量放入数组
				if (vs == null) vs = ttypePool[v.index] = [];
				vs.push(v);
				temps.push(v);
			}else if (v.type==Var.TYPE_C) {//遍历常量
				if (v.index!=-1) {//找到非临时常量使用的最大内存
					uniforms.push(v);
				}else {//找到临时常量
					tempConsts.push(v);
				}
			}else if (v.type==Var.TYPE_FS) {
				samplers.push(v);
			}else if (v.type==Var.TYPE_VA) {
				buffs.push(v);
			}else if (v.type==Var.TYPE_V) {
				varyings.push(v);
			}
		}
		
		public function optimizeVar(vars:Array, sourceVars:Array):Array {
			if (sourceVars==null||sourceVars.length == 0) return vars;
			var map:Object = { };
			var newVars:Array = [];
			var index2newindex:Object = { };
			var len:int = 0;
			for each(var v:Var in vars) {
				if (map[v.index]==null) {
					map[v.index] = []
					newVars.push(v);//可能有多个相同索引的，但只push入第一个
					index2newindex[v.index] = len;
					len += v.constLenght;
				}
				map[v.index].push(v);
			}
			for each(v in sourceVars) {
				if (map[v.index]) {
					map[v.index].push(v);
				}
			}
			for (var key:String in map) {
				var newIndex:int = index2newindex[key];
				for each(v in map[key]) {
					v.index = newIndex;
					v.used = true;
				}
			}
			return newVars;
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
		
		private function createUniform(len:int = 1):Var {
			var c:Var = C(uniformCounter++, len);
			uniformVars = uniformVars || [];
			uniformVars.push(c);
			return c;
		}
		
		public function uniform():Var {
			return createUniform();
		}
		
		public function matrix():Var {
			return createUniform(4);
		}
		
		public function matrix34():Var {
			return createUniform(3);
		}
		
		public function floatArray(len:int):Var {
			return createUniform(len);
		}
		
		public function matrixArray(len:int):Var {
			return createUniform(len*4);
		}
		
		public function matrix34Array(len:int):Var {
			return createUniform(len*3);
		}
		
		public function buff():Var {
			var va:Var = VA(buffCounter++);
			buffVars = buffVars || [];
			buffVars.push(va);
			return va;
		}
		
		public function sampler():Var {
			var fs:Var = FS(samplerCounter++);
			samplerVars = samplerVars || [];
			samplerVars.push(fs);
			return fs;
		}
		
		public function varying():Var {
			var v:Var = V(varyingCounter++);
			varyingVars = varyingVars || [];
			varyingVars.push(v);
			return v;
		}
		
		public function get code():Object {
			if (invalid) {
				invalid = false;
				build();
				optimize();
				creator.creat(this);
			}
			if(creator.data==null)creator.creat(this);
			return creator.data;
		}
		
		public function get op():Var 
		{
			return new Var(Var.TYPE_OP);
		}
		
		public function set op(value:Var):void 
		{
			mov(value, op);
		}
		
		public function get oc():Var 
		{
			return new Var(Var.TYPE_OC);
		}
		
		public function set oc(value:Var):void 
		{
			mov(value, oc);
		}
		
		public function debug(txt:Object):void {
			logs[lines.length] = logs[lines.length] || [];
			logs[lines.length].push(txt);
		}
		
		public function f(op:String, a:Object = null, b:Object = null, t:Var = null, flag:Array = null, numParam:int = 3 ,component:String=null):Var {
			var line:Array = [op];
			if (a != null) {
				var av:Var=object2Var(a)
				line.push(av);
			}
			if (b != null) {
				var bv:Var=object2Var(b)
				line.push(bv);
			}
			if (av && bv && av.type == Var.TYPE_C && bv.type == Var.TYPE_C&&av.data&&bv.data) {
				return np.doop(op,av,bv);
				//throw "can not all the a,b type const"
			}
			if(numParam>1){
				var c:Var = t || createTempVar();
			}
			if (component) {
				c = c.c(component);
			}
			if (c) line.splice(1,0,c);
			/*if (c==null) {
				throw "no target"
			}*/
			
			line["flag"] = flag;
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
		
		public function length(a:Object, len:int = 2, t:Var = null):Var {
			if(len==2){
				var c:Var = mul(a, a);
				var arr:Array = [c.x,c.y];
				if (len>2) {
					arr.push(c.z);
				}
				if (len>3) {
					arr.push(c.w);
				}
				return sqt(add2(arr), t);
			}
			return sqt(dp3(a,a),t);
			
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
            return mul2([x2,x2,sub(3 , add(x2,x2))],t);
        }
		
		public function mix(a:Object, b:Object, v:Object, t:Var = null):Var {
			var out:Var = add(a, mul(v, sub(b, a)), t);
			return out;
		}
		
		public function mod(a:Object, b:Object, t:Var=null):Var {
			var c:Var = div(a, b);
			return mul(frc(c), b, t);
		}
		
		public function fwidth(a:Object, t:Var = null):Var {
			return add(abs( ddx( a ) ) , abs( ddy( a ) ),t);
		}
		
		public function vec2(a:Object, b:Object, t:Var = null):Var {
			t = t || createTempVar();
			mov(b, t.w);
			mov(b, t.z);
			mov(b, t.y);
			mov(a, t.x);
			return t;
		}
		
		public function vec3(a:Object, b:Object, c:Object, t:Var = null):Var {
			t = t || createTempVar();
			mov(c, t.w);
			mov(c, t.z);
			mov(b, t.y);
			mov(a, t.x);
			return t;
		}
		
		public function vec4(a:Object, b:Object,c:Object,d:Object, t:Var = null):Var {
			t = t || createTempVar();
			mov(d, t.w);
			mov(c, t.z);
			mov(b, t.y);
			mov(a, t.x);
			return t;
		}
		
		public function mul2(arr:Array, t:Var=null):Var {return f2("mul", arr, t);}
		public function add2(arr:Array, t:Var=null):Var {return f2("add", arr, t);}
		public function sub2(arr:Array, t:Var=null):Var {return f2("sub", arr, t);}
		public function div2(arr:Array, t:Var=null):Var {return f2("div", arr, t);}
		public function max2(arr:Array, t:Var=null):Var {return f2("max", arr, t);}
		public function min2(arr:Array, t:Var=null):Var {return f2("min", arr, t);}
		public function clamp(a:Object, minValue:Object, maxValue:Object, t:Var = null):Var {
			return min(maxValue, max(a, minValue), t);
		}
		public function floor(a:Object, t:Var = null):Var {
			return sub(a, frc(a), t);
		}
		
		
		
		//http://molecularmusings.wordpress.com/2013/05/24/a-faster-quaternion-vector-multiplication/
		//t = 2 * cross(q.xyz, v)
		//v' = v + q.w * t + cross(q.xyz, t)
		public function q44(pos:Var, quas:Var, tran:Var):Var {
			var temp:Var = add(q33(pos, mov(quas)), tran);
			mov(1, temp.w);
			return temp.xyzw;
		}
		
		public function q33(pos:Var, quas:Var):Var {
			var t:Var = mul(2 , crs(quas, pos));
			return add2([pos , mul(quas.w , t) , crs(quas, t)]);
		}
		
		public function half2float(half:Var):Var{
			debug("half2float start");
			half = mov(half);
			var halfshr10:Var = div(half , Math.pow(2,10));
			var fshr10:Var = frc(halfshr10);
			var se:Var = sub(halfshr10 , fshr10);
			var seshr5:Var = div(se , Math.pow(2, 5));
			var eshr5:Var = frc(seshr5);
			var e:Var = mul(eshr5 , Math.pow(2, 5));
			var v:Var = mul(pow(2, sub(e, 15)) , add(1 , fshr10));
			var s:Var = seq(seshr5, eshr5);
			s = sub(s, .5);
			s = mul(s, 2);
			v = mul(v, s);
			v = mul(v, sne(half, 0));
			debug("half2float end");
			return v;
		}
		
		public function half2float2(half2:Var):Array{
			debug("half2float2 start");
			var half2shr16:Var = div(half2, 0x10000);
			var lowshr16:Var = frc(half2shr16);
			var highshr16:Var = sub(half2shr16, lowshr16);
			debug("half2float2 end");
			return [half2float(highshr16), half2float(mul(lowshr16, 0x10000))];
		}
		
		/** float */
		public function F(data:Object, len:int = 1):Var { 
			if (data is int||data is Number||data is uint) {
				return createTempConst([data], len) 
			}else if (data is Vector.<Number>&&data.length>=4) {// TODO :
				return createTempConst([data[0],data[1],data[2],data[3]], len) 
			}
			return createTempConst(data, len) 
		}
		public function M(data:Matrix3D):Var { return createTempConst(data,4) };
		public function C(index:int = 0, len:int=1):Var {
			var c:Var = new Var(Var.TYPE_C, index);
			c.constLenght = len;
			return c;
		}
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
		public function m34(a:Object, b:Object, t:Var=null,component:String=null):Var {return f("m34", a, b, t,null,3,component||"xyz");}
		public function ddx(a:Object, t:Var=null):Var {return f("ddx", a, null, t);}
		public function ddy(a:Object, t:Var=null):Var {return f("ddy", a, null, t);}
		public function ife(a:Object, b:Object):Var {return f("ife", a, b,null,null,1);}
		public function ine(a:Object, b:Object):Var {return f("ine", a, b,null,null,1);}
		public function ifg(a:Object, b:Object):Var {return f("ifg", a, b, null,null,1);}
		public function ifl(a:Object, b:Object):Var {return f("ifl", a, b, null,null,1);}
		public function els():Var {return f("els", null,null,null,null,0);}
		public function eif():Var {return f("eif", null,null,null,null,0);}
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