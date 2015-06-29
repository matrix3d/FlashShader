package as3Shader 
{
	/**
	 * http://help.adobe.com/en_US/as3/dev/WSd6a006f2eb1dc31e-310b95831324724ec56-8000.html
	 * @author lizhi
	 */
	public class NativeOp 
	{
		private var shader:AS3Shader;
		
		public function NativeOp(shader:AS3Shader) 
		{
			this.shader = shader;
			
		}
		
		public function doop(op:String, a:Var, b:Var):Var {
			var fun:Function = this[op] as Function;
			if (fun!=null) {
				return fun(a,b);
			}
			return null;
		}
		
		public function i_doop1(a:Var, b:Var, fun:Function):Var {
			var v:Array = [];
			var len:int = Math.max(a.data.length, b.data.length);
			for (var i:int = 0; i < len;i++ ) {
				v[i] = fun(a.data[i%a.data.length],b.data[i%b.data.length]);
			}
			return shader.object2Var(v);
		}
		
		public function mov(a:Var, b:Var):Var {
			throw "no imp";
			return null;
		}
		public function add(a:Var, b:Var):Var {
			return i_doop1(a,b,i_add);
		}
		public function sub(a:Var, b:Var):Var {
			return i_doop1(a,b,i_sub);
		}
		public function mul(a:Var, b:Var):Var {
			return i_doop1(a,b,i_mul);
		}
		public function div(a:Var, b:Var):Var {
			return i_doop1(a,b,i_div);
		}
		public function rcp(a:Var, b:Var):Var {
			throw "no imp";
			return null;
		}
		public function min(a:Var, b:Var):Var {
			return i_doop1(a,b,i_min);
		}
		public function max(a:Var, b:Var):Var {
			return i_doop1(a,b,i_max);
		}
		public function frc(a:Var, b:Var):Var {
			throw "no imp";
			return null;
		}
		public function sqt(a:Var, b:Var):Var {
			throw "no imp";
			return null;
		}
		public function rsq(a:Var, b:Var):Var {
			throw "no imp";
			return null;
		}
		public function pow(a:Var, b:Var):Var {
			return i_doop1(a,b,i_pow);
		}
		public function log(a:Var, b:Var):Var {
			throw "no imp";
			return null;
		}
		public function exp(a:Var, b:Var):Var {
			throw "no imp";
			return null;
		}
		public function nrm(a:Var, b:Var):Var {
			throw "no imp";
			return null;
		}
		public function sin(a:Var, b:Var):Var {
			throw "no imp";
			return null;
		}
		public function cos(a:Var, b:Var):Var {
			throw "no imp";
			return null;
		}
		public function crs(a:Var, b:Var):Var {
			throw "no imp";
			return null;
		}
		public function dp3(a:Var, b:Var):Var {
			throw "no imp";
			return null;
		}
		public function dp4(a:Var, b:Var):Var {
			throw "no imp";
			return null;
		}
		public function abs(a:Var, b:Var):Var {
			throw "no imp";
			return null;
		}
		public function neg(a:Var, b:Var):Var {
			throw "no imp";
			return null;
		}
		public function sat(a:Var, b:Var):Var {
			throw "no imp";
			return null;
		}
		public function m33(a:Var, b:Var):Var {
			throw "no imp";
			return null;
		}
		public function m44(a:Var, b:Var):Var {
			throw "no imp";
			return null;
		}
		public function m34(a:Var, b:Var):Var {
			throw "no imp";
			return null;
		}
		public function ife(a:Var, b:Var):Var {
			throw "no imp";
			return null;
		}
		public function ine(a:Var, b:Var):Var {
			throw "no imp";
			return null;
		}
		public function ifg(a:Var, b:Var):Var {
			throw "no imp";
			return null;
		}
		public function ifl(a:Var, b:Var):Var {
			throw "no imp";
			return null;
		}
		public function els(a:Var, b:Var):Var {
			throw "no imp";
			return null;
		}
		public function eif(a:Var, b:Var):Var {
			throw "no imp";
			return null;
		}
		public function ted(a:Var, b:Var):Var {
			throw "no imp";
			return null;
		}
		public function sge(a:Var, b:Var):Var {
			throw "no imp";
			return null;
		}
		public function slt(a:Var, b:Var):Var {
			throw "no imp";
			return null;
		}
		public function sgn(a:Var, b:Var):Var {
			throw "no imp";
			return null;
		}
		public function seq(a:Var, b:Var):Var {
			throw "no imp";
			return null;
		}
		public function sne(a:Var, b:Var):Var {
			throw "no imp";
			return null;
		}
		
		public function i_mov(a:Number, b:Number):Number {
			return 0;
		}
		public function i_add(a:Number, b:Number):Number {
			return a+b;
		}
		public function i_sub(a:Number, b:Number):Number {
			return a-b;
		}
		public function i_mul(a:Number, b:Number):Number {
			return a*b;
		}
		public function i_div(a:Number, b:Number):Number {
			return a/b;
		}
		public function i_rcp(a:Number, b:Number):Number {
			return 1/a;
		}
		public function i_min(a:Number, b:Number):Number {
			return Math.min(a,b);
		}
		public function i_max(a:Number, b:Number):Number {
			return Math.max(a,b);
		}
		public function i_frc(a:Number, b:Number):Number {
			return 0;
		}
		public function i_sqt(a:Number, b:Number):Number {
			return 0;
		}
		public function i_rsq(a:Number, b:Number):Number {
			return 0;
		}
		public function i_pow(a:Number, b:Number):Number {
			return Math.pow(a,b);
		}
		public function i_log(a:Number, b:Number):Number {
			return 0;
		}
		public function i_exp(a:Number, b:Number):Number {
			return 0;
		}
		public function i_nrm(a:Number, b:Number):Number {
			return 0;
		}
		public function i_sin(a:Number, b:Number):Number {
			return 0;
		}
		public function i_cos(a:Number, b:Number):Number {
			return 0;
		}
		public function i_crs(a:Number, b:Number):Number {
			return 0;
		}
		public function i_dp3(a:Number, b:Number):Number {
			return 0;
		}
		public function i_dp4(a:Number, b:Number):Number {
			return 0;
		}
		public function i_abs(a:Number, b:Number):Number {
			return 0;
		}
		public function i_neg(a:Number, b:Number):Number {
			return 0;
		}
		public function i_sat(a:Number, b:Number):Number {
			return 0;
		}
		public function i_m33(a:Number, b:Number):Number {
			return 0;
		}
		public function i_m44(a:Number, b:Number):Number {
			return 0;
		}
		public function i_m34(a:Number, b:Number):Number {
			return 0;
		}
		public function i_ife(a:Number, b:Number):Number {
			return 0;
		}
		public function i_ine(a:Number, b:Number):Number {
			return 0;
		}
		public function i_ifg(a:Number, b:Number):Number {
			return 0;
		}
		public function i_ifl(a:Number, b:Number):Number {
			return 0;
		}
		public function i_els(a:Number, b:Number):Number {
			return 0;
		}
		public function i_eif(a:Number, b:Number):Number {
			return 0;
		}
		public function i_ted(a:Number, b:Number):Number {
			return 0;
		}
		public function i_sge(a:Number, b:Number):Number {
			return 0;
		}
		public function i_slt(a:Number, b:Number):Number {
			return 0;
		}
		public function i_sgn(a:Number, b:Number):Number {
			return 0;
		}
		public function i_seq(a:Number, b:Number):Number {
			return 0;
		}
		public function i_sne(a:Number, b:Number):Number {
			return 0;
		}
		
	}

}