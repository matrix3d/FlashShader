package flShader;

import flash.display3D.Context3DProgramType;

/**

 * ...

 * @author lizhi

 */class AGALCodeCreator extends Creator {

	var programTypeName : String;
	public function new() {
		super();
	}

	override public function creat(shader : FlShader) : Void {
		var lines : Array<Dynamic> = shader.lines;
		if(shader.programType == Context3DProgramType.VERTEX)  {
			programTypeName = "v";
		}

		else  {
			programTypeName = "f";
		}

		var txt : String = "";
		var i : Int = 0;
		while(i < lines.length) {
			var line : Array<Dynamic> = lines[i];
			txt += line[0];
			var j : Int = 1;
			while(j < line.length) {
				var v : Var = line[j];
				txt += " " + var2String(v);
				j++;
			}
			var flag = shader.line2Flag.get(line);
			if(flag!=null)  {
				txt += ",<" + flag.join(",") + ">";
			}
			txt += "\n";
			data = txt;
			i++;
		}
	}

	function var2StringNoIndex(v : Var) : String {
		var vtxt : String=null;
		var _sw0_ = (v.type);
		switch(_sw0_) {
		case Var.TYPE_C:
			vtxt = programTypeName + "c";
		case Var.TYPE_FS:
			vtxt = programTypeName + "s";
		case Var.TYPE_OC:
			vtxt = "oc";
		case Var.TYPE_OP:
			vtxt = "op";
		case Var.TYPE_T:
			vtxt = programTypeName + "t";
		case Var.TYPE_V:
			vtxt = "v";
		case Var.TYPE_VA:
			vtxt = programTypeName + "a";
		}
		return vtxt;
	}

	function var2String(v : Var) : String {
		var vtxt : String = var2StringNoIndex(v);
		if(v.component && Std.is(v.component, Var)) 
			{ }
		else  {
			var _sw1_ = (v.type);
			switch(_sw1_) {
			case Var.TYPE_C, Var.TYPE_FS, Var.TYPE_T, Var.TYPE_V, Var.TYPE_VA:
				vtxt += v.index;
			}
		}

		if(v.component)  {
			if(Std.is(v.component, Var))  {
				var cv : Var = try cast(v.component, Var) catch(e:Dynamic) null;
				vtxt += "[" + var2String(cv) + "+" + cv.offset + "]";
			}

			else  {
				vtxt += "." + v.component;
			}

		}
		return vtxt;
	}

}

