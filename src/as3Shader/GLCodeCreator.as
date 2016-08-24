package as3Shader 
{
	import flash.display3D.Context3DProgramType;
	/**
	 * http://zach.in.tu-clausthal.de/teaching/cg_literatur/glsl_tutorial/
	 * http://blog.csdn.net/hgl868/article/details/7876257
	 * http://kurst.co.uk/samples/aglsl/
	 * @author lizhi
	 */
	public class GLCodeCreator extends Creator
	{
		private var programTypeName:String;
		private static var simpleOps1:Object = {mul:"*",m44:"*",m33:"*",m34:"*",add:"+",sub:"-",div:"/" };
		private static var simpleOps2:Object = { mov:["",""],neg:["-",""] ,rcp:["1/",""],sat:["clamp(",",0,1)"]};
		private static var simpleOps3:Object = {  
			//rcp
			//min
			//max
			frc:"fract",
			sqt:"sqrt",
			rsq:"inversesqrt",
			//pow
			//log
			//exp
			nrm:"normalize",
			//sin
			//cos
			crs:"cross",
			dp3:"dot",
			dp4:"dot",
			//abs
			//neg
			//sat:"clamp(v,0,1)",
			//ddx
			//ddy
			//ted
			//kil*/
			tex:"texture2D",
			sge:"greaterThanEqual",
			slt:"lessThan",
			sgn:"greaterThan",
			seq:"equal",
			sne:"notEqual"
		};
		private var initedvar:Object = { };
		public function GLCodeCreator() 
		{
			
		}
		
		override public function creat(shader:AS3Shader):void 
		{
			var lines:Array = shader.lines;
			var logs:Object = shader.logs;
			if (shader.programType==Context3DProgramType.VERTEX) {
				programTypeName = "v";
			}else {
				programTypeName = "f";
			}
			var uniformTxt:String = "";
			var varyingTxt:String = "";
			var attributeTxt:String = "";
			var txt:String = "void main(){\n";
			for (var i:int = 0; i < lines.length;i++ ) {
				var log:Array = logs[i];
				if (log) {
					for each(var lb:Object in log) {
						txt +="\t//"+ lb + "\n";
					}
				}
				var line:Array = lines[i];
				var op:String = line[0];
				var v1var:Var = line[1] as Var;
				var v1:String = var2String(v1var);
				if (initedvar[v1]==null) {
					initedvar[v1] = true;
					if (v1var.type == Var.TYPE_T) {
						v1 = var2type(v1var)+" " + v1;
					}else if (v1var.type==Var.TYPE_V) {
						varyingTxt += "varying "+var2type(v1var)+" " + v1 + ";\n";
					}
				}
				var ps:Array = [];
				for (var j:int = 2; j < line.length;j++ ) {
					var v:Var = line[j];
					var vtxt:String = var2String(v.root,false);
					var vtype:String = var2type(v);
					ps.push(vtxt);
					if (initedvar[vtxt] == null) {
						initedvar[vtxt] = true;
						if((v.type==Var.TYPE_FS)||(v.type==Var.TYPE_C)){
							uniformTxt += "uniform "+vtype+" " + vtxt + ";\n";
						}else if (v.type==Var.TYPE_V) {
							varyingTxt += "varying "+vtype+" " + vtxt + ";\n";
						}else if (v.type==Var.TYPE_VA) {
							attributeTxt += "attribute "+vtype+" " + vtxt + ";\n";
						}
					}
				}
				if (op2simple1(op)) {
					txt += "\t" + v1 + " = " + ps.join(" "+op2simple1(op)+" ");
					if (line["flag"]) {
						txt += ",<" + line["flag"]+">";
					}
					txt += ";";
				}else if (op2simple2(op)) {
					txt += "\t" + v1 + " = " +op2simple2(op)[0]+ ps+op2simple2(op)[1]+";";
				}else {
					txt += "\t" + v1 + " = " + op2simple3(op) + "(" +ps;
					if (line["flag"]) {
						txt += ",<" + line["flag"]+">";
					}
					txt += ");";
				}
				
				txt += "\n"
			}
			log = logs[i];
			if (log) {
				for each(lb in log) {
					txt +="//"+ lb + "\n";
				}
			}
			txt = uniformTxt+varyingTxt+attributeTxt + txt;
			data = txt + "}";
			if (shader.programType==Context3DProgramType.FRAGMENT) {
				data = "precision mediump float;\n" + data;
			}
		}
		
		private function var2type(v:Var):String {
			if (v.type == Var.TYPE_FS) return "sampler2D";
			if (v.constLenght == 1) return "vec4";
			return "mat" + v.constLenght;
		}
		
		private function var2StringNoIndex(v:Var):String {
			var vtxt:String;
			switch(v.type) {
				case Var.TYPE_C:
					vtxt = programTypeName+"c";
					break;
				case Var.TYPE_FS:
					vtxt = programTypeName+"s";
					break;
				case Var.TYPE_OC:
					vtxt = "gl_FragColor";
					break;
				case Var.TYPE_OP:
					vtxt = "gl_Position";
					break;
				case Var.TYPE_T:
					vtxt = programTypeName+"t";
					break;
				case Var.TYPE_V:
					vtxt = "v";
					break;
				case Var.TYPE_VA:
					vtxt = programTypeName+"a";
					break;
			}
			return vtxt;
		}
		
		private function var2String(v:Var,hasComponent:Boolean=true):String {
			var vtxt:String = var2StringNoIndex(v);
			if (v.component && v.component is Var) {
				
			}else {
				switch(v.type) {
					case Var.TYPE_C:
					case Var.TYPE_FS:
					case Var.TYPE_T:
					case Var.TYPE_V:
					case Var.TYPE_VA:
						vtxt += v.index;
				}
			}
			if (hasComponent&&v.component) {
				if (v.component is Var) {
					var cv:Var = v.component as Var;
					vtxt += "["+var2String(cv)+"+"+(v.index+v.componentOffset)+"]";
				}else {
					vtxt += "." + v.component;
				}
			}
			return vtxt;
		}
		
		private function op2simple1(op:String):String {
			return simpleOps1[op];
		}
		private function op2simple2(op:String):Array {
			return simpleOps2[op];
		}
		private function op2simple3(op:String):String {
			return simpleOps3[op]||op;
		}
	}
}