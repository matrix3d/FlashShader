package 
{
	import as3Shader.AS3Shader;
	import as3Shader.GLCodeCreator;
	import as3Shader.Var;
	import flash.display.Sprite;
	import gl3d.util.HFloat;
	/**
	 * ...
	 * @author lizhi
	 */
	public class TestHF extends Sprite
	{
		
		public function TestHF() 
		{
			var a:Number =-4.438871302557631;
			var b:Number = 0.000030517578125;
			trace(a,b);
			trace(HFloat.half2float2( HFloat.toHalfFloat2(a,b)));
			trace(HFloat.half2float2Agal( HFloat.toHalfFloat2(a,b)));
			return;
			var samples:Array = [
				0x3C00, // = 1
					0xC000, // = −2
					0x7BFF, // = 6.5504 × 10^4 (max half precision)
					0x0400, // = 2^−14 ≈ 6.10352 × 10^−5 (minimum positive normal)
					0x0001, // = 2^−24 ≈ 5.96046 × 10^−8 (minimum strictly positive subnormal)
					0x0000, // = 0
					0x8000, // = −0
					0x7C00, // = Infinity
					0xFC00, // = −Infinity
					0x3555, // ≈ 0.33325... ≈ 1/3
					0x7C01  // = NaN
				]
			samples = [HFloat.toHalfFloat(0.000007172189798818296)];
			//samples = [HFloat.toHalfFloat(125.8)];
			for each(var s:int in samples){
				trace("---------------");
				trace(s.toString(2));
				trace(s);
				trace(HFloat.toFloat(s));
				trace(HFloat.toFloatAgal(s));
			}
			trace(HFloat.toFloat(1));
			trace(HFloat.toFloat(0x8001));
			//testshader();
		}
		
		private function testshader():void{
			var s:AS3Shader = new AS3Shader;
			var half:Var = s.buff();
			var halfshr10:Var = s.div(half , Math.pow(2,10));
			var fshr10:Var = s.frc(halfshr10);
			var se:Var = s.sub(halfshr10 , fshr10);
			var seshr5:Var = s.div(se , Math.pow(2, 5));
			var eshr5:Var = s.frc(seshr5);
			var e:Var = s.mul(eshr5 , Math.pow(2, 5));
			var v:Var = s.mul(s.pow(2, s.sub(e, 15)) , s.add(1 , fshr10));
			v = s.mul(v, s.sge(seshr5, 0));
			trace(s.code);
			var gl:GLCodeCreator = new GLCodeCreator;
			gl.creat(s);
			trace(gl.data);
			trace(s.constPoolVec);
		}
		
	}

}