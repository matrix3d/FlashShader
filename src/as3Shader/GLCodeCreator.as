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
		private var simpleOps1:Object = {mul:"*",m44:"*",m33:"*",m34:"*",add:"+",sub:"-",div:"/" };
		private var simpleOps2:Object = { mov:true };
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
						v1 = "vec4 " + v1;
					}else if (v1var.type==Var.TYPE_V) {
						varyingTxt += "varying vec4 " + v1 + "\n";
					}
				}
				var ps:Array = [];
				for (var j:int = 2; j < line.length;j++ ) {
					var v:Var = line[j];
					var vtxt:String = var2String(v);
					ps.push(vtxt);
					if (initedvar[vtxt] == null) {
						initedvar[vtxt] = true;
						if((v.type==Var.TYPE_FS)||(v.type==Var.TYPE_C)){
							uniformTxt += "uniform vec4 " + vtxt + "\n";
						}else if (v.type==Var.TYPE_V) {
							varyingTxt += "varying vec4 " + vtxt + "\n";
						}else if (v.type==Var.TYPE_VA) {
							attributeTxt += "attribute vec4 " + vtxt + "\n";
						}
					}
				}
				if (op2simple1(op)) {
					txt += "\t" + v1 + " = " + ps.join(" "+op2simple1(op)+" ");
					if (line.flag) {
						txt += ",<" + line.flag+">";
					}
					txt += ";";
				}else if (op2simple2(op)) {
					txt += "\t" + v1 + " = " + ps;
				}else {
					txt += "\t" + v1 + " = " + op + "(" +ps;
					if (line.flag) {
						txt += ",<" + line.flag+">";
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
			data = txt+"}";
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
		
		private function var2String(v:Var):String {
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
			if (v.component) {
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
		private function op2simple2(op:String):String {
			return simpleOps2[op];
		}
	}

}