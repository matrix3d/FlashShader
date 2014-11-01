package;

import flash.display.Sprite;
import flash.display3D.Context3DProgramType;
import flShader.Creator;
import flShader.FlShader;
import flShader.Var;
/**
 * ...
 * @author lizhi
 */

class Main extends Sprite 
{

	public function new() 
	{
		super();
		var shader:FlShader = new FlShader(Context3DProgramType.VERTEX);
		shader.mov(shader.V(), null, FlShader.op);
		shader.tex(shader.V(), null, FlShader.op,["2d","nomip"]);
		trace(shader.code);
	}
}
