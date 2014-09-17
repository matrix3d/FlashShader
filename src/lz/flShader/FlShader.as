package lz.flShader {
	/**
	 * ...
	 * @author lizhi
	 */
	public class FlShader 
	{
		//["add","sub","mul","div","rcp","min","max","frc","sqt","rsq","pow","log","exp","nrm","sin","cos","crs","dp3","dp4","abs","neg","sat","m33","m44","m34","ddx","ddy","ife","ine","ifg","ifl","els","eif","ted","kil","tex","sge","slt","sgn","seq","sne"]
		public var lines:Array = [];
		private var tempCounter:int = 0;
		public static var op:Var = new Var("op");
		public static var oc:Var = new Var("oc");
		public function FlShader(type:String="vt") 
		{
			
		}
		
		public function f(op:String,a:Var=null, b:Var=null,t:Var=null):Var {
			var c:Var = t||createTempVar();
			var line:Array = [op];
			if (c) line.push(c.name);
			if (a) line.push(a.name);
			if (b) line.push(b.name);
			lines.push(line);
			return c;
		}
		
		private function createTempVar():Var {
			var v:Var = new Var("ft" + tempCounter);
			tempCounter++;
			return v;
		}
		
		public function get code():String {
			return lines.join("\n");
		}
		public function add(a:Var=null, b:Var=null, t:Var=null):Var {return f("add", a, b, t);}
		public function sub(a:Var=null, b:Var=null, t:Var=null):Var {return f("sub", a, b, t);}
		public function mul(a:Var=null, b:Var=null, t:Var=null):Var {return f("mul", a, b, t);}
		public function div(a:Var=null, b:Var=null, t:Var=null):Var {return f("div", a, b, t);}
		public function rcp(a:Var=null, b:Var=null, t:Var=null):Var {return f("rcp", a, b, t);}
		public function min(a:Var=null, b:Var=null, t:Var=null):Var {return f("min", a, b, t);}
		public function max(a:Var=null, b:Var=null, t:Var=null):Var {return f("max", a, b, t);}
		public function frc(a:Var=null, b:Var=null, t:Var=null):Var {return f("frc", a, b, t);}
		public function sqt(a:Var=null, b:Var=null, t:Var=null):Var {return f("sqt", a, b, t);}
		public function rsq(a:Var=null, b:Var=null, t:Var=null):Var {return f("rsq", a, b, t);}
		public function pow(a:Var=null, b:Var=null, t:Var=null):Var {return f("pow", a, b, t);}
		public function log(a:Var=null, b:Var=null, t:Var=null):Var {return f("log", a, b, t);}
		public function exp(a:Var=null, b:Var=null, t:Var=null):Var {return f("exp", a, b, t);}
		public function nrm(a:Var=null, b:Var=null, t:Var=null):Var {return f("nrm", a, b, t);}
		public function sin(a:Var=null, b:Var=null, t:Var=null):Var {return f("sin", a, b, t);}
		public function cos(a:Var=null, b:Var=null, t:Var=null):Var {return f("cos", a, b, t);}
		public function crs(a:Var=null, b:Var=null, t:Var=null):Var {return f("crs", a, b, t);}
		public function dp3(a:Var=null, b:Var=null, t:Var=null):Var {return f("dp3", a, b, t);}
		public function dp4(a:Var=null, b:Var=null, t:Var=null):Var {return f("dp4", a, b, t);}
		public function abs(a:Var=null, b:Var=null, t:Var=null):Var {return f("abs", a, b, t);}
		public function neg(a:Var=null, b:Var=null, t:Var=null):Var {return f("neg", a, b, t);}
		public function sat(a:Var=null, b:Var=null, t:Var=null):Var {return f("sat", a, b, t);}
		public function m33(a:Var=null, b:Var=null, t:Var=null):Var {return f("m33", a, b, t);}
		public function m44(a:Var=null, b:Var=null, t:Var=null):Var {return f("m44", a, b, t);}
		public function m34(a:Var=null, b:Var=null, t:Var=null):Var {return f("m34", a, b, t);}
		public function ddx(a:Var=null, b:Var=null, t:Var=null):Var {return f("ddx", a, b, t);}
		public function ddy(a:Var=null, b:Var=null, t:Var=null):Var {return f("ddy", a, b, t);}
		public function ife(a:Var=null, b:Var=null, t:Var=null):Var {return f("ife", a, b, t);}
		public function ine(a:Var=null, b:Var=null, t:Var=null):Var {return f("ine", a, b, t);}
		public function ifg(a:Var=null, b:Var=null, t:Var=null):Var {return f("ifg", a, b, t);}
		public function ifl(a:Var=null, b:Var=null, t:Var=null):Var {return f("ifl", a, b, t);}
		public function els(a:Var=null, b:Var=null, t:Var=null):Var {return f("els", a, b, t);}
		public function eif(a:Var=null, b:Var=null, t:Var=null):Var {return f("eif", a, b, t);}
		public function ted(a:Var=null, b:Var=null, t:Var=null):Var {return f("ted", a, b, t);}
		public function kil(a:Var=null, b:Var=null, t:Var=null):Var {return f("kil", a, b, t);}
		public function tex(a:Var=null, b:Var=null, t:Var=null):Var {return f("tex", a, b, t);}
		public function sge(a:Var=null, b:Var=null, t:Var=null):Var {return f("sge", a, b, t);}
		public function slt(a:Var=null, b:Var=null, t:Var=null):Var {return f("slt", a, b, t);}
		public function sgn(a:Var=null, b:Var=null, t:Var=null):Var {return f("sgn", a, b, t);}
		public function seq(a:Var=null, b:Var=null, t:Var=null):Var {return f("seq", a, b, t);}
		public function sne(a:Var=null, b:Var=null, t:Var=null):Var {return f("sne", a, b, t);}
		
	}

}