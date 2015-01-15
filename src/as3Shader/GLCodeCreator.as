package as3Shader 
{
	import flash.display3D.Context3DProgramType;
	/**
	 * ...
	 * @author lizhi
	 */
	public class GLCodeCreator extends Creator
	{
		private var programTypeName:String;
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
			var txt:String = "void main(void){\n";
			for (var i:int = 0; i < lines.length;i++ ) {
				var log:Array = logs[i];
				if (log) {
					for each(var lb:Object in log) {
						txt +="\n//"+ lb + "\n";
					}
				}
				var line:Array = lines[i];
				txt +="\t"+ var2String(line[1])+" = "+ line[0]+"(";
				for (var j:int = 2; j < line.length;j++ ) {
					var v:Var = line[j];
					txt += (j==2?"":",") + var2String(v);
				}
				if (line.flag) {
					txt += ",<" + line.flag+">";
				}
				txt += ")";
				txt += "\n"
			}
			log = logs[i];
			if (log) {
				for each(lb in log) {
					txt +="//"+ lb + "\n";
				}
			}
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
					vtxt += "["+var2String(cv)+"+"+cv.offset+"]";
				}else {
					vtxt += "." + v.component;
				}
			}
			return vtxt;
		}
		
		
	}

}