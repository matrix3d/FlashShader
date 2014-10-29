package flShader 
{
	import flash.display3D.Context3DProgramType;
	/**
	 * ...
	 * @author lizhi
	 */
	public class AGALCodeCreator extends Creator
	{
		public function AGALCodeCreator() 
		{
			
		}
		override public function creat(shader:FlShader):void 
		{
			var lines:Array = shader.lines;
			
			var programTypeName:String;
			if (shader.programType==Context3DProgramType.VERTEX) {
				programTypeName = "v";
			}else {
				programTypeName = "f";
			}
			var txt:String = "";
			for (var i:int = 0; i < lines.length;i++ ) {
				var line:Array = lines[i];
				txt += line[0];
				for (var j:int = 1; j < line.length;j++ ) {
					var v:Var = line[j];
					var vtxt:String;
					switch(v.type) {
						case Var.TYPE_C:
							vtxt = programTypeName+"c" + v.index;
							break;
						case Var.TYPE_FS:
							vtxt = programTypeName+"s" + v.index;
							break;
						case Var.TYPE_OC:
							vtxt = "oc";
							break;
						case Var.TYPE_OP:
							vtxt = "op";
							break;
						case Var.TYPE_T:
							vtxt = programTypeName+"t" + v.index;
							break;
						case Var.TYPE_V:
							vtxt = "v" + v.index;
							break;
						case Var.TYPE_VA:
							vtxt = programTypeName+"a" + v.index;
							break;
					}
					txt += "," + vtxt;
					if (v.component) {
						txt += "." + v.component;
					}
				}
				if (line.flag) {
					txt += ",<" + line.flag+">";
				}
				txt += "\n"
				data = txt;
			}
		}
		
	}

}